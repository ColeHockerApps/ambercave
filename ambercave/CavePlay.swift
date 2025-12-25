import SwiftUI
import Combine
import WebKit

struct CavePlay: UIViewRepresentable {

    let startPoint: URL
    let portals: CavePortals
    let rune: CaveOrientationRune
    let onReady: () -> Void

    func makeCoordinator() -> Guide {
        Guide(
            startPoint: startPoint,
            portals: portals,
            rune: rune,
            onReady: onReady
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)

        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator

        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false

        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black

        let refresh = UIRefreshControl()
        refresh.addTarget(
            context.coordinator,
            action: #selector(Guide.handleRefresh(_:)),
            for: .valueChanged
        )
        view.scrollView.refreshControl = refresh

        context.coordinator.attach(view)
        context.coordinator.begin()

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

final class Guide: NSObject, WKNavigationDelegate, WKUIDelegate {

    private let startPoint: URL
    private let portals: CavePortals
    private let rune: CaveOrientationRune
    private let onReady: () -> Void

    weak var mainView: WKWebView?
    weak var popupView: WKWebView?

    private var marksTimer: Timer?
    private var didReveal = false
    private var didScheduleSave = false

    init(
        startPoint: URL,
        portals: CavePortals,
        rune: CaveOrientationRune,
        onReady: @escaping () -> Void
    ) {
        self.startPoint = startPoint
        self.portals = portals
        self.rune = rune
        self.onReady = onReady
    }

    func attach(_ view: WKWebView) {
        mainView = view
    }

    func begin() {
        didReveal = false
        didScheduleSave = false
        rune.setActiveValue(startPoint)
        mainView?.load(URLRequest(url: startPoint))
    }

    @objc func handleRefresh(_ sender: UIRefreshControl) {
        mainView?.reload()
    }

    private func normalize(_ value: String) -> String {
        var v = value
        while v.count > 1, v.hasSuffix("/") {
            v.removeLast()
        }
        return v
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor action: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if webView === popupView {
            if let main = mainView,
               let next = action.request.url {
                if action.targetFrame?.isMainFrame != false {
                    rune.setActiveValue(next)
                }
                main.load(URLRequest(url: next))
            }
            decisionHandler(.cancel)
            return
        }

        guard let next = action.request.url,
              let scheme = next.scheme?.lowercased(),
              scheme == "http" || scheme == "https" || scheme == "about"
        else {
            decisionHandler(.cancel)
            return
        }

        if action.targetFrame?.isMainFrame != false {
            rune.setActiveValue(next)
        }

        if action.targetFrame == nil {
            webView.load(action.request)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        stopMarksJob()
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        handleFinish(in: webView)
    }

    func webView(
        _ webView: WKWebView,
        didFail _: WKNavigation!,
        withError _: Error
    ) {
        handleFailure(in: webView)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation _: WKNavigation!,
        withError _: Error
    ) {
        handleFailure(in: webView)
    }

    private func revealIfNeeded() {
        guard didReveal == false else { return }
        didReveal = true
        DispatchQueue.main.async { self.onReady() }
    }

    private func handleFinish(in view: WKWebView) {
        view.scrollView.refreshControl?.endRefreshing()

        guard let current = view.url else {
            rune.setActiveValue(nil)
            stopMarksJob()
            revealIfNeeded()
            return
        }

        rune.setActiveValue(current)
        scheduleSaveIfNeeded()
        runMarksJob(for: current, in: view)
        revealIfNeeded()
    }

    private func handleFailure(in view: WKWebView) {
        view.scrollView.refreshControl?.endRefreshing()
        rune.setActiveValue(view.url)
        stopMarksJob()
        revealIfNeeded()
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for _: WKNavigationAction,
        windowFeatures _: WKWindowFeatures
    ) -> WKWebView? {
        let popup = WKWebView(frame: .zero, configuration: configuration)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        popupView = popup
        return popup
    }

    private func scheduleSaveIfNeeded() {
        guard didScheduleSave == false else { return }
        didScheduleSave = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self,
                  let active = self.mainView?.url else { return }

            let base = self.startPoint.absoluteString
            let now = active.absoluteString
            guard self.normalize(now) != self.normalize(base) else { return }

            self.portals.storeResumeIfNeeded(active)
        }
    }

    private func runMarksJob(for point: URL, in view: WKWebView) {
        stopMarksJob()

        let mask = (point.host ?? "").lowercased()

        marksTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak view, weak portals] _ in
            guard let view, let portals else { return }

            view.configuration.websiteDataStore.httpCookieStore.getAllCookies { list in
                let filtered = list.filter {
                    mask.isEmpty || $0.domain.lowercased().contains(mask)
                }

                let packed = filtered.map { c -> [String: Any] in
                    var m: [String: Any] = [
                        "name": c.name,
                        "value": c.value,
                        "domain": c.domain,
                        "path": c.path,
                        "secure": c.isSecure,
                        "httpOnly": c.isHTTPOnly
                    ]
                    if let e = c.expiresDate {
                        m["expires"] = e.timeIntervalSince1970
                    }
                    if #available(iOS 13.0, *), let s = c.sameSitePolicy {
                        m["sameSite"] = s.rawValue
                    }
                    return m
                }

                portals.saveMarks(packed)
            }
        }

        if let job = marksTimer {
            RunLoop.main.add(job, forMode: .common)
        }
    }

    private func stopMarksJob() {
        marksTimer?.invalidate()
        marksTimer = nil
    }
}

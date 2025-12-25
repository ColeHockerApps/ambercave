import Foundation
import CoreGraphics

struct HexGrid {

    let radius: CGFloat
    let spacing: CGFloat

    private(set) var nodes: [HexNode.Axial: HexNode] = [:]

    init(
        rows: Int,
        cols: Int,
        radius: CGFloat,
        spacing: CGFloat = 1.0,
        center: CGPoint = .zero
    ) {
        self.radius = radius
        self.spacing = spacing
        buildGrid(rows: rows, cols: cols, center: center)
    }

    mutating func buildGrid(rows: Int, cols: Int, center: CGPoint) {
        nodes.removeAll()

        let w = radius * 2
        let h = sqrt(3) * radius

        for r in 0..<rows {
            for q in 0..<cols {

                let xOffset = CGFloat(q) * w * 0.75
                let yOffset = CGFloat(r) * h + (CGFloat(q % 2) * h / 2)

                let position = CGPoint(
                    x: center.x + xOffset,
                    y: center.y + yOffset
                )

                let axial = HexNode.Axial(q: q, r: r)

                let node = HexNode(
                    axial: axial,
                    position: position,
                    radius: radius,
                    color: HexNode.HexColor.allCases.randomElement()!,
                    state: .occupied
                )

                nodes[axial] = node
            }
        }
    }

    func node(at axial: HexNode.Axial) -> HexNode? {
        nodes[axial]
    }

    mutating func setNode(_ node: HexNode) {
        nodes[node.axial] = node
    }

    func neighbors(of axial: HexNode.Axial) -> [HexNode] {
        guard let node = nodes[axial] else { return [] }
        return node.neighbors().compactMap { nodes[$0] }
    }

    func occupiedNeighbors(of axial: HexNode.Axial) -> [HexNode] {
        neighbors(of: axial).filter { $0.state == .occupied }
    }
}

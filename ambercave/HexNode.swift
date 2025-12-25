import Foundation
import CoreGraphics

struct HexNode: Identifiable, Hashable {

    let id: UUID = UUID()

    var axial: Axial
    var position: CGPoint
    var radius: CGFloat

    var color: HexColor
    var state: State

    enum State {
        case empty
        case occupied
        case locked
    }

    enum HexColor: Int, CaseIterable {
        case red
        case blue
        case green
        case yellow
        case purple
        case orange
    }

    struct Axial: Hashable {
        var q: Int
        var r: Int
    }

    init(
        axial: Axial,
        position: CGPoint,
        radius: CGFloat,
        color: HexColor,
        state: State = .occupied
    ) {
        self.axial = axial
        self.position = position
        self.radius = radius
        self.color = color
        self.state = state
    }

    func neighbors() -> [Axial] {
        [
            Axial(q: axial.q + 1, r: axial.r),
            Axial(q: axial.q - 1, r: axial.r),
            Axial(q: axial.q, r: axial.r + 1),
            Axial(q: axial.q, r: axial.r - 1),
            Axial(q: axial.q + 1, r: axial.r - 1),
            Axial(q: axial.q - 1, r: axial.r + 1)
        ]
    }
}

import Foundation
import CoreGraphics

enum OrbMergeLogic {

    static func resolveMerge(
        on grid: inout HexGrid,
        at axial: HexNode.Axial,
        insertedColor: HexNode.HexColor,
        chain: inout Int,
        score: inout Int
    ) -> Bool {
        guard var node = grid.node(at: axial) else { return false }

        if node.state != .occupied {
            node.state = .occupied
            node.color = insertedColor
            grid.setNode(node)
            return true
        }

        guard node.color == insertedColor else { return false }

        node.color = upgradedColor(node.color)
        grid.setNode(node)

        chain += 1
        score += mergePoints(color: node.color, chain: chain)

        performCascade(from: axial, grid: &grid, chain: &chain, score: &score)
        return true
    }

    static func tryPlaceOrMerge(
        on grid: inout HexGrid,
        near point: CGPoint,
        insertedColor: HexNode.HexColor,
        chain: inout Int,
        score: inout Int
    ) -> Bool {
        guard let axial = grid.nearestAxial(to: point) else { return false }
        return resolveMerge(on: &grid, at: axial, insertedColor: insertedColor, chain: &chain, score: &score)
    }

    private static func upgradedColor(_ c: HexNode.HexColor) -> HexNode.HexColor {
        let all = HexNode.HexColor.allCases
        guard let idx = all.firstIndex(of: c) else { return c }
        let next = idx + 1
        if next < all.count { return all[next] }
        return all.last ?? c
    }

    private static func mergePoints(color: HexNode.HexColor, chain: Int) -> Int {
        let base = 10 + color.rawValue * 6
        let mult = 1 + min(6, chain)
        return base * mult
    }

    private static func performCascade(
        from start: HexNode.Axial,
        grid: inout HexGrid,
        chain: inout Int,
        score: inout Int
    ) {
        var pivot = start

        while true {
            guard let pivotNode = grid.node(at: pivot), pivotNode.state == .occupied else { break }

            let component = connectedComponent(of: pivotNode.color, from: pivot, in: grid)

            if component.count < 3 { break }

            for a in component where a != pivot {
                if var n = grid.node(at: a) {
                    n.state = .empty
                    grid.setNode(n)
                }
            }

            var upgraded = pivotNode
            upgraded.color = upgradedColor(upgraded.color)
            upgraded.state = .occupied
            grid.setNode(upgraded)

            chain += 1
            score += mergePoints(color: upgraded.color, chain: chain)

            pivot = upgraded.axial
        }
    }

    private static func connectedComponent(
        of color: HexNode.HexColor,
        from start: HexNode.Axial,
        in grid: HexGrid
    ) -> Set<HexNode.Axial> {
        var visited = Set<HexNode.Axial>()
        var queue: [HexNode.Axial] = [start]

        while let current = queue.first {
            queue.removeFirst()
            if visited.contains(current) { continue }

            guard let node = grid.node(at: current),
                  node.state == .occupied,
                  node.color == color
            else { continue }

            visited.insert(current)

            let next = node.neighbors()
            for a in next where visited.contains(a) == false {
                queue.append(a)
            }
        }

        return visited
    }
}

extension HexGrid {

    func nearestAxial(to point: CGPoint) -> HexNode.Axial? {
        var best: HexNode.Axial?
        var bestD: CGFloat = .greatestFiniteMagnitude

        for (axial, node) in nodes {
            let dx = node.position.x - point.x
            let dy = node.position.y - point.y
            let d = dx * dx + dy * dy
            if d < bestD {
                bestD = d
                best = axial
            }
        }

        return best
    }
}

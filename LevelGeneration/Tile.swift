public struct Tile { // Represents a tile on the level grid
    public let point: LevelPoint // Each tile has a point
    public var tileState: TileState // The state of each tile
}

extension Tile: Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(point)
        hasher.combine(tileState)
    }
    
    public static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.point == rhs.point &&
          lhs.tileState == rhs.tileState
    }
}

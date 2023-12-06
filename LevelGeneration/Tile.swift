class Tile {
    let point: Point
    var tileState: TileState

    init(point: Point, tileState: TileState) {
        self.point = point
        self.tileState = tileState
    }
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

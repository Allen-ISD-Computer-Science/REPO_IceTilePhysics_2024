class Tile { // Represents a tile on the level grid, class because Tiles are passed in reference when constructing the Grid
    let point: Point // Each tile has a point, x values increase as tiles continue to the right, y values increase as tile continue down
    var tileState: TileState // The state of each tile

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

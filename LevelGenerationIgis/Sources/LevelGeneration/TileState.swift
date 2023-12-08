public enum TileState: String, CustomStringConvertible {
    case wall // Represents a tile that the player will collide and end a slide with
    case critical // Represents a tile that the player can land on, sub set of active tiles
    case active // Represents a tile that the player can "paint" (slide over/land on)
    case inactive // Represents a tile that is not a tile, wall, or active (empty)

    public var description: String {
        switch self {
        case .wall:
            return "wall"
        case .critical:
            return "critical"
        case .active:
            return "active"
        case .inactive:
            return "inactive"
        }
    }
}

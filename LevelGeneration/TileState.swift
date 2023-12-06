enum TileState: String, CustomStringConvertible {
    case wall, critical, active, inactive

    var description: String {
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

struct GridPoint { // Defines a point with an x and y value
    let x: Int
    let y: Int
}

extension GridPoint: Equatable, Hashable {
   
    public static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
        return lhs.x == rhs.x &&
          lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

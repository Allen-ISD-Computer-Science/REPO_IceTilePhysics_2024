struct Point { // Defines a point with an x and y value
    let x: Int
    let y: Int
}

extension Point: Equatable, Hashable {
   
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x &&
          lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

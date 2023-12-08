public struct GridPoint { // Defines a point with an x and y value
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
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

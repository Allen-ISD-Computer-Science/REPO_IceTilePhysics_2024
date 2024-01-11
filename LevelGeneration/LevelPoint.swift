public struct LevelPoint { // Defines a point with an x and y value
    public let x: Int
    public let y: Int
    public let cubeFace: CubeFace

    public init(x: Int, y: Int, cubeFace: CubeFace) {
        self.x = x
        self.y = y
        self.cubeFace = cubeFace
    }
}

extension LevelPoint: Equatable, Hashable {
   
    public static func ==(lhs: LevelPoint, rhs: LevelPoint) -> Bool {
        return lhs.x == rhs.x &&
          lhs.y == rhs.y &&        
          lhs.cubeFace == rhs.cubeFace
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(cubeFace)
    }
}

struct CubeEdge: Equatable, Hashable {
    let cubeFace: CubeFace
    let direction: Direction

    init(_ cubeFace: CubeFace, _ direction: Direction) {
        self.cubeFace = cubeFace
        self.direction = direction
    }

    static func ==(lhs: CubeEdge, rhs: CubeEdge) -> Bool {
        return lhs.cubeFace == rhs.cubeFace &&
          lhs.direction == rhs.direction
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(cubeFace)
        hasher.combine(direction)
    }            
}

enum CubeEdgeTransformation {
    case maxX
    case maxY
    case minX
    case minY
    case swap
    case invertDeltaY
    case invertDeltaX

    func transform(levelSize: LevelSize, newCubeFace: CubeFace, point: LevelPoint) -> LevelPoint {
        let newFaceSize = levelSize.faceSize(cubeFace: newCubeFace)
        switch self {
        case .maxX:                
            return LevelPoint(x: newFaceSize.maxX - 1, y: point.y, cubeFace: newCubeFace)
        case .maxY:
            return LevelPoint(x: point.x, y: newFaceSize.maxY - 1, cubeFace: newCubeFace)
        case .minX:
            return LevelPoint(x: 0, y: point.y, cubeFace: newCubeFace)
        case .minY:
            return LevelPoint(x: point.x, y: 0, cubeFace: newCubeFace)
        case .swap:
            return LevelPoint(x: point.y, y: point.x, cubeFace: newCubeFace)
        case .invertDeltaX:
            return LevelPoint(x: newFaceSize.maxX - 1 - point.x, y: point.y, cubeFace: newCubeFace)
        case .invertDeltaY:
            return LevelPoint(x: point.x, y: newFaceSize.maxY - 1 - point.y, cubeFace: newCubeFace)
        }
    }
}

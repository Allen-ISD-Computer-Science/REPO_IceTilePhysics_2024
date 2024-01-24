public struct Level {
    public let levelSize: LevelSize
    public let startingPosition: LevelPoint

    public var faceLevels: [FaceLevel]
    public var levelGraph = Graph()
    public init(levelSize: LevelSize, startingPosition: LevelPoint) {
        self.levelSize = levelSize
        self.startingPosition = startingPosition
        
        // Create the face levels
        var faceLevels = [FaceLevel]()
        for cubeFace in [CubeFace]([.back, .left, .top, .right, .front, .bottom]) { // Arbitrary order of cube faces
            faceLevels.append(FaceLevel(faceSize: levelSize.faceSize(cubeFace: cubeFace), cubeFace: cubeFace))
        }
        self.faceLevels = faceLevels
        setTileState(levelPoint: startingPosition, tileState: .critical)
        initializeCriticalTiles()
    }

    // Initializing function that is used to set the state of one or multiple tiles
    mutating func setTileState(levelPoint: LevelPoint, tileState: TileState) {
        faceLevels[levelPoint.cubeFace.rawValue].setTileState(levelPoint: levelPoint, tileState: tileState)
    }
    mutating func setTileState(levelPoints: [LevelPoint], tileState: TileState) {
        levelPoints.forEach { setTileState(levelPoint: $0, tileState: tileState) }
    }

    // Initializing functiona that is used to change the state of one or multiple tiles if they match a current tile state
    mutating func changeTileStateIfCurrent(levelPoint: LevelPoint, current currentTileState: TileState, new newTileState: TileState) {
        faceLevels[levelPoint.cubeFace.rawValue].changeTileStateIfCurrent(levelPoint: levelPoint, current: currentTileState, new: newTileState)        
    }
    mutating func changeTileStateIfCurrent(levelPoints: [LevelPoint], current currentTileState: TileState, new newTileState: TileState) {
        levelPoints.forEach { changeTileStateIfCurrent(levelPoint: $0, current: currentTileState, new: newTileState) }   
    }

    func tilePointsOfState(tileState: TileState) -> [LevelPoint] {
        return faceLevels.flatMap { $0.tilePointsOfState(tileState: tileState) }
    }

    let crossCubeEdgeMap: [CubeEdge:(CubeFace, Direction, [CubeEdgeTransformation])] = [
      CubeEdge(.back, .up):(.bottom, .up, [.maxY]),
      CubeEdge(.back, .right):(.right, .down, [.swap, .invertDeltaX, .minY]),
      CubeEdge(.back, .down):(.top, .down, [.minY]),
      CubeEdge(.back, .left):(.left, .down, [.swap]),
      CubeEdge(.left, .up):(.back, .right, [.swap]),
      CubeEdge(.left, .right):(.top, .right, [.minX]),
      CubeEdge(.left, .down):(.front, .right, [.swap, .minX]),
      CubeEdge(.left, .left):(.bottom, .right, [.invertDeltaY, .minX]),
      CubeEdge(.top, .up):(.back, .up, [.maxY]),
      CubeEdge(.top, .right):(.right, .right, [.minX]),
      CubeEdge(.top, .down):(.front, .down, [.minY]),
      CubeEdge(.top, .left):(.left, .left, [.maxX]),
      CubeEdge(.right, .up):(.back, .left, [.swap, .maxX]),
      CubeEdge(.right, .right):(.bottom, .left, [.invertDeltaY, .maxX]),
      CubeEdge(.right, .down):(.front, .left, [.swap]),
      CubeEdge(.right, .left):(.top, .left, [.maxX]),
      CubeEdge(.front, .up):(.top, .up, [.maxY]),
      CubeEdge(.front, .right):(.right, .up, [.swap]),
      CubeEdge(.front, .down):(.bottom, .down, [.minY]),
      CubeEdge(.front, .left):(.left, .up, [.swap, .invertDeltaX, .maxY]),
      CubeEdge(.bottom, .up):(.front, .up, [.maxY]),
      CubeEdge(.bottom, .right):(.right, .left, [.invertDeltaY, .maxX]),
      CubeEdge(.bottom, .down):(.back, .down, [.minY]),
      CubeEdge(.bottom, .left):(.left, .right, [.invertDeltaY, .minX]),
    ]

    func adjacentPoint(from origin: LevelPoint, direction: Direction) -> (adjacentPoint: LevelPoint, direction: Direction) {        
        func handleEdge() -> (LevelPoint, Direction) {
            guard let (cubeFace, direction, transformations) = crossCubeEdgeMap[CubeEdge(origin.cubeFace, direction)] else {
                fatalError("Unexpected edge transformation.")
            }
            return (transformations.reduce(origin, { (point: LevelPoint, transformation: CubeEdgeTransformation) -> LevelPoint in
                                                           return transformation.transform(levelSize: levelSize, newCubeFace: cubeFace, point: point)
                                                        }), direction)
        }

        let faceSize = levelSize.faceSize(cubeFace: origin.cubeFace)
        switch direction {
        case .up:
            if origin.y - 1 < 0 { // Transform
                return handleEdge()
            }
            return (LevelPoint(x: origin.x, y: origin.y - 1, cubeFace: origin.cubeFace), direction)
        case .down:
            if origin.y + 1 >= faceSize.maxY { // Another face
                return handleEdge()
            }
            return (LevelPoint(x: origin.x, y: origin.y + 1, cubeFace: origin.cubeFace), direction)
        case .left:
            if origin.x - 1 < 0 { // Another face
                return handleEdge()
            }
            return (LevelPoint(x: origin.x - 1, y: origin.y, cubeFace: origin.cubeFace), direction)
        case .right:
            if origin.x + 1 >= faceSize.maxX {
                return handleEdge()
            }
            return (LevelPoint(x: origin.x + 1, y: origin.y, cubeFace: origin.cubeFace), direction)
        }
    }

    func adjacentPoints(levelPoint: LevelPoint) -> [(adjacentPoint: LevelPoint, direction: Direction)] {
        return [Direction]([.up, .down, .left, .right]).map { adjacentPoint(from: levelPoint, direction: $0) }
    }

    func slideCriticalTile(origin: LevelPoint, direction: Direction) -> Slide {
        let originFaceLevel = faceLevels[origin.cubeFace.rawValue]
        precondition(originFaceLevel.tiles[origin.x][origin.y].tileState == .critical,
                     "Tile state must be critical in order to slide.")
        var previous = origin
        var (destination, direction) = adjacentPoint(from: previous, direction: direction)
        var activatedTilePoints = [LevelPoint]()
        while faceLevels[destination.cubeFace.rawValue].tiles[destination.x][destination.y].tileState != .wall {
            previous = destination
            activatedTilePoints.append(previous)
            (destination, direction) = adjacentPoint(from: destination, direction: direction)
        }
        return Slide(origin: origin, destination: previous, activatedTilePoints: activatedTilePoints)
    }

    mutating func initializeCriticalTiles(criticalTilePoints: [LevelPoint]? = nil) {
        let allCriticalTiles = tilePointsOfState(tileState: .critical)
        var foundCriticalTilePoints = [LevelPoint]()
        for criticalTilePoint in criticalTilePoints ?? allCriticalTiles {            
            for direction in [Direction]([.up, .down, .left, .right]) {
                let slide = slideCriticalTile(origin: criticalTilePoint, direction: direction)                
                if slide.origin != slide.destination {
                    levelGraph.slides.insert(slide)
                    if !allCriticalTiles.contains(slide.destination) {
                        setTileState(levelPoint: slide.destination, tileState: .critical)
                        changeTileStateIfCurrent(levelPoints: slide.activatedTilePoints, current: .inactive, new: .active)
                        foundCriticalTilePoints.append(slide.destination)
                    }
                }
            }
        }
        if foundCriticalTilePoints.count > 0 {
            initializeCriticalTiles(criticalTilePoints: foundCriticalTilePoints)
        }
    }

    func activeTilePointsAdjacentToCriticals() -> [LevelPoint] {
        let activeTilePoints = tilePointsOfState(tileState: .active)
        return activeTilePoints.filter {
            for direction in [Direction]([.up, .down, .left, .right]) {
                let adjacentPoint = adjacentPoint(from: $0, direction: direction).adjacentPoint
                if faceLevels[adjacentPoint.cubeFace.rawValue].tiles[adjacentPoint.x][adjacentPoint.y].tileState == .critical {
                    return true
                }
            }
            return false
        }
    }

        // Resets the level to be revalidated
    mutating func resetLevel() {
        tilePointsOfState(tileState: .active).forEach { setTileState(levelPoint: $0, tileState: .inactive) }
        tilePointsOfState(tileState: .critical).forEach { setTileState(levelPoint: $0, tileState: .inactive) }
        levelGraph.slides = []
        setTileState(levelPoint: startingPosition, tileState: .critical)
        initializeCriticalTiles()
    }
    

    // Checks if a level grid is solvable by ensuring that every critical point has a path to the starting position    
    func solvable() -> Bool {
        for criticalTileGridPoint in tilePointsOfState(tileState: .critical) {
            if levelGraph.breadthFirstSearch(origin: criticalTileGridPoint, destination: startingPosition) == nil {
                return false
            }
        }
        return true
    }

    func printTileStates() {
        for cubeFace in [CubeFace]([.back, .left, .top, .right, .front, .bottom]) {
            print(cubeFace)
            faceLevels[cubeFace.rawValue].printTileStates()
        }              
    }
}

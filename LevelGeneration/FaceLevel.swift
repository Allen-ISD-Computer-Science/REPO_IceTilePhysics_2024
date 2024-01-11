import Foundation

public struct FaceLevel { // Represents one side of a level within our game
    public let faceSize: FaceSize
    public let cubeFace: CubeFace    

    public var faceLevelTiles: [[Tile]]
    public init(faceSize: FaceSize, cubeFace: CubeFace) {
        self.faceSize = faceSize
        self.cubeFace = cubeFace

        // Create the grid tiles and set their state as inactive by default
        var gridTiles = [[Tile]]()
        for x in 0 ..< faceSize.maxX {
            var tileColumn = [Tile]()
            for y in 0 ..< faceSize.maxY {
                tileColumn.append(Tile(point: LevelPoint(x: x, y: y, cubeFace: cubeFace), tileState: .inactive))
            }
            gridTiles.append(tileColumn)
        }
        self.gridTiles = gridTiles
        setBorderToWall() // Testing purposes
    }

    // Initializing function that sets the state of border tiles to .wall
    mutating func setBordersToWall() {
        let borderPoints = borderPoints()
        for borderPoint in borderPoints {
            gridTiles[borderPoint.x][borderPoint.y].tileState = .wall
        }
    }

    // Initializing function that is used to set the state of one or multiple tiles
    mutating func setTileState(levelPoint: LevelPoint, tileState: TileState) {
        gridTiles[levelPoint.x][levelPoint.y].tileState = tileState
    }
    mutating func setTileState(levelPoints: [LevelPoint], tileState: TileState) {
        levelPoints.forEach { setTileState(levelPoint: $0, tileState: tileState) }
    }
    
    // Initializing function that is used to change the state of one or multiple tiles if they match a current tile state
    mutating func changeTileStateIfCurrent(levelPoint: LevelPoint, current currentTileState: TileState, new newTileState: TileState) {
        if gridTiles[levelPoint.x][levelPoint.y].tileState == currentTileState {
            gridTiles[levelPoint.x][levelPoint.y].tileState = newTileState
        }
    }
    mutating func changeTileStateIfCurrent(levelPoints: [LevelPoint], current currentTileState: TileState, new newTileState: TileState) {
        levelPoints.forEach { changeTileStateIfCurrent(levelPoint: $0, current: currentTileState, new: newTileState)
    }

    // Returns the points of tiles along the border of a face
    func borderPoints() -> [LevelPoint] {
        var borderPoints = [LevelPoint]()
        for tileColumn in gridTiles {
            for tile in tileColumn {
                if tile.point.x == 0 || tile.point.x == (faceSize.maxX - 1) ||
                     tile.point.y == 0 || tile.point.y == (faceSize.maxY - 1) {
                    borderPoints.append(tile.point)
                }
            }
        }
        return borderPoints
    }
    
    // Returns the points of all tiles with a tile state
    func tilePointsOfState(tileState: TileState) -> [LevelPoint] {
        var tilePointsOfState = [LevelPoint]()
        for tileColumn in gridTiles {
            for tile in tileColumn {
                if gridTiles[tile.point.x][tile.point.y].tileState == tileState {
                    tilePointsOfState.append(tile.point)
                }
            }
        }
        return tilePointsOfState
    }

    func adjacentTile(from orginPoint: LevelPoint, direction: Direction) -> (adjacentPoint: LevelPoint, newDirection: Direction) {
        var x: Int
        var y: Int
        var direction: Direction
        switch direction {
        case .up:
            if originPoint.y - 1 < 0 { // Another face
                return (originPoint, direction)
            }
            return (LevelPoint(x: originPoint.x, y: orginPoint.y - 1, cubeFace: cubeFace), direction)
        case .down:
            if originPoint.y + 1 >= faceSize.maxY { // Another face
                return (originPoint, direction)
            }
            return (LevelPoint(x: originPoint.x, y: originPoint.y + 1, cubeFace: cubeFace), direction)
        case .left:
            if originPoint.x - 1 < 0 { // Another face
                return (originPoint, direction)
            }
            return (LevelPoint(x: originPoint.x - 1, y: originPoint.y, cubeFace: cubeFace), direction)
        case .right:
            if originPoint.x + 1 >= faceSize.maxX {
                return (originPoint, direction)
            }
            return (LevelPoint(x: originPoint.x + 1, originPoint.y, cubeFace: cubeFace), direction)
        }
    }

    func slideCriticalTile(origin: LevelPoint, direction: Direction) -> Slide {
        precondition(origin.tileState == .critical, "Tile state must be critical in order to slide.")
        var destination = origin
        var activatedTilePoints = [LevelPoint]()
        repeat {
            destination = adjacentTile(from: destination, direction: direction)
            activatedTilePoints.append(destination)
        } while destination.tileState != .wall
        activatedTilePoints.removeLast()
        return Slide(origin: origin, destination: destination, activatedTilePoints: activatedTilePoints)
    }

    func initializeCriticalTiles(criticalTilePoints: [LevelPoint]?) {
        let criticalTilePoints = criticalTilePoints ?? tilePointsOfState(tileState: .critical)
        var foundCriticalTilePoints = [LevelPoint]()
        for criticalTilePoint in criticalTilePoints {            
            for direction in Direction {
                let slide = slideCriticalTile(origin: criticalTilePoint, direction: direction)
                if slide.origin != slide.destination {
                    foundCriticalTilePoints.append(slide.destination)
                }
            }
        }
    }
}
    

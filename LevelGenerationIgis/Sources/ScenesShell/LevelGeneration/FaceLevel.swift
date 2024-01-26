import Foundation

struct FaceLevel { // Represents one side of a level within our game
    let faceSize: FaceSize
    let cubeFace: CubeFace    

    public var tiles: [[Tile]]
    init(faceSize: FaceSize, cubeFace: CubeFace) {
        self.faceSize = faceSize
        self.cubeFace = cubeFace

        // Create the grid tiles and set their state as inactive by default
        var tiles = [[Tile]]()
        for x in 0 ..< faceSize.maxX {
            var tileColumn = [Tile]()
            for y in 0 ..< faceSize.maxY {
                tileColumn.append(Tile(point: LevelPoint(x: x, y: y, cubeFace: cubeFace), tileState: .inactive))
            }
            tiles.append(tileColumn)
        }
        self.tiles = tiles
        setBordersToWall() // Testing purposes
    }

    // Initializing function that sets the state of border tiles to .wall
    mutating func setBordersToWall() {
        let borderPoints = borderPoints()
        for borderPoint in borderPoints {
            tiles[borderPoint.x][borderPoint.y].tileState = .wall
        }
    }

    // Initializing function that is used to set the state of one or multiple tiles
    mutating func setTileState(levelPoint: LevelPoint, tileState: TileState) {
        tiles[levelPoint.x][levelPoint.y].tileState = tileState
    }
    mutating func setTileState(levelPoints: [LevelPoint], tileState: TileState) {
        levelPoints.forEach { setTileState(levelPoint: $0, tileState: tileState) }
    }
    
    // Initializing function that is used to change the state of one or multiple tiles if they match a current tile state
    mutating func changeTileStateIfCurrent(levelPoint: LevelPoint, current currentTileState: TileState, new newTileState: TileState) {
        if tiles[levelPoint.x][levelPoint.y].tileState == currentTileState {
            tiles[levelPoint.x][levelPoint.y].tileState = newTileState
        }
    }
    mutating func changeTileStateIfCurrent(levelPoints: [LevelPoint], current currentTileState: TileState, new newTileState: TileState) {
        levelPoints.forEach { changeTileStateIfCurrent(levelPoint: $0, current: currentTileState, new: newTileState) }
    }

    // Returns the points of tiles along the border of a face
    func borderPoints() -> [LevelPoint] {
        var borderPoints = [LevelPoint]()
        for tileColumn in tiles {
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
        for tileColumn in tiles {
            for tile in tileColumn {
                if tiles[tile.point.x][tile.point.y].tileState == tileState {
                    tilePointsOfState.append(tile.point)
                }
            }
        }
        return tilePointsOfState
    }

    // Prints the grid
    func printTileStates() {
        for y in 0 ..< faceSize.maxY {
            var stateRow = [TileState]()
            for x in 0 ..< faceSize.maxX {
                stateRow.append(tiles[x][y].tileState)
            }
            print(stateRow)
        }
    }
}    

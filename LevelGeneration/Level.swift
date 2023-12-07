import Foundation

struct Level { // Represents a Level of our Ice Tile Physics game
    let startingPosition: GridPoint // Where the player would start    
    let size: GridSize // The size of the level grid
    
    var gridTiles: [[Tile]] // The tiles that make up the level grid
    var graph = Graph() // How the tiles on the graph are connected through slides

    init(size: GridSize, startingPosition: GridPoint) {
        precondition(startingPosition.x > 0 &&
                       startingPosition.x < size.width &&
                       startingPosition.y > 0 &&
                       startingPosition.y < size.height,
                     "Starting position must be with the bounds of the grid.")        
        
        self.size = size
        self.startingPosition = startingPosition

        // Create the grid tiles and set their state as inactive by default
        var gridTiles = [[Tile]]()
        for x in 0 ..< size.width {
            var tileColumn = [Tile]()
            for y in 0 ..< size.height {
                tileColumn.append(Tile(point: GridPoint(x: x, y: y), tileState: .inactive))
            }
            gridTiles.append(tileColumn)
        }
        self.gridTiles = gridTiles
        setBoundaryWalls()
        setTileState(point: startingPosition, tileState: .critical)
        createCriticalTiles()        
    }

    // Sets boundary walls on the grid, all perimeter tile states are set to wall
    mutating func setBoundaryWalls() {
        for boundY in [0, size.height - 1] {
            for x in 0 ..< size.width {
                gridTiles[x][boundY].tileState = .wall
            }
        }
        for boundX in [0, size.width - 1] {
            for y in 0 ..< size.height {
                gridTiles[boundX][y].tileState = .wall
            }
        }        
    }

    // Returns the points of all tiles that have a given state
    func tileGridPointsOfState(tileState: TileState) -> [GridPoint] {
        var tileGridPointsOfState = [GridPoint]()
        for tileColumn in gridTiles {
            for tile in tileColumn {
                if tile.tileState == tileState {
                    tileGridPointsOfState.append(tile.point)
                }
            }
        }
        return tileGridPointsOfState
    }


    // Returns a slide in a given direction from a given point
    func slideTile(point: GridPoint, direction: Direction) -> Slide {
        precondition(gridTiles[point.x][point.y].tileState == .critical, "A tile must be critical in order to slide.")
        var activatedTileGridPoints = [GridPoint]()
        let destination: GridPoint
        switch direction {
        case .down:
            var incrementY = 1
            while gridTiles[point.x][point.y + incrementY].tileState != .wall {                
                activatedTileGridPoints.append(GridPoint(x: point.x, y: point.y + incrementY))
                incrementY += 1
            }            
            destination = GridPoint(x: point.x, y: point.y + incrementY - 1)
        case .up:
            var decrementY = 1
            while gridTiles[point.x][point.y - decrementY].tileState != .wall {
                activatedTileGridPoints.append(GridPoint(x: point.x, y: point.y - decrementY))
                decrementY += 1
            }
            destination = GridPoint(x: point.x, y: point.y - decrementY + 1)
        case .right:
            var incrementX = 1
            while gridTiles[point.x + incrementX][point.y].tileState != .wall {
                activatedTileGridPoints.append(GridPoint(x: point.x + incrementX, y: point.y))
                incrementX += 1
            }
            destination = GridPoint(x: point.x + incrementX - 1, y: point.y)
        case .left:
            var decrementX = 1
            while gridTiles[point.x - decrementX][point.y].tileState != .wall {
                activatedTileGridPoints.append(GridPoint(x: point.x - decrementX, y: point.y))
                decrementX += 1
            }
            destination = GridPoint(x: point.x - decrementX + 1, y: point.y)
        }
        if activatedTileGridPoints.count > 0 {
            activatedTileGridPoints.removeLast()
        }
        return Slide(origin: point, destination: destination, activatedTileGridPoints: activatedTileGridPoints)
    }

    // Returns an array of Slides of all four directions from a given point
    func slideAllDirections(point: GridPoint) -> [Slide] {
        return [slideTile(point: point, direction: .up), slideTile(point: point, direction: .down),
                slideTile(point: point, direction: .right), slideTile(point: point, direction: .left)]
    }

    // Sets a given point's tile state
    mutating func setTileState(point: GridPoint, tileState: TileState) {
        gridTiles[point.x][point.y].tileState = tileState
    }
    // Sets multiple given points' tile states
    mutating func setTileState(points: [GridPoint], tileState: TileState) {
        points.forEach { setTileState(point: $0, tileState: tileState) }
    }
    // Changes a given point's tile state if it has the previous tile state
    mutating func changeTileState(point: GridPoint, previousTileState: TileState, newTileState: TileState) {
        if gridTiles[point.x][point.y].tileState == previousTileState {
            setTileState(point: point, tileState: newTileState)
        }
    }
    // Changes multiple given points' tile states if they have the previous tile state
    mutating func changeTileState(points: [GridPoint], previousTileState: TileState, newTileState: TileState) {
        points.forEach { changeTileState(point: $0, previousTileState: previousTileState, newTileState: newTileState) }
    }

    // Recursively "sets" the critical tile states by sliding from the starting position. Active tiles along a slide are "changed"
    mutating func createCriticalTiles(criticalTileGridPoints: [GridPoint]? = nil) { // Default uses all curent critical tiles
        let allCriticalTileGridPoints = tileGridPointsOfState(tileState: .critical)
        for criticalTileGridPoint in criticalTileGridPoints ?? allCriticalTileGridPoints {
            // For each critical tile slide in all directions and change states accordingly
            let criticalSlides = slideAllDirections(point: criticalTileGridPoint).filter { $0.origin != $0.destination }
            criticalSlides.forEach { graph.slides.insert($0) }
            let activatedTileGridPoints: [GridPoint] = Array(criticalSlides.map { $0.activatedTileGridPoints }.joined())
            changeTileState(points: activatedTileGridPoints, previousTileState: .inactive, newTileState: .active)
            let newDestinations = criticalSlides.map { $0.destination }.filter { !allCriticalTileGridPoints.contains($0) }
            setTileState(points: newDestinations, tileState: .critical)
            // If there are new critical tiles found, recursively call this function until all critical tiles are found
            if newDestinations.count > 0 {
                createCriticalTiles(criticalTileGridPoints: newDestinations)
            }                             
        }            
    }
    
    // Prints the grid
    func printGrid() {
        for y in 0 ..< size.height {
            var stateRow = [TileState]()
            for x in 0 ..< size.width {
                stateRow.append(gridTiles[x][y].tileState)
            }
            print(stateRow)
        }
    }
}

extension Level {
    // Functions used for randomizing levels
    
    // Returns an array of active points that have an adjacent critical point
    func activesAdjacentToCriticals() -> [GridPoint] {
        let activeTileGridPoints = tileGridPointsOfState(tileState: .active)
        let criticalTileGridPoints = tileGridPointsOfState(tileState: .critical)

        func adjacentCritical(point: GridPoint) -> Bool {
            for criticalTileGridPoint in criticalTileGridPoints {
                // If x value is +- 1 and y value is same or y value is +- 1 and x value is same
                if abs(criticalTileGridPoint.x - point.x) == 1 && criticalTileGridPoint.y == point.y ||
                     abs(criticalTileGridPoint.y - point.y) == 1 && criticalTileGridPoint.x == point.x { 
                    return true
                }
            }
            return false
        }
        return activeTileGridPoints.filter { adjacentCritical(point: $0) }
    }

    // Resets the level to be revalidated
    mutating func resetLevel() {
        tileGridPointsOfState(tileState: .active).forEach { gridTiles[$0.x][$0.y].tileState = .inactive }
        tileGridPointsOfState(tileState: .critical).forEach { gridTiles[$0.x][$0.y].tileState = .inactive }
        graph.slides = []
        setTileState(point: startingPosition, tileState: .critical)
        createCriticalTiles()
    }
    

    // Checks if a level grid is solvable by ensuring that every critical point has a path to the starting position    
    func solvable() -> Bool {
        for criticalTileGridPoint in tileGridPointsOfState(tileState: .critical) {
            if graph.breadthFirstSearch(origin: criticalTileGridPoint, destination: startingPosition) == nil {
                return false
            }
        }
        return true
    }
}

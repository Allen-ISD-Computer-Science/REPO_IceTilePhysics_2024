struct Level { // Represents a Level of our Ice Tile Physics game
    let startingPosition: Point // Where the player would start    
    let size: Size // The size of the level grid
    
    var gridTiles: [[Tile]] // The tiles that make up the level grid
    var graph = Graph() // How the tiles on the graph are connected through slides

    init(size: Size, startingPosition: Point) {
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
                tileColumn.append(Tile(point: Point(x: x, y: y), tileState: .inactive))
            }
            gridTiles.append(tileColumn)
        }
        self.gridTiles = gridTiles
        setBoundaryWalls()
        tile(startingPosition).tileState = .critical
        createCriticalTiles()        
    }

    func tile(_ point: Point) -> Tile {
        precondition(size.width > point.x || size.height > point.y, "Point must be within the bounds of the grid.")
        return gridTiles[point.x][point.y]
    }
    func tiles(_ points: [Point]) -> [Tile] {
        var tiles = [Tile]()
        for point in points {
            tiles.append(tile(point))
        }
        return tiles
    }

    // Sets boundary walls on the grid, all perimeter tile states are set to wall
    mutating func setBoundaryWalls() {
        for boundY in [0, size.height - 1] {
            for x in 0 ..< size.width {
                tile(Point(x: x, y: boundY)).tileState = .wall
            }
        }
        for boundX in [0, size.width - 1] {
            for y in 0 ..< size.height {
                tile(Point(x: boundX, y: y)).tileState = .wall
            }
        }        
    }

    // Returns the points of all tiles that have a given state
    func tilePointsOfState(tileState: TileState) -> [Point] {
        var tilePointsOfState = [Point]()
        for tileColumn in gridTiles {
            for tile in tileColumn {
                if tile.tileState == tileState {
                    tilePointsOfState.append(tile.point)
                }
            }
        }
        return tilePointsOfState
    }


    // Returns a slide in a given direction from a given point
    func slideTile(point: Point, direction: Direction) -> Slide {
        precondition(tile(point).tileState == .critical, "A tile must be critical in order to slide.")
        var activatedTilePoints = [Point]()
        let destination: Point
        switch direction {
        case .down:
            var incrementY = 1
            while tile(Point(x: point.x, y: point.y + incrementY)).tileState != .wall {                
                activatedTilePoints.append(Point(x: point.x, y: point.y + incrementY))
                incrementY += 1
            }            
            destination = Point(x: point.x, y: point.y + incrementY - 1)
        case .up:
            var decrementY = 1
            while tile(Point(x: point.x, y: point.y - decrementY)).tileState != .wall {
                activatedTilePoints.append(Point(x: point.x, y: point.y - decrementY))
                decrementY += 1
            }
            destination = Point(x: point.x, y: point.y - decrementY + 1)
        case .right:
            var incrementX = 1
            while tile(Point(x: point.x + incrementX, y: point.y)).tileState != .wall {
                activatedTilePoints.append(Point(x: point.x + incrementX, y: point.y))
                incrementX += 1
            }
            destination = Point(x: point.x + incrementX - 1, y: point.y)
        case .left:
            var decrementX = 1
            while tile(Point(x: point.x - decrementX, y: point.y)).tileState != .wall {
                activatedTilePoints.append(Point(x: point.x - decrementX, y: point.y))
                decrementX += 1
            }
            destination = Point(x: point.x - decrementX + 1, y: point.y)
        }
        if activatedTilePoints.count > 0 {
            activatedTilePoints.removeLast()
        }
        return Slide(origin: point, destination: destination, activatedTilePoints: activatedTilePoints)
    }

    // Returns an array of Slides of all four directions from a given point
    func slideAllDirections(point: Point) -> [Slide] {
        return [slideTile(point: point, direction: .up), slideTile(point: point, direction: .down),
                slideTile(point: point, direction: .right), slideTile(point: point, direction: .left)]
    }

    // Sets a given point's tile state
    mutating func setTileState(point: Point, tileState: TileState) {
        tile(point).tileState = tileState
    }
    // Sets multiple given points' tile states
    mutating func setTileState(points: [Point], tileState: TileState) {
        points.forEach { setTileState(point: $0, tileState: tileState) }
    }
    // Changes a given point's tile state if it has the previous tile state
    mutating func changeTileState(point: Point, previousTileState: TileState, newTileState: TileState) {
        if tile(point).tileState == previousTileState {
            tile(point).tileState = newTileState
        }
    }
    // Changes multiple given points' tile states if they have the previous tile state
    mutating func changeTileState(points: [Point], previousTileState: TileState, newTileState: TileState) {
        points.forEach { changeTileState(point: $0, previousTileState: previousTileState, newTileState: newTileState) }
    }

    // Recursively "sets" the critical tile states by sliding from the starting position. Active tiles along a slide are "changed"
    mutating func createCriticalTiles(criticalTilePoints: [Point]? = nil) { // Default uses all curent critical tiles
        let currentCriticalTilePoints = tilePointsOfState(tileState: .critical)
        let criticalTiles = criticalTilePoints == nil ? tiles(currentCriticalTilePoints) : tiles(criticalTilePoints!)
        for criticalTile in criticalTiles {
            // For each critical tile slide in all directions and change states accordingly
            let criticalSlides = slideAllDirections(point: criticalTile.point).filter { $0.origin != $0.destination }
            criticalSlides.forEach { graph.slides.insert($0) }
            let activatedTilePoints: [Point] = Array(criticalSlides.map { $0.activatedTilePoints }.joined())
            changeTileState(points: activatedTilePoints, previousTileState: .inactive, newTileState: .active)
            let newDestinations = criticalSlides.map { $0.destination }.filter { !currentCriticalTilePoints.contains($0) }
            setTileState(points: newDestinations, tileState: .critical)
            // If there are new critical tiles found, recursively call this function until all critical tiles are found
            if newDestinations.count > 0 {
                createCriticalTiles(criticalTilePoints: newDestinations)
            }                             
        }            
    }

    // Checks if a level grid is solvable by ensuring that every critical point has a path to the starting position
    func solvable() -> Bool {
        for criticalTilePoint in tilePointsOfState(tileState: .critical) {
            if graph.breadthFirstSearch(origin: criticalTilePoint, destination: startingPosition) == nil {
                return false
            }
        }
        return true
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

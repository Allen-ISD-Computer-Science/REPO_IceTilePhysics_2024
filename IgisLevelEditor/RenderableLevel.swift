import Igis
import Scenes
import LevelGeneration

class RenderableLevel: RenderableEntity, MouseDownHandler {
    public var level: Level
    private var updatedLevel = true

    // Private variable that stores the size of a single square tile on a renderable level
    private var tileSize = Size(width: 20, height: 20)
    // Private variable to narrow a search on click to a single face level
    private var faceLevelBoundingRects: [Rect] = []
    // Private variable that stores all rects for every tile
    private var faceLevelRectGrids: [[[Rect]]] = []
      
    init(level: Level) {
        self.level = level
        super.init(name:"RenderableLevel")
    }

    // Protocols
    // MouseDownHandler - onMouseDown
    func onMouseDown(globalLocation: Point) {
        for face in Face.allCases {
            // Detects if/which face was clicked
            if faceLevelBoundingRects[face.rawValue].containment(target: globalLocation).contains(.containedFully) {
                // !!! This algorithm could be improved but MVP !!!                
                for x in 0 ..< faceLevelRectGrids[face.rawValue].count {
                    for y in 0 ..< faceLevelRectGrids[face.rawValue][x].count {
                        if faceLevelRectGrids[face.rawValue][x][y].containment(target: globalLocation).contains(.containedFully) {
                            let tile = level.faceLevels[face.rawValue].tiles[x][y]
                            guard tile.point != level.startingPosition else {
                                return
                            }
                            if tile.tileState == .wall {
                                level.faceLevels[face.rawValue].tiles[x][y].tileState = .inactive
                            } else {                                
                                level.faceLevels[face.rawValue].tiles[x][y].tileState = .wall
                            }
                            level.resetLevel()
                            updatedLevel = true
                            return
                        }
                    }
                }
            }            
        }
    }
    
    // RenderableEntity - Setup
    override func setup(canvasSize: Size, canvas: Canvas) {
        dispatcher.registerMouseDownHandler(handler: self)
        let center = Point(x: canvasSize.width / 2, y: canvasSize.height / 2)
        faceLevelBoundingRects = faceLevelBoundingRects(center: center)
        canvas.render(StrokeStyle(color: Color(.black)))
    }

    // Setup Functions
    // Function that returns the size of a bounding box for a face on a level
    func faceLevelSize(face: Face) -> Size {
        let faceSize = level.levelSize.faceSize(face: face)
        return Size(width: tileSize.width * faceSize.maxX, height: tileSize.height * faceSize.maxY)
    }

    // Returns an array of Rect that contain the topLeft Point and Size of each FaceLevel
    func faceLevelBoundingRects(center: Point) -> [Rect] {
        // Face.allCases = [.back, .left, .top, .right, .front, .bottom]
        let faceSizes: [Size] = Face.allCases.map { faceLevelSize(face: $0) }
        let faceTopLefts = {
            // Center Point is located closest to the Front face topLeft, located half of the width of the top to the left
            let frontTopLeft = center - Point(x: faceSizes[4].width / 2, y: 0)
            // Bottom is full height of Front down
            let bottomTopLeft = frontTopLeft + Point(x: 0, y: faceSizes[4].height)
            // Top is full height of Top up
            let topTopLeft = frontTopLeft - Point(x: 0, y: faceSizes[2].height)
            // Left is full width of Left left
            let leftTopLeft = topTopLeft - Point(x: faceSizes[1].width, y: 0)
            // Right is full width of Top right
            let rightTopLeft = topTopLeft + Point(x: faceSizes[2].width, y: 0)
            // Back is full height of Back up
            let backTopLeft = topTopLeft - Point(x: 0, y: faceSizes[0].height)
            return [backTopLeft, leftTopLeft, topTopLeft, rightTopLeft, frontTopLeft, bottomTopLeft]
        }()
        return zip(faceTopLefts, faceSizes).map { Rect(topLeft: $0, size: $1) }
    }

    // RenderableEntity - Calculate
    override func calculate(canvasSize: Size) {
        
    }

    // RenderableEntity - Render
    override func render(canvas: Canvas) {

        // Only if the level was updated do you recalculate/render the rect grids
        if updatedLevel {
            // update the rect grids with this closure
            faceLevelRectGrids = {
                // for each cubeface return a new rect grid
                Face.allCases.map {
                    let face = $0
                    let faceTopLeft = faceLevelBoundingRects[face.rawValue].topLeft
                    let faceLevelTiles = level.faceLevels[face.rawValue].tiles                    
                    let colorGrid = tilesToColorGrid(tiles: faceLevelTiles)
                    var faceLevelRectGrid = [[Rect]]()
                    for tileColumnIndex in 0 ..< faceLevelTiles.count {
                        var faceLevelRectColumn = [Rect]()
                        for tileRowIndex in 0 ..< faceLevelTiles[tileColumnIndex].count {
                            canvas.render(FillStyle(color: colorGrid[tileColumnIndex][tileRowIndex]))
                            let tileTopLeft = faceTopLeft + Point(x: tileColumnIndex * tileSize.width, y: tileRowIndex * tileSize.height)
                            let tileRect = Rect(topLeft: tileTopLeft, size: tileSize)
                            faceLevelRectColumn.append(tileRect)
                            canvas.render(Rectangle(rect: tileRect, fillMode: .fillAndStroke))
                        }
                        faceLevelRectGrid.append(faceLevelRectColumn)
                    }
                    return faceLevelRectGrid
                }        
            }()
            updatedLevel = false
        }   
    }

    // Render Functions
    func tilesToColorGrid(tiles: [[Tile]]) -> [[Color]] {
        let colorGrid: [[Color]] = tiles.map { tileColumn in
            tileColumn.map { tile in
                switch tile.tileState {
                case .active:
                    return Color(.yellow)
                case .critical:
                    return Color(.purple)
                case .wall:
                    return Color(.black)
                case .inactive:
                    return Color(.gray)                    
                }
            }
        }
        return colorGrid
    }

    // RenderableEntity - Teardown
    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

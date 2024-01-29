import Scenes
import Igis
import LevelGeneration

class LevelEditor: RenderableEntity, MouseDownHandler {

    // Formatting - Static Constants
    static let buffer = 30
    
    // Igis
    private var levelEditorRect = Rect()
    private var tileSize = Size()
    private var faceLevelBoundingRects: [Rect] = []
    private var faceLevelRectGrids: [[[Rect]]] = []

    // LevelGeneration
    public var level: Level
    
    init(level: Level) {
        self.level = level
        super.init(name: "LevelEditor")
    }

    func onMouseDown(globalLocation: Point) {
        if levelEditorRect.containment(target: globalLocation).contains(.containedFully) {
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
                                return
                            }
                        }
                    }
                }            
            }
        }
    }

    // UpdateLevel Event
    func updateLevel(level: Level) {        
        self.level = level
        updateLevelRendering()
    }

    // RenderableEntity - setup
    override func setup(canvasSize: Size, canvas: Canvas) {
        // Establish levelEditorRect, tileSize, and faceLevelBoundingRects        
        let levelEditorSize = Size(width: canvasSize.width * 3 / 4, height: canvasSize.height)
        levelEditorRect = Rect(topRight: Point(x: canvasSize.width, y: 0), size: levelEditorSize)
        updateLevelRendering()

        // Render a black StrokeStyle
        canvas.render(StrokeStyle(color: Color(.black)))
        
        // Register MouseDownHandler
        dispatcher.registerMouseDownHandler(handler: self)
    }
    
    // Setup Helper Functions
    // Sets level rendering constants, called by setup and any time level is updated
    func updateLevelRendering() {
        tileSize = calculateTileSize()
        faceLevelBoundingRects = calculateFaceLevelBoundingRects()
    }
    
    // Returns optimal tileSize, fit to height and width separately and take the lower option
    func calculateTileSize() -> Size {
        let verticalTileCount = level.levelSize.length * 2 + level.levelSize.height * 2
        let maxTileHeight = (levelEditorRect.size.height - LevelEditor.buffer) / verticalTileCount
        let horizontalTileCount = level.levelSize.width * 2 + level.levelSize.height * 2
        let maxTileWidth = (levelEditorRect.size.width - LevelEditor.buffer) / horizontalTileCount
        return maxTileHeight > maxTileWidth ? Size(width: maxTileWidth, height: maxTileWidth) : Size(width: maxTileHeight, height: maxTileHeight)        
    }
    
    // Returns the size of a bounding box for a face on a level
    func calculateFaceLevelSize(face: Face) -> Size {
        let faceSize = level.levelSize.faceSize(face: face)
        return Size(width: tileSize.width * faceSize.maxX, height: tileSize.height * faceSize.maxY)
    }

    // Returns an array of Rect that contain the topLeft Point and Size of each FaceLevel
    func calculateFaceLevelBoundingRects() -> [Rect] {
        let center = levelEditorRect.center
        // Face.allCases = [.back, .left, .top, .right, .front, .bottom]
        let faceSizes: [Size] = Face.allCases.map { calculateFaceLevelSize(face: $0) }
        let topRect = {
            var rect = Rect(size: faceSizes[2])
            rect.centerX = center.x
            rect.bottomLeft = center - Point(x: faceSizes[2].width / 2, y: 0)
            return rect            
        }()
        let backRect = Rect(bottomLeft: topRect.topLeft, size: faceSizes[0])
        let leftRect = Rect(topRight: topRect.topLeft, size: faceSizes[1])
        // Skip top as it was initialized first
        let rightRect = Rect(topLeft: topRect.topRight, size: faceSizes[3])
        let frontRect = Rect(topLeft: topRect.bottomLeft, size: faceSizes[4])
        let bottomRect = Rect(topLeft: frontRect.bottomLeft, size: faceSizes[5])
        return [backRect, leftRect, topRect, rightRect, frontRect, bottomRect]
    }

    override func render(canvas: Canvas) {
        // Update FaceLevelRectGrids with this closure
        faceLevelRectGrids = {
            // For each face return a new grid of rects
            Face.allCases.map { face in
                    let relativePoint = faceLevelBoundingRects[face.rawValue].topLeft
                    var rectGrid = [[Rect]]()
                    for x in 0 ..< level.faceLevels[face.rawValue].tiles.count {
                        var rectColumn = [Rect]()
                        for y in 0 ..< level.faceLevels[face.rawValue].tiles[x].count {
                            let tileRect = Rect(topLeft: relativePoint + Point(x: tileSize.width * x, y: tileSize.height * y), size: tileSize)
                            rectColumn.append(tileRect)
                            canvas.render(FillStyle(color: tileToColor(tile: level.faceLevels[face.rawValue].tiles[x][y])))
                            canvas.render(Rectangle(rect: tileRect, fillMode: .fillAndStroke))
                        }
                        rectGrid.append(rectColumn)
                    }
                    return rectGrid
            }
        }()

        let solvableText: String = level.solvable() ? "true" : "false"
        let canvasText = Text(location: levelEditorRect.topLeft + Point(x: 5, y: 5), text: solvableText, fillMode: .fillAndStroke)
        canvasText.alignment = .left
        canvasText.font = "30pt Arial"
        canvasText.baseline = .top
        canvas.render(canvasText)
}

    // Render Helper Functions
    func tileToColor(tile: Tile) -> Color {
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

    

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
    
}

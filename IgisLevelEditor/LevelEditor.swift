import Scenes
import Igis
import LevelGeneration

class LevelEditor: RenderableEntity, MouseDownHandler {

    private enum LevelEditorMode: String {
        case edit, select
    }

    private var mode: LevelEditorMode = .edit
    
    // Formatting - Static Constants
    static let buffer = 30
    
    // Igis
    private var levelEditorRect = Rect()
    private var tileSize = Size()
    private var faceLevelBoundingRects: [Rect] = []
    private var faceLevelRectGrids: [[[Rect]]] = []
    private var updatedLevel = true

    // Selection Mode
    private var selectedPoint: LevelPoint? = nil    
    private var updatedSelectedTile = true
    private var updatedMode = true

    // SpecialTileSelection
    static let specialTileTypeCount = 3
    private var specialTileSelectorBoundingBox = Rect()
    private var specialTileSelectionButtonRects = [Rect]()
    private var selectedSpecialTileType: SpecialTileType = .wall
    private var updatedSpecialTileTypeSelection = true
    private var directionWheel = DirectionWheel()

    // LevelGeneration
    public var level: Level
    private var solvable = false
    
    init(level: Level) {
        self.level = level
        super.init(name: "LevelEditor")
    }

    func onMouseDown(globalLocation: Point) {
        if levelEditorRect.containment(target: globalLocation).contains(.containedFully) {

            func tileClicked() -> Tile? {
                for faceIndex in 0 ..< Face.allCases.count {
                    if faceLevelBoundingRects[faceIndex].containment(target: globalLocation).contains(.containedFully) {
                        let relativePoint = globalLocation - faceLevelBoundingRects[faceIndex].topLeft
                        let xIndex = relativePoint.x / tileSize.width
                        let yIndex = relativePoint.y / tileSize.height
                        return level.faceLevels[faceIndex].tiles[xIndex][yIndex]                    
                    }                    
                }
                return nil
            }

            if let clickedTile = tileClicked() {
                switch mode {
                case .select:
                    selectedPoint = clickedTile.point
                    mode = .edit
                case .edit:
                    guard clickedTile.point != level.startingPosition else {                    
                        return
                    }
                    if clickedTile.specialTileType == selectedSpecialTileType {
                        level.faceLevels[clickedTile.point.face.rawValue].tiles[clickedTile.point.x][clickedTile.point.y].specialTileType = nil
                    }
                    if clickedTile.specialTileType == nil {
                        level.faceLevels[clickedTile.point.face.rawValue].tiles[clickedTile.point.x][clickedTile.point.y].specialTileType = selectedSpecialTileType
                    }

                    // Revert back to wall after placing specialTile
                    if selectedSpecialTileType != .wall {
                        selectedSpecialTileType = .wall
                        updatedSpecialTileTypeSelection = true
                    }
                    
                    level.resetLevel()
                    updatedLevel = true
                }
            } else {
                if specialTileSelectorBoundingBox.containment(target: globalLocation).contains(.containedFully) {
                    for rectIndex in 0 ..< specialTileSelectionButtonRects.count {
                        if specialTileSelectionButtonRects[rectIndex].containment(target: globalLocation).contains(.containedFully) {
                            switch rectIndex {
                            case 0:
                                selectedSpecialTileType = .wall
                            case 1:
                                guard let directionPair = directionWheel.directionPair() else {
                                    print("Must select a valid direction pair before placing a direction shifter.")
                                    return
                                }
                                selectedSpecialTileType = .directionShift(pair: directionPair)
                            case 2:
                                guard let destination = selectedPoint else {
                                    print("Must select a point before placing a portal.")
                                    return
                                }
                                selectedSpecialTileType = .portal(to: destination)
                            default:
                                fatalError("Expected an index less than \(specialTileSelectionButtonRects.count), found \(rectIndex)")
                            }
                            updatedSpecialTileTypeSelection = true
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

    func setSelectionMode() {
        mode = .select
    }
    func setEditMode() {
        mode = .edit
    }
    
    func setSpecialTileType(specialTileType: SpecialTileType) {
        self.selectedSpecialTileType = specialTileType
    }

    // RenderableEntity - setup
    override func setup(canvasSize: Size, canvas: Canvas) {
        // Establish levelEditorRect, tileSize, and faceLevelBoundingRects        
        let levelEditorSize = Size(width: canvasSize.width * 3 / 4, height: canvasSize.height)
        levelEditorRect = Rect(topRight: Point(x: canvasSize.width, y: 0), size: levelEditorSize)
        updateLevelRendering()

        // Render SpecialTileTypeSelector
        // Create a bounding box for the special tile selector, padding is 5 and buttons with be 50x50, 10 padding for width, 5 initial padding for height plus 5 for each special tile
        specialTileSelectorBoundingBox = Rect(topLeft: levelEditorRect.topLeft + Point(x: 5, y: 200), size: Size(width: 60, height: 5 + LevelEditor.specialTileTypeCount * (50 + 5)))        
        canvas.render(StrokeStyle(color: Color(.black)),
                      FillStyle(color: Color(.darkgray)),
                      Rectangle(rect: specialTileSelectorBoundingBox, fillMode: .fillAndStroke))
        for specialTileTypeIndex in 0 ..< LevelEditor.specialTileTypeCount {
            let topLeft = specialTileSelectorBoundingBox.topLeft + Point(x: 5, y: 5) + Point(x: 0, y: (50 + 5) * specialTileTypeIndex)
            let size = Size(width: 50, height: 50)
            let rect = Rect(topLeft: topLeft, size: size)
            let fillColor = [Color(.black), Color(.orange), Color(.lightblue)][specialTileTypeIndex]
            canvas.render(FillStyle(color: fillColor),
                          Rectangle(rect: rect, fillMode: .fillAndStroke))
            specialTileSelectionButtonRects.append(rect)
        }

        directionWheel.setBoundingBox(rect: Rect(topLeft: levelEditorRect.topLeft + Point(x: 5, y: 55), size: Size(width: 100, height: 100)))
        layer.insert(entity:directionWheel, at:.front)


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
        if updatedLevel {
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
                            canvas.render(FillStyle(color: tileToColor(tile: level.faceLevels[face.rawValue].tiles[x][y])),
                                          StrokeStyle(color: Color(.black)),
                                          LineWidth(width: 1))
                            canvas.render(Rectangle(rect: tileRect, fillMode: .fillAndStroke))
                        }
                        rectGrid.append(rectColumn)
                    }
                    return rectGrid
                }
            }()
            
            if level.solvable() != solvable {
                solvable = !solvable
                let solvableString: String = "Solvable Level? " + (solvable ? "true" : "false")
                let solvableText = Text(location: levelEditorRect.topLeft + Point(x: 5, y: 5), text: solvableString, fillMode: .fillAndStroke)
                solvableText.alignment = .left
                solvableText.font = "30pt Arial"
                solvableText.baseline = .top
                canvas.render(FillStyle(color: Color(.lightgray)),
                              Rectangle(rect: Rect(topLeft: levelEditorRect.topLeft + Point(x: 5, y: 5),
                                                   size: Size(width: 450, height: 50)),
                                        fillMode: .fill))
                canvas.render(FillStyle(color: Color(.black)),
                              solvableText)
            }
        }

        if updatedSelectedTile, let selectedPoint = selectedPoint {
            let selectionPath = Path(fillMode: .stroke)
            let selectedRect = faceLevelRectGrids[selectedPoint.face.rawValue][selectedPoint.x][selectedPoint.y]
            selectionPath.rect(selectedRect)
            canvas.render(StrokeStyle(color: Color(.red)),
                          LineWidth(width: 3),
                          selectionPath)
        }

        if updatedSpecialTileTypeSelection {
            let selectedSpecialTileTypeText = Text(location: levelEditorRect.topLeft + Point(x: 5, y: 160),
                                                   text: selectedSpecialTileType.description, fillMode: .fillAndStroke)
            selectedSpecialTileTypeText.alignment = .left
            selectedSpecialTileTypeText.font = "30pt Arial"
            selectedSpecialTileTypeText.baseline = .top
            canvas.render(FillStyle(color: Color(.lightgray)),
                          Rectangle(rect: Rect(topLeft: levelEditorRect.topLeft + Point(x: 5, y: 160),
                                               size: Size(width: 250, height: 33)),
                                    fillMode: .fill))
            canvas.render(FillStyle(color: Color(.black)),
                          StrokeStyle(color: Color(.black)),
                          LineWidth(width: 1),
                          selectedSpecialTileTypeText)
        }

        if updatedMode {
            let modeText = Text(location: levelEditorRect.topLeft + Point(x: 115, y: 50),
                                text: mode.rawValue + " mode", fillMode: .fillAndStroke)
            modeText.alignment = .left
            modeText.font = "30pt Arial"
            modeText.baseline = .top
            canvas.render(FillStyle(color: Color(.lightgray)),
                          Rectangle(rect: Rect(topLeft: levelEditorRect.topLeft + Point(x: 115, y: 50),
                                               size: Size(width: 250, height: 33)),
                                    fillMode: .fill))
            canvas.render(FillStyle(color: Color(.black)),
                          StrokeStyle(color: Color(.black)),
                          LineWidth(width: 1),
                          modeText)
        }

   }

    
    // Render Helper Functions
    func tileToColor(tile: Tile) -> Color {
        // Special Tiles take render priority
        if let specialTileType = tile.specialTileType {
            switch specialTileType {
            case .wall:
                return Color(.black)
            case .directionShift:
                return Color(.orange)
            case .portal:
                return Color(.lightblue)
            }
        }
        switch tile.tileState {
        case .active:
            return Color(.yellow)
        case .critical:
            return Color(.purple)
        case .inactive:
            return Color(.gray)
        }

    }

    

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
    
}

import Scenes
import Igis
import LevelGeneration

class LevelEditor: RenderableEntity, EntityMouseDownHandler, EntityMouseDragHandler, EntityMouseUpHandler {

    public enum LevelEditorMode: String, CaseIterable {
        case edit, select, erase
    }
    public private(set) var mode: LevelEditorMode = .edit    
    var selectedSpecialTileType: SpecialTileType? = .wall
    var selectedTile: Tile? = nil
    
    var levelEditorBoundingBox: Rect!
    
    var levelRenderer: LevelRenderer!
    var specialTileSelector: SpecialTileSelector!
    var levelEditorInformation: LevelEditorInformation!
    var levelEditorInterface: LevelEditorInterface!
    var errorConsole: ErrorConsole!

    var currentDrag: Set<LevelPoint> = []

    private var updateRender = true

    init() {
        super.init(name: "LevelEditor")
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("scene of type EditScene is required for LevelEditor")
        }
        return editScene
    }

    func controlPanel() -> ControlPanel {
        let interactionLayer = editScene().interactionLayer
        return interactionLayer.controlPanel
    }

    func background() -> EditBackground {
        let backgroundLayer = editScene().backgroundLayer
        return backgroundLayer.background
    }

    func update() {
        levelRenderer.update()
        specialTileSelector.update()
        levelEditorInformation.update()
        levelEditorInterface.update()
        errorConsole.update()
    }

    func findTileClicked(globalLocation: Point) -> Tile? {
        for faceIndex in 0 ..< Face.allCases.count {
            if levelRenderer.faceBoundingBoxs[faceIndex].containment(target: globalLocation).contains(.containedFully) {
                let relativePoint = globalLocation - levelRenderer.faceBoundingBoxs[faceIndex].topLeft
                let xIndex = relativePoint.x / levelRenderer.tileSize.width
                let yIndex = relativePoint.y / levelRenderer.tileSize.height
                return levelRenderer.level.faceLevels[faceIndex].tiles[xIndex][yIndex]
            }
        }
        return nil
    }

    func clickTile(tile: Tile) {
        switch mode {
        case .edit:
            guard tile.point != levelRenderer.level.startingPosition else {
                // Throw to Error Console
                errorConsole.throwError("Cannot change the state of the level's starting position.")
                return                          
            }
            if tile.specialTileType == selectedSpecialTileType {
                levelRenderer.setSpecialTileType(levelPoint: tile.point, specialTileType: nil)                
            } else {
                levelRenderer.setSpecialTileType(levelPoint: tile.point, specialTileType: selectedSpecialTileType)
            }
        case .select:
            selectedTile = tile
            levelRenderer.update()
        case .erase:
            levelRenderer.setSpecialTileType(levelPoint: tile.point, specialTileType: nil)
        }
        levelEditorInformation.update()
    }    
    
    func onEntityMouseDown(globalLocation: Point) {        
        if levelRenderer.levelStaged, let tile = findTileClicked(globalLocation: globalLocation) {            
            clickTile(tile: tile)
            currentDrag.insert(tile.point)
        }        
    }

    func onEntityMouseDrag(globalLocation: Point, movement: Point) {
        // Only perform a click if there is a level staged, a tile was found, and it wasn't already clicked on the current drag
        if levelRenderer.levelStaged, let tile = findTileClicked(globalLocation: globalLocation),
           !currentDrag.contains(tile.point) {
            currentDrag.insert(tile.point)
            clickTile(tile: tile)
        }        
    }

    func onEntityMouseUp(globalLocation: Point) {
        currentDrag = []
    }

    func selectSpecialTileType(_ specialTileType: SpecialTileType) {
        selectedSpecialTileType = specialTileType
    }
    func setMode(_ mode: LevelEditorMode) {
        self.mode = mode
        levelEditorInformation.update()
    }

    override func boundingRect() -> Rect {
        return levelEditorBoundingBox
    }
    
    override func setup(canvasSize: Size, canvas: Canvas) {
        // Accounts for 5px Padding
        levelEditorBoundingBox = Rect(topLeft: Point(x: (canvasSize.width / 4) + 5, y: 5),
                                       size: Size(width: (canvasSize.width * 3 / 4) - 10, height: canvasSize.height - 10))

        // Setup LevelRenderer
        let levelRendererFaceSize = (levelEditorBoundingBox.size.width / 3) > (levelEditorBoundingBox.size.height / 4) ?
          Size(width: levelEditorBoundingBox.size.height / 4, height: levelEditorBoundingBox.size.height / 4) :
          Size(width: levelEditorBoundingBox.size.width / 3, height: levelEditorBoundingBox.size.width / 3)
        var levelRendererBoundingBox = Rect(size: Size(width: levelRendererFaceSize.width * 3, height: levelRendererFaceSize.height * 4))
        levelRendererBoundingBox.center = levelEditorBoundingBox.center               
        levelRenderer = LevelRenderer(boundingBox: levelRendererBoundingBox, faceSize: levelRendererFaceSize)
        levelRenderer.claimAsEditor(levelEditor: self)

        // Setup SpecialTileSelector
        var specialTileSelectorBoundingBox = Rect()
        specialTileSelectorBoundingBox.topLeft = levelEditorBoundingBox.topLeft
        specialTileSelectorBoundingBox.bottom = levelRenderer.faceBoundingBoxs[Face.back.rawValue].bottomLeft.y - 5
        specialTileSelectorBoundingBox.right = levelRenderer.faceBoundingBoxs[Face.back.rawValue].bottomLeft.x - 5
        specialTileSelector = SpecialTileSelector(boundingBox: specialTileSelectorBoundingBox)

        // Setup LevelEditorInformation
        var levelEditorInformationBoundingBox = Rect()
        levelEditorInformationBoundingBox.topRight = levelEditorBoundingBox.topRight
        levelEditorInformationBoundingBox.bottom = levelRenderer.faceBoundingBoxs[Face.back.rawValue].bottomRight.y - 5
        levelEditorInformationBoundingBox.left = levelRenderer.faceBoundingBoxs[Face.back.rawValue].bottomRight.x + 5
        levelEditorInformation = LevelEditorInformation(boundingBox: levelEditorInformationBoundingBox)

        // Setup LevelEditorInterface
        var levelEditorInterfaceBoundingBox = Rect()
        levelEditorInterfaceBoundingBox.bottomLeft = levelEditorBoundingBox.bottomLeft
        levelEditorInterfaceBoundingBox.top = levelRenderer.faceBoundingBoxs[Face.top.rawValue].bottomLeft.y + 5
        levelEditorInterfaceBoundingBox.right = levelRenderer.faceBoundingBoxs[Face.top.rawValue].bottomLeft.x - 5
        levelEditorInterface = LevelEditorInterface(boundingBox: levelEditorInterfaceBoundingBox)

        // Setup Error Console
        var errorConsoleBoundingBox = Rect()
        errorConsoleBoundingBox.bottomRight = levelEditorBoundingBox.bottomRight
        errorConsoleBoundingBox.top = levelRenderer.faceBoundingBoxs[Face.top.rawValue].bottomRight.y + 5
        errorConsoleBoundingBox.left = levelRenderer.faceBoundingBoxs[Face.top.rawValue].bottomRight.x + 5
        errorConsole = ErrorConsole(boundingBox: errorConsoleBoundingBox)
        
        // Layer
        layer.insert(entity: levelRenderer, at: .behind(object: self))
        layer.insert(entity: specialTileSelector, at: .behind(object: self))
        layer.insert(entity: levelEditorInformation, at: .behind(object: self))
        layer.insert(entity: levelEditorInterface, at: .behind(object: self))
        layer.insert(entity: errorConsole, at: .behind(object: self))
        
        
        // Scene

        // Dispatcher
        dispatcher.registerEntityMouseDownHandler(handler: self)        
        dispatcher.registerEntityMouseDragHandler(handler: self)
        dispatcher.registerEntityMouseUpHandler(handler: self)
    }
        

    override func render(canvas: Canvas) {
        if !levelRenderer.levelStaged {
            let loadText = Text(location: levelRenderer.faceBoundingBoxs[Face.top.rawValue].center, text: "Please Load a Level.",
                                fillMode: .fillAndStroke)
            loadText.font = "30pt Arial"
            loadText.alignment = .center
            loadText.baseline = .middle
            canvas.render(FillStyle(color: Color(.black)), StrokeStyle(color: Color(.black)), LineWidth(width: 1))
            canvas.render(loadText)            
        }

        if updateRender {
            update()
            updateRender = false
        }
    }    

    override func teardown() {
        dispatcher.unregisterEntityMouseDownHandler(handler: self)
        dispatcher.unregisterEntityMouseDragHandler(handler: self)
        dispatcher.unregisterEntityMouseUpHandler(handler: self)
    }
}


import Scenes
import Igis
import LevelGeneration

class LevelEditor: RenderableEntity, MouseDownHandler {

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

    private var updateRender = true

    init() {
        super.init(name: "LevelEditor")
    }

    func mainScene() -> MainScene {
        guard let mainScene = scene as? MainScene else {
            fatalError("mainScene of type MainScene is required")
        }
        return mainScene
    }

    func controlPanel() -> ControlPanel {
        let interactionLayer = mainScene().interactionLayer
        return interactionLayer.controlPanel
    }

    func background() -> Background {
        let backgroundLayer = mainScene().backgroundLayer
        return backgroundLayer.background
    }

    func update() {
        levelRenderer.update()
        specialTileSelector.update()
        levelEditorInformation.update()
        levelEditorInterface.update()
        errorConsole.update()
    }

    func onMouseDown(globalLocation: Point) {        
        if levelEditorBoundingBox.containment(target: globalLocation).contains(.containedFully) {

            func tileClicked() -> Tile? {
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

            if levelRenderer.levelStaged, let clickedTile = tileClicked() {
                switch mode {
                case .edit:
                    guard clickedTile.point != levelRenderer.level.startingPosition else {
                        // Throw to Error Console
                        errorConsole.throwError("Cannot change the state of the level's starting position.")
                        return                          
                    }
                    if clickedTile.specialTileType == selectedSpecialTileType {
                        levelRenderer.setSpecialTileType(levelPoint: clickedTile.point, specialTileType: nil)                
                    } else {
                        levelRenderer.setSpecialTileType(levelPoint: clickedTile.point, specialTileType: selectedSpecialTileType)
                    }
                case .select:
                    selectedTile = clickedTile
                    levelRenderer.update()
                case .erase:
                    levelRenderer.setSpecialTileType(levelPoint: clickedTile.point, specialTileType: nil)
                }
                levelEditorInformation.update()                    
            }
            
            
        }
    }

    func selectSpecialTileType(_ specialTileType: SpecialTileType) {
        selectedSpecialTileType = specialTileType
    }
    func setMode(_ mode: LevelEditorMode) {
        self.mode = mode
        levelEditorInformation.update()
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
        layer.insert(entity: levelRenderer, at: .front)
        layer.insert(entity: specialTileSelector, at: .front)
        layer.insert(entity: levelEditorInformation, at: .front)
        layer.insert(entity: levelEditorInterface, at: .front)
        layer.insert(entity: errorConsole, at: .front)
        // Scene

        // Dispatcher
        dispatcher.registerMouseDownHandler(handler: self)        
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
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}


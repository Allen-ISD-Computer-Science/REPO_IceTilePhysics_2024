import Scenes
import Igis
import LevelGeneration

class LevelEditorInterface: RenderableEntity, MouseDownHandler {

    let boundingBox: Rect
    private var updateRender = false

    // In order of LevelEditor.LevelEditorMode.allCases
    var modeRectButtons = [Rect]()
    var directionWheel: DirectionWheel!
    var setStartingPositionRectButton: Rect!
    var playTestRectButton: Rect!
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
        super.init(name: "LevelEditorInterface")
    }

    func update() {
        updateRender = true
        directionWheel.update()
    }

    func shellDirector() -> ShellDirector {
        guard let shellDirector = director as? ShellDirector else {
            fatalError("director is required to be of type ShellDirector for PlayInteractionLayer.")
        }
        return shellDirector
    }
    
    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("scene is required to be of type EditScene for LevelEditorInterface.")
        }
        return editScene        
    }

    func levelEditor() -> LevelEditor {
        return editScene().interactionLayer.levelEditor
    }

    func onMouseDown(globalLocation: Point) {
        if boundingBox.containment(target: globalLocation).contains(.containedFully) {
            for modeRectButtonIndex in 0 ..< modeRectButtons.count {
                if modeRectButtons[modeRectButtonIndex].containment(target: globalLocation).contains(.containedFully) {
                    switch modeRectButtonIndex {
                    case 0: levelEditor().setMode(.edit)
                    case 1: levelEditor().setMode(.select)
                    case 2: levelEditor().setMode(.erase)
                    default: fatalError("Unexpected index greater than \(modeRectButtons.count)")
                    }
                    levelEditor().update()
                    return
                }
            }
            if setStartingPositionRectButton.containment(target: globalLocation).contains(.containedFully) {
                guard let selectedTilePoint = levelEditor().selectedTile?.point else {
                    // Throw to Error Console
                    levelEditor().errorConsole.throwError("Must select a tile before setting starting position.")
                    return
                }
                guard levelEditor().levelRenderer.level.faceLevels[selectedTilePoint.face.rawValue].tiles[selectedTilePoint.x][selectedTilePoint.y].tileState == .critical else {
                    // Throw to Error Console
                    levelEditor().errorConsole.throwError("Selected tile must be critical to set starting position.")
                    return
                }                    
                levelEditor().levelRenderer.level.startingPosition = selectedTilePoint
                levelEditor().levelRenderer.update()
                return
            }
            if playTestRectButton.containment(target: globalLocation).contains(.containedFully) {
                shellDirector().play(level: levelEditor().levelRenderer.level.emptyLevel())
                director.transitionToNextScene()
            }
        }
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Setup ModeRectButtons
        let modeCount = LevelEditor.LevelEditorMode.allCases.count
        let modeButtonSize = Size(width: (boundingBox.width - 10) / modeCount, height: 50)            
        for modeIndex in 0 ..< modeCount {
            let modeRect = Rect(topLeft: boundingBox.topLeft +
                                  Point(x: 5, y: 5) + Point(x: modeIndex * modeButtonSize.width, y: 0),
                                size: modeButtonSize)                
            modeRectButtons.append(modeRect)
        }

        // Setup Direction Wheel
        let maxDirectionWheelWidth = boundingBox.size.width * 2 / 3 - 10
        let maxDirectionWheelHeight = boundingBox.size.height - 65
        let directionWheelSize = maxDirectionWheelWidth > maxDirectionWheelHeight ? maxDirectionWheelHeight : maxDirectionWheelWidth
        var directionWheelBoundingBox = Rect(size: Size(width: directionWheelSize, height: directionWheelSize))
        directionWheelBoundingBox.topRight = boundingBox.topRight + Point(x: -5, y: modeButtonSize.height + 10)
        directionWheel = DirectionWheel(boundingBox: directionWheelBoundingBox)
        
        // Setup Set Starting Position Rect Button
        setStartingPositionRectButton = Rect(topLeft: boundingBox.topLeft + Point(x: 5, y: 60), size: Size(width: boundingBox.size.width - directionWheelSize - 15, height: 50))

        // Setup Play Test Rect Button
        playTestRectButton = Rect(topLeft: setStartingPositionRectButton.bottomLeft + Point(x: 0, y: 5), size: setStartingPositionRectButton.size)

        // Layer
        layer.insert(entity: directionWheel, at: .front)
        
        // Dispatcher
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updateRender {            
            // Render Bounding Box Rectangle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

            // Select Mode Buttons
            for modeIndex in 0 ..< modeRectButtons.count {
                let mode = LevelEditor.LevelEditorMode.allCases[modeIndex]
                let modeText = Text(location: modeRectButtons[modeIndex].center,
                                    text: mode.rawValue,
                                    fillMode: .fill)
                modeText.font = "20pt Arial"
                modeText.alignment = .center
                modeText.baseline = .middle
                canvas.render(FillStyle(color: Color(.black)), modeText)
                if levelEditor().mode == mode {
                    canvas.render(StrokeStyle(color: Color(.red)), LineWidth(width: 2))
                } else {
                    canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1))
                }
                canvas.render(Rectangle(rect: modeRectButtons[modeIndex], fillMode: .stroke))                
            }
            let setStartingPositionText = Text(location: setStartingPositionRectButton.center,
                                               text: "Set Starting Position",
                                               fillMode: .fill)
            setStartingPositionText.font = "12pt Arial"
            setStartingPositionText.alignment = .center
            setStartingPositionText.baseline = .middle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1), Rectangle(rect: setStartingPositionRectButton, fillMode: .stroke),
                          FillStyle(color: Color(.black)), setStartingPositionText)

            let playTestText = Text(location: playTestRectButton.center,
                                    text: "Play Test",
                                    fillMode: .fill)
            playTestText.font = "12pt Arial"
            playTestText.alignment = .center
            playTestText.baseline = .middle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1), Rectangle(rect: playTestRectButton, fillMode: .stroke),
                          FillStyle(color: Color(.black)), playTestText)

            updateRender = false
        }
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
    
}                          

import Scenes
import Igis
import LevelGeneration

class SpecialTileSelector: RenderableEntity, MouseDownHandler {
    
    let boundingBox: Rect    
    private var updateRender = false

    // Lists follow SpecialTileType encoding behavior with respective Int as Index, .wall = 1, .directionShift = 2, .portal = 3, etc.
    static let latestSpecialTile = "portal"
    static let specialTileColors = [Color(.black), Color(.orange), Color(.lightblue)]
    static let specialTileLabels = ["wall", "directionShift", "portal"]
    var specialTileButtonRects = [Rect]()

    var directionShiftPath = Path()

    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
        super.init(name: "SpecialTileSelector")
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("scene is required to be of type EditScene for SpecialTileSelector.")
        }
        return editScene
    }

    func levelEditor() -> LevelEditor {
        return editScene().interactionLayer.levelEditor
    }

    func update() {
        updateRender = true
    }

    func onMouseDown(globalLocation: Point) {
        if boundingBox.containment(target: globalLocation).contains(.containedFully) {
            for specialTileIndex in 0 ..< specialTileButtonRects.count {
                if specialTileButtonRects[specialTileIndex].containment(target: globalLocation).contains(.containedFully) {
                    switch specialTileIndex + 1 {
                    case 1: levelEditor().selectSpecialTileType(.wall)
                    case 2:
                        guard let directionPair = levelEditor().levelEditorInterface.directionWheel.directionPair() else {
                            levelEditor().errorConsole.throwError("Must select a valid direction pair prior to placing a direction shift.")
                            return
                        }
                        levelEditor().selectSpecialTileType(.directionShift(pair: directionPair))
                        directionShiftPath = levelEditor().levelRenderer.directionShiftPath(directionPair: directionPair,
                                                                                            tileRect: specialTileButtonRects[specialTileIndex])
                    case 3:
                        guard let destination = levelEditor().selectedTile?.point else {
                            // Throw to error console
                            levelEditor().errorConsole.throwError("Must select a tile prior to placing a portal.")
                            return
                        }
                        levelEditor().selectSpecialTileType(.portal(to: destination))
                    default: fatalError("Latest supported special tile is \(SpecialTileSelector.latestSpecialTile).")
                    }
                    levelEditor().setMode(.edit)
                    levelEditor().update()
                }
            }
        }
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        let sideLength = (boundingBox.size.height - (5 * 4)) / 3
        let buttonRectSize = Size(width: sideLength, height: sideLength)
        let wallButtonRect = Rect(topLeft: boundingBox.topLeft + Point(x: 5, y: 5), size: buttonRectSize)
        specialTileButtonRects.append(wallButtonRect)
        let directionShiftButtonRect = Rect(topLeft: wallButtonRect.bottomLeft + Point(x: 0, y: 5), size: buttonRectSize)
        specialTileButtonRects.append(directionShiftButtonRect)
        let portalButtonRect = Rect(topLeft: directionShiftButtonRect.bottomLeft + Point(x: 0, y: 5), size: buttonRectSize)
        specialTileButtonRects.append(portalButtonRect)

        // Dispatcher        
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updateRender {
            // Render BoundingBox rectangle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

            for specialTileIndex in 0 ..< SpecialTileSelector.specialTileColors.count {
                canvas.render(FillStyle(color: SpecialTileSelector.specialTileColors[specialTileIndex]),
                              Rectangle(rect: specialTileButtonRects[specialTileIndex], fillMode: .fillAndStroke))
                let specialTileText = Text(location: Point(x: specialTileButtonRects[specialTileIndex].right + 5,
                                                           y: specialTileButtonRects[specialTileIndex].centerY),
                                           text: SpecialTileSelector.specialTileLabels[specialTileIndex],
                                           fillMode: .fill)
                specialTileText.font = "24pt Arial"
                specialTileText.alignment = .left
                specialTileText.baseline = .middle
                canvas.render(FillStyle(color: Color(.black)), specialTileText)
            }

            canvas.render(directionShiftPath)
            updateRender = false
        }
        
    }

    override func teardown() {        
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
    
    
}

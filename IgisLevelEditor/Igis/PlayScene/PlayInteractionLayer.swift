import Scenes
import ScenesControls
import Igis
import LevelGeneration

class PlayInteractionLayer: Layer, KeyDownHandler {

    var player: Player!
    
    init() {
        super.init(name: "PlayInteraction")

        let doneButton = Button(labelString: "Done", topLeft: Point(x: 5, y: 5))
        doneButton.clickHandler = onDoneButtonClickHandler
        insert(entity: doneButton, at: .front)

        let incrementRotationCount = Button(labelString: "Rotate", topLeft: Point(x: 100, y: 5))
        incrementRotationCount.clickHandler = onIncrementRotationCountClickHandler
        insert(entity: incrementRotationCount, at: .front)

        let setSingleFaceRenderModeButton = Button(labelString: "Set Single Face Mode", topLeft: Point(x: 5, y: 35))
        setSingleFaceRenderModeButton.clickHandler = onSetSingleFaceRenderModeButtonClickHandler
        insert(entity: setSingleFaceRenderModeButton, at: .front)

        let setFullLevelRenderModeButton = Button(labelString: "Set Full Level Mode", topLeft: Point(x: 5, y: 70))
        setFullLevelRenderModeButton.clickHandler = onSetFullLevelRenderModeButtonClickHandler
        insert(entity: setFullLevelRenderModeButton, at: .front)

        let skipLevelButton = Button(labelString: "Skip Level", topLeft: Point(x: 5, y: 105))
        skipLevelButton.clickHandler = onSkipLevelButtonClickHandler
        insert(entity: skipLevelButton, at: .front)

        let randomizeColorButton = Button(labelString: "Randomize Color", topLeft: Point(x: 5, y: 140))
        randomizeColorButton.clickHandler = onRandomizeColorButtonClickHandler
        insert(entity: randomizeColorButton, at: .front)
    }

    func onDoneButtonClickHandler(control: Control, localLocation: Point) {
        playScene().level.resetLevel()
        // print(playScene().level.faceLevels)
        shellDirector().edit(fileName: playScene().fileName, level: playScene().level)
        
        director.transitionToNextScene()
    }
    func onSetSingleFaceRenderModeButtonClickHandler(control: Control, localLocation: Point) {
        playScene().backgroundLayer.background.levelRenderer.setSingleFaceRenderMode(face: player.location.face, rotations: 0)
        playScene().backgroundLayer.background.update()
    }
    func onSetFullLevelRenderModeButtonClickHandler(control: Control, localLocation: Point) {
        playScene().backgroundLayer.background.levelRenderer.setFullLevelRenderMode()
        playScene().backgroundLayer.background.update()
    }
    func onSkipLevelButtonClickHandler(control: Control, localLocation: Point) {
        playScene().enqueueNextLevel()
    }
    func onRandomizeColorButtonClickHandler(control: Control, localLocation: Point) {
        playScene().backgroundLayer.background.randomizePaintColor()
        playScene().backgroundLayer.background.update()
    }
    func onIncrementRotationCountClickHandler(control: Control, localLocation: Point) {
        let levelRenderer = playScene().backgroundLayer.background.levelRenderer!
        if case .singleFace(let currentFace, let rotations) = levelRenderer.renderMode {
            levelRenderer.setSingleFaceRenderMode(face: currentFace, rotations: (rotations + 1) % 4)
        }
    }

    
    func playScene() -> PlayScene {
        guard let playScene = scene as? PlayScene else {
            fatalError("scene is required to be of type PlayScene for PlayInteractionLayer.")
        }
        return playScene
    }

    func shellDirector() -> ShellDirector {
        guard let shellDirector = director as? ShellDirector else {
            fatalError("director is required to be of type ShellDirector for PlayInteractionLayer.")
        }
        return shellDirector
    }

    func onKeyDown(key: String, code: String, ctrlKey: Bool, shiftKey: Bool, altKey: Bool, metaKey: Bool) {
        let arrowKeyToDirection: [String:Direction] = [
          "ArrowUp":.up,
          "ArrowDown":.down,
          "ArrowLeft":.left,
          "ArrowRight":.right
        ]
        if let direction = arrowKeyToDirection[key], player.currentSlide == nil {
            if case .singleFace(_, let rotations) = playScene().backgroundLayer.background.levelRenderer.renderMode {
                player.slide(direction.rotatedClockwise(times: 4 - (rotations % 4)))
            } else {
                player.slide(direction)
            }            
        }
    }

    override func preSetup(canvasSize: Size, canvas: Canvas) {
        // Setup Player
        player = Player(startingLocation: playScene().backgroundLayer.background.levelRenderer.level.startingPosition,
                        levelGraph: playScene().backgroundLayer.background.levelRenderer.level.levelGraph)
        insert(entity: player, at: .front)
        dispatcher.registerKeyDownHandler(handler: self)
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
    }
}

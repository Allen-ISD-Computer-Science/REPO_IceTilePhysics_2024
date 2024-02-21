import Scenes
import ScenesControls
import Igis
import LevelGeneration

class PlayInteractionLayer: Layer, KeyDownHandler {

    var player: Player!
    
    init() {
        super.init(name: "PlayInteraction")

        let doneButton = Button(labelString: "Done")
        doneButton.clickHandler = onDoneButtonClickHandler
        insert(entity: doneButton, at: .front)
    }

    func onDoneButtonClickHandler(control: Control, localLocation: Point) {
        playScene().level.resetLevel()
        shellDirector().edit(fileName: playScene().fileName, level: playScene().level)
        director.transitionToNextScene()
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
            player.slide(direction)
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

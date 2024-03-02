import Scenes
import LevelGeneration

class PlayScene: Scene {

    var level: Level
    var levelList: [Level]? = nil
    var fileName: String? = nil
    var fileNameList: [String]? = nil

    let interactionLayer = PlayInteractionLayer()
    let backgroundLayer = PlayBackgroundLayer()

    init(fileName: String? = nil, level: Level) {
        self.level = level
        self.fileName = fileName
        super.init(name: "PlayScene")

        insert(layer: interactionLayer, at: .front)
        insert(layer: backgroundLayer, at: .back)        
    }

    init(fileNameList: [String]? = nil, levelList: [Level]) {
        guard !levelList.isEmpty else {
            fatalError("Cannot initialize PlayScene with empty LevelList")
        }
        self.fileNameList = fileNameList
        self.fileName = self.fileNameList?.removeFirst()
        self.levelList = levelList
        self.level = self.levelList!.removeFirst()
        super.init(name: "PlayScene")

        insert(layer: interactionLayer, at: .front)
        insert(layer: backgroundLayer, at: .back)
    }

    func shellDirector() -> ShellDirector {
        guard let shellDirector = director as? ShellDirector else {
            fatalError("director is required to be of type ShellDirector for PlayScene.")
        }
        return shellDirector
    }

    func enqueueNextLevel() {
        guard levelList != nil else {
            return
        }
        if levelList!.isEmpty {
            level.resetLevel()
            shellDirector().edit(fileName: fileName, level: level)
            director.transitionToNextScene()
        } else {
            level = levelList!.removeFirst()
            fileName = fileNameList?.removeFirst()
            backgroundLayer.background.totalInactive = backgroundLayer.background.calculateTotalInactive(level: level)
            interactionLayer.player.levelGraph = level.levelGraph
            interactionLayer.player.location = level.startingPosition
            backgroundLayer.background.levelRenderer.stageLevel(level: level)
            backgroundLayer.background.levelRenderer.playerLocation = level.startingPosition
            if case .singleFace = backgroundLayer.background.levelRenderer.renderMode {
                backgroundLayer.background.levelRenderer.setSingleFaceRenderMode(face: level.startingPosition.face)
            }
        }
    }
}

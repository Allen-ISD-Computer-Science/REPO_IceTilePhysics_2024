import Scenes
import LevelGeneration

class PlayScene: Scene {

    var level: Level
    let fileName: String?

    let interactionLayer = PlayInteractionLayer()
    let backgroundLayer = PlayBackgroundLayer()

    init(fileName: String? = nil, level: Level) {
        self.level = level
        self.fileName = fileName
        super.init(name: "PlayScene")

        insert(layer: interactionLayer, at: .front)
        insert(layer: backgroundLayer, at: .back)        
    }
    
}

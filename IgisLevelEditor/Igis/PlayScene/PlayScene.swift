import Scenes
import LevelGeneration

class PlayScene: Scene {

    var level: Level

    let interactionLayer = PlayInteractionLayer()
    let backgroundLayer = PlayBackgroundLayer()

    init(level: Level) {
        self.level = level
        super.init(name: "PlayScene")

        insert(layer: interactionLayer, at: .front)
        insert(layer: backgroundLayer, at: .back)        
    }
    
}

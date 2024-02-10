import Scenes
import Igis
import LevelGeneration

class EditScene: Scene {

    let initLevel: Level?
    let interactionLayer = EditInteractionLayer()
    let backgroundLayer = EditBackgroundLayer()

    init(level: Level? = nil) {
        self.initLevel = level
        super.init(name: "EditScene")

        insert(layer:interactionLayer, at:.front)
        insert(layer:backgroundLayer, at:.back)
    }

    override func postSetup(canvasSize: Size, canvas: Canvas) {
        if initLevel != nil {
            interactionLayer.levelEditor.levelRenderer.stageLevel(level: initLevel!)
        }
    }
    
}

import Scenes
import ScenesControls
import Igis
import LevelGeneration

class EditInteractionLayer: Layer {

    var levelEditor: LevelEditor
    var controlPanel: ControlPanel

    init() {
                
        self.levelEditor = LevelEditor()
        self.controlPanel = ControlPanel()

        super.init(name: "EditInteraction")

        insert(entity: levelEditor, at: .front)
        insert(entity: controlPanel, at: .behind(object: levelEditor))
    }
}

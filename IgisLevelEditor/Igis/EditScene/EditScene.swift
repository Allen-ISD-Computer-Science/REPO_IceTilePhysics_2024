import Scenes
import Igis
import LevelGeneration

class EditScene: Scene {

    let initLevel: Level?
    let initFileName: String?
    let interactionLayer = EditInteractionLayer()
    let backgroundLayer = EditBackgroundLayer()

    init(fileName: String? = nil, level: Level? = nil) {
        self.initLevel = level
        self.initFileName = fileName        
        super.init(name: "EditScene")

        insert(layer:interactionLayer, at:.front)
        insert(layer:backgroundLayer, at:.back)
    }

    override func postSetup(canvasSize: Size, canvas: Canvas) {
        if initLevel != nil {
            interactionLayer.levelEditor.levelRenderer.stageLevel(level: initLevel!)
        }
        if initFileName != nil {
            interactionLayer.controlPanel.fileViewer.activeFileIndex = interactionLayer.controlPanel.fileViewer.fileNames.firstIndex(where: { $0 as String == initFileName! })
            interactionLayer.controlPanel.update()
        }
    }
    
}

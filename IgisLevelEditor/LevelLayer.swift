import Igis
import Scenes
import ScenesControls
import LevelGeneration

class LevelLayer: Layer {

    let renderableLevel: RenderableLevel
    let levelFileManager: LevelFileManager

    init() {
        self.levelFileManager = LevelFileManager.shared

        guard let level = levelFileManager.initializeLevel(from: "./test.lvl") else {
            fatalError("failed to load level from file")
        }
        self.renderableLevel = RenderableLevel(level: level)
        super.init(name:"Level")

        let saveFileButton = Button(name:"SaveToFile", labelString:"Save to File", topLeft: Point(x: 10, y: 10))
        saveFileButton.clickHandler = onSaveFileClickHandler
        insert(entity:saveFileButton, at: .front)
        insert(entity:renderableLevel, at: .back)
    }

    func onSaveFileClickHandler(control: Control, localLocation: Point) {
        guard let fileData = levelFileManager.encodeLVL(from: renderableLevel.level) else {
            print("Unable to encode Level")
            return
        }
        levelFileManager.write(path: "./test.lvl", content: fileData)
    }
}

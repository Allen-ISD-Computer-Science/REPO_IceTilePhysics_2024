import Igis
import Scenes
import ScenesControls
import LevelGeneration

class LevelLayer: Layer, RenderableLevelDelegate {

    let renderableLevel: RenderableLevel
    let levelFileManager: LevelFileManager
    let textInputField: TextInputField

    init() {
        self.levelFileManager = LevelFileManager.shared

        guard let level = levelFileManager.initializeLevel(from: "./Levels/customLevel.lvl") else {
            fatalError("failed to load level from file")
        }
        self.renderableLevel = RenderableLevel(level: level)
        self.textInputField = TextInputField()
        super.init(name:"Level")

        let saveFileButton = Button(name:"SaveToFile", labelString:"Save to File", topLeft: Point(x: 10, y: 10))
        saveFileButton.clickHandler = onSaveFileClickHandler
        insert(entity:saveFileButton, at: .front)
        insert(entity:textInputField, at: .front)
        insert(entity:renderableLevel, at: .back)

        renderableLevel.delegate = self
        textInputField.onUpdateLevelRequested = { [weak self] in
            self?.updateLevel()
        }
    }

    func updateLevel() {
        renderableLevel.updateLevel()
    }

    func onSaveFileClickHandler(control: Control, localLocation: Point) {
        guard let fileData = levelFileManager.encodeLVL(from: renderableLevel.level) else {
            print("Unable to encode Level")
            return
        }
        levelFileManager.write(path: "./Levels/\(textInputField.text).lvl", content: fileData)
    }
}

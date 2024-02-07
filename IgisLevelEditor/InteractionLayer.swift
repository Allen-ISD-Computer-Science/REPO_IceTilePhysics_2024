import Scenes
import ScenesControls
import Igis
import LevelGeneration

class InteractionLayer: Layer {

    let levelFileManager = LevelFileManager.shared
    var fileInputField: TextInputField
    var sizeInputField: TextInputField
//    var levelList: LevelList
    var levelEditor: LevelEditor

    init() {
                
        let allowedFileKeys = {
            let lowerCaseCharacters = (Character("a").asciiValue!...Character("z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
            let upperCaseCharacters = (Character("A").asciiValue!...Character("Z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
            let numberCharacters = (0...9).map { String($0) }
            let specialCharacters = ["-", "_", "Backspace"]        
            return lowerCaseCharacters + upperCaseCharacters + numberCharacters + specialCharacters
        }()
        let countRestriction: (String) -> Bool = { $0.count <= 10 }
        self.fileInputField = TextInputField(boundingBoxTopLeft: Point(x: 10, y: 60), allowedKeys: allowedFileKeys, restrictions: [countRestriction])
        
        let allowedSizeKeys = {
            let numberCharacters = (0...9).map { String($0) }
            let specialCharacters = ["Backspace"]        
            return numberCharacters + specialCharacters
        }()
        let sizeRestriction: (String) -> Bool = {
            if let integer = Int($0), integer <= 15 {
                return true
            }
            return false
        }
        self.sizeInputField = TextInputField(boundingBoxTopLeft: Point(x: 10, y: 160), allowedKeys: allowedSizeKeys, restrictions: [sizeRestriction])

//        self.levelList = LevelList(boundingBox: Rect(topLeft: Point(x: 10, y: 220), size: Size(width: 200, height: 400)))
//        let levelFiles = try levelFileManager.fileManager.contentsOfDirectory(atPath: "./Levels")

        guard let level = levelFileManager.initializeLevel(from: "./Levels/test2.lvl") else {
            fatalError("failed to load level from file")
        }
        self.levelEditor = LevelEditor(level: level)

        super.init(name: "Interaction")
        
        insert(entity: fileInputField, at: .front)
        insert(entity: sizeInputField, at: .front)
//        insert(entity: levelList, at: .front)
        insert(entity: levelEditor, at: .back)

        let saveFileButton = Button(name:"SaveToFile", labelString:"Save to File", topLeft: Point(x: 10, y: 10))
        saveFileButton.clickHandler = onSaveFileClickHandler       
        insert(entity:saveFileButton, at: .front)

        let setSizeButton = Button(name:"SetSize", labelString:"Save Level Size", topLeft: Point(x: 10, y: 120))
        setSizeButton.clickHandler = onSetSizeClickHandler
        insert(entity:setSizeButton, at: .front)

        let editModeButton = Button(name:"EditMode", labelString:"Edit Mode", topLeft: Point(x: 10, y: 220))
        editModeButton.clickHandler = onEditButtonClickHandler
        insert(entity:editModeButton, at: .front)
        
        let selectionModeButton = Button(name:"SelectionMode", labelString:"Selection Mode", topLeft: Point(x: 10, y: 270))
        selectionModeButton.clickHandler = onSelectionButtonClickHandler
        insert(entity:selectionModeButton, at: .front)        
    }

    func onSaveFileClickHandler(control: Control, localLocation: Point) {
        guard levelEditor.level.solvable() else {
            print("Cannot save unsolvable level")
            return
        } 
        
        guard let fileData = levelFileManager.encodeLVL(from: levelEditor.level) else {
            print("Unable to encode Level")
            return
        }
        levelFileManager.write(path: "./Levels/\(fileInputField.text).lvl", content: fileData)            
    }

    func onSetSizeClickHandler(control: Control, localLocation: Point) {
        guard let edgeLength = Int(sizeInputField.text) else {
            fatalError("Failed to initialize an Integer from \(sizeInputField.text)")
        }
        guard edgeLength > 3 else {
            fatalError("edgeLength must be greater than 3")
        }
        let levelSize = LevelSize(edgeLength: edgeLength)
        let startingPosition = LevelPoint(face: .back, x: 1, y: 1)
        levelEditor.updateLevel(level: Level(levelSize: levelSize, startingPosition: startingPosition))
    }

    func onEditButtonClickHandler(control: Control, localLocation: Point) {
        levelEditor.setEditMode()
    }
    func onSelectionButtonClickHandler(control: Control, localLocation: Point) {
        levelEditor.setSelectionMode()
    }
}

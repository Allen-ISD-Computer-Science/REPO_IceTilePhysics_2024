import Scenes
import Igis
import LevelGeneration

class ControlPanel: RenderableEntity, MouseDownHandler, KeyDownHandler {

    let levelFileManager = LevelFileManager.shared
    
    var controlPanelBoundingBox: Rect!
    var setLevelSize: TextFieldButton!
    var saveFile: TextFieldButton!
    // fileViewer
    // levelRenderer

    init() {
        super.init(name: "ControlPanel")        
    }

    func mainScene() -> MainScene {
        guard let mainScene = scene as? MainScene else {
            fatalError("mainScene of type MainScene is required")
        }
        return mainScene
    }

    func levelEditor() -> LevelEditor {        
        let interactionLayer = mainScene().interactionLayer
        return interactionLayer.levelEditor
    }

    func background() -> Background {
        let backgroundLayer = mainScene().backgroundLayer
        return backgroundLayer.background
    }

    func onMouseDown(globalLocation: Point) {
        // Hit test with setLevelSize Button
        if setLevelSize.buttonBoundingBox.containment(target: globalLocation).contains(.containedFully) {
            guard let edgeLength = Int(setLevelSize.inputString) else {
                // Throw to Error Console
                print("Input must be of type Int")
                return
            }
            guard edgeLength >= 6 else {
                // Throw to Error Console
                print("Input must be >= 6.")
                return
            }
            levelEditor().levelRenderer.stageLevel(level: Level(levelSize: LevelSize(edgeLength: edgeLength),
                                                                startingPosition: LevelPoint(face: .back, x: 1, y: 1)))
            background().clear(levelEditor: true)
            levelEditor().update()
            return
        }
        // Hit test with saveFile Button
        if saveFile.buttonBoundingBox.containment(target: globalLocation).contains(.containedFully) {
            guard saveFile.inputString != saveFile.defaultString else {
                // Throw to Error Console
                print("Must provide file name.")
                return
            }
            guard let level = levelEditor().levelRenderer.level else {
                // Throw to Error Console
                print("Must load level before saving it to file.")
                return
            }
            guard level.solvable() else {
                // Throw to Error Console
                print("Cannot save unsolvable level")
                return
            }
            guard let fileData = levelFileManager.encodeLVL(from: levelEditor().levelRenderer.level) else {
                // Throw to Error Console
                print("Unable to encode Level")
                return
            }
            levelFileManager.write(path: "./Levels/\(saveFile.inputString).lvl", content: fileData)
        }
    }

    func onKeyDown(key: String, code: String, ctrlKey: Bool, shiftKey: Bool, altKey: Bool, metaKey: Bool) {

    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Define Control Panel Bounding Box
        controlPanelBoundingBox = Rect(topLeft: Point(x: 5, y: 5),
                                       size: Size(width: (canvasSize.width / 4) - 10, height: canvasSize.height - 10))

        // setLevelSize TextFieldButton
        let setSizeFieldAllowedKeys = {
            let numberCharacters = (0...9).map { String($0) }
            let specialCharacters = ["Backspace"]        
            return numberCharacters + specialCharacters
        }()
        let setSizeSizeRestriction: (String) -> Bool = {
            if let integer = Int($0), integer <= 15 {
                return true
            }
            return false
        }
        setLevelSize = TextFieldButton(boundingBox: Rect(topLeft: controlPanelBoundingBox.topLeft + Point(x: 0, y: 40),
                                                         size: Size(width: controlPanelBoundingBox.size.width, height: 50)),
                                       defaultString: "Enter Size",
                                       buttonLabel: "Set",
                                       allowedKeys: setSizeFieldAllowedKeys,
                                       restrictions: [setSizeSizeRestriction])
        let setLevelSizeUILabel = Text(location: Point(x: controlPanelBoundingBox.centerX, y: 20), text: "Set Level Size (Basic Seed, 6 - 15)", fillMode: .fill)
        setLevelSizeUILabel.font = "15pt Arial"
        setLevelSizeUILabel.alignment = .center
        setLevelSizeUILabel.baseline = .middle
        canvas.render(FillStyle(color: Color(.black)), setLevelSizeUILabel)

        // Save File TextFieldButton
        let saveFileAllowedKeys = {
            let lowerCaseCharacters = (Character("a").asciiValue!...Character("z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
            let upperCaseCharacters = (Character("A").asciiValue!...Character("Z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
            let numberCharacters = (0...9).map { String($0) }
            let specialCharacters = ["-", "_", "Backspace"]        
            return lowerCaseCharacters + upperCaseCharacters + numberCharacters + specialCharacters
        }()
        saveFile = TextFieldButton(boundingBox: Rect(topLeft: setLevelSize.boundingBox.topLeft +
                                                       Point(x: 0, y: setLevelSize.boundingBox.size.height + 45),
                                                     size: Size(width: controlPanelBoundingBox.size.width, height: 50)),
                                   defaultString: "Enter File Name",
                                   buttonLabel: "Save",
                                   allowedKeys: saveFileAllowedKeys)
        let saveFileUILabel = Text(location: Point(x: controlPanelBoundingBox.centerX, y: setLevelSize.boundingBox.bottom + 25),
                                   text: "Save Level To File", fillMode: .fill)
        saveFileUILabel.font = "15pt Arial"
        saveFileUILabel.alignment = .center
        saveFileUILabel.baseline = .middle
        canvas.render(FillStyle(color: Color(.black)), saveFileUILabel)
                                                                                                              
        
        // Layer
        layer.insert(entity: setLevelSize, at: .front)
        layer.insert(entity: saveFile, at: .front)
        // Scene

        // Dispatcher        
        dispatcher.registerMouseDownHandler(handler: self)
        dispatcher.registerKeyDownHandler(handler: self)
    }

    override func teardown() {
        // Dispatcher
        dispatcher.unregisterMouseDownHandler(handler: self)
        dispatcher.unregisterKeyDownHandler(handler: self)
    }
}

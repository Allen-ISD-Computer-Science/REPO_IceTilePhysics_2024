import Foundation
import Scenes
import Igis
import LevelGeneration

class ControlPanel: RenderableEntity, MouseDownHandler {

    let levelFileManager = LevelFileManager.shared    
    static let levelsPath = "./Levels/"
    
    var controlPanelBoundingBox: Rect!
    var setLevelSize: TextFieldButton!
    var saveFile: TextFieldButton!
    var fileViewer: FileViewer!
    var levelViewer: LevelRenderer!

    private var updateRender = true

    init() {
        super.init(name: "ControlPanel")        
    }

    func update() {
        updateRender = true
        fileViewer.update()
        levelViewer.update()
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("Scene of type EditScene is required for ControlPanel")
        }
        return editScene
    }

    func levelEditor() -> LevelEditor {        
        let interactionLayer = editScene().interactionLayer
        return interactionLayer.levelEditor
    }

    func background() -> EditBackground {
        let backgroundLayer = editScene().backgroundLayer
        return backgroundLayer.background
    }

    func onMouseDown(globalLocation: Point) {
        // Hit test with setLevelSize Button
        if setLevelSize.buttonBoundingBox.containment(target: globalLocation).contains(.containedFully) {
            guard let edgeLength = Int(setLevelSize.inputString) else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Input must be of type Int")
                return
            }
            guard edgeLength >= 6 else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Input must be >= 6.")
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
            guard saveFile.inputString != saveFile.defaultString && saveFile.inputString != "" else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Must provide file name.")
                return
            }
            guard let level = levelEditor().levelRenderer.level else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Must load level before saving it to file.")
                return
            }
            guard level.solvable() else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Cannot save unsolvable level")
                return
            }
            guard let fileData = levelFileManager.encodeLVL(from: levelEditor().levelRenderer.level) else {
                // Throw to Error Console
                levelEditor().errorConsole.throwError("Unable to encode Level")
                return
            }
            levelEditor().errorConsole.throwError(levelFileManager.write(path: "./Levels/\(saveFile.inputString).lvl", content: fileData))
            insertFilesIntoFileViewer()
            background().clear(controlPanel: true)            
            update()
        }
    }

    func insertFilesIntoFileViewer() {
        do {
            let levelFiles: [NSString] = try levelFileManager.fileManager.contentsOfDirectory(atPath: ControlPanel.levelsPath).sorted().map { $0 as NSString }
            var processedFileNames = [NSString]()
            var levels = [Level]()
            levelFiles.forEach {
                if let level = levelFileManager.initializeLevel(from: ControlPanel.levelsPath + ($0 as String)) {
                    processedFileNames.append($0)
                    levels.append(level)
                } else {
                    print("failed to generate level from \($0)")
                }
            }
            fileViewer.loadLevels(fileNames: processedFileNames, levels: levels)
            fileViewer.update()
        }
        catch {
            levelEditor().errorConsole.throwError("\(error)")
        }
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
                                                                                                              
        // FileViewer
        var fileViewerBoundingBox = Rect()
        fileViewerBoundingBox.topLeft = saveFile.boundingBox.bottomLeft + Point(x: 0, y: 5)
        fileViewerBoundingBox.right = controlPanelBoundingBox.topRight.x
        fileViewerBoundingBox.bottom = fileViewerBoundingBox.top +
          (controlPanelBoundingBox.bottom - fileViewerBoundingBox.top) * 5 / 12
        fileViewer = FileViewer(boundingBox: fileViewerBoundingBox)
        insertFilesIntoFileViewer()

        // Setup Level Viewer
        var levelViewerBoundingBox = Rect()
        levelViewerBoundingBox.topLeft = fileViewerBoundingBox.bottomLeft + Point(x: 0, y: 5)
        levelViewerBoundingBox.bottom = controlPanelBoundingBox.bottom
        levelViewerBoundingBox.right = controlPanelBoundingBox.right
        let levelViewerFaceSize = (levelViewerBoundingBox.size.width / 3) > (levelViewerBoundingBox.size.height / 4) ?
          Size(width: levelViewerBoundingBox.size.height / 4, height: levelViewerBoundingBox.size.height / 4) :
          Size(width: levelViewerBoundingBox.size.width / 3, height: levelViewerBoundingBox.size.width / 3)
        var levelBoundingBox = Rect(size: Size(width: levelViewerFaceSize.width * 3, height: levelViewerFaceSize.height * 4))
        levelBoundingBox.center = levelViewerBoundingBox.center
        levelViewer = LevelRenderer(boundingBox: levelBoundingBox, faceSize: levelViewerFaceSize)
        
        // Layer
        layer.insert(entity: setLevelSize, at: .behind(object: self))
        layer.insert(entity: saveFile, at: .behind(object: self))
        layer.insert(entity: fileViewer, at: .behind(object: self))
        layer.insert(entity: levelViewer, at: .behind(object: self))
        // Scene

        // Dispatcher        
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updateRender {
            
            let setLevelSizeUILabel = Text(location: Point(x: controlPanelBoundingBox.centerX, y: 20), text: "Set Level Size (Basic Seed, 6 - 15)", fillMode: .fill)
            setLevelSizeUILabel.font = "15pt Arial"
            setLevelSizeUILabel.alignment = .center
            setLevelSizeUILabel.baseline = .middle
            canvas.render(FillStyle(color: Color(.black)), setLevelSizeUILabel)

            let saveFileUILabel = Text(location: Point(x: controlPanelBoundingBox.centerX, y: setLevelSize.boundingBox.bottom + 25),
                                       text: "Save Level To File", fillMode: .fill)
            saveFileUILabel.font = "15pt Arial"
            saveFileUILabel.alignment = .center
            saveFileUILabel.baseline = .middle
            canvas.render(FillStyle(color: Color(.black)), saveFileUILabel)
            
            updateRender = false
        }
    }
    
    override func teardown() {
        // Dispatcher
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

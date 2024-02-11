import Scenes
import Igis
import LevelGeneration

class LevelEditorInformation: RenderableEntity {
    
    let boundingBox: Rect
    private var updateRender = false
    
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
        super.init(name: "LevelEditorInformation")
    }

    func update() {
        updateRender = true
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("editScene is required to be of type EditScene for LevelEditorInformation")
        }
        return editScene
    }

    func levelEditor() -> LevelEditor {
        return editScene().interactionLayer.levelEditor
    }

    func level() -> Level? {
        guard let level = levelEditor().levelRenderer.level else {
            return nil
        }
        return level
    }

    override func render(canvas: Canvas) {
        if updateRender {
            // Render Bounding Box Rectangle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

            let levelEditorModeText = Text(location: boundingBox.topLeft + Point(x: 5, y: 5),
                                           text: "Level Editor Mode: \(levelEditor().mode)",
                                           fillMode: .fill)
            levelEditorModeText.font = "24pt Arial"
            levelEditorModeText.alignment = .left
            levelEditorModeText.baseline = .top
            canvas.render(FillStyle(color: Color(.black)), levelEditorModeText)

            
            if let level = level() {
                let solvableText = Text(location: boundingBox.topLeft + Point(x: 5, y: 35),
                                        text: "Solvable: \(level.solvable())",
                                        fillMode: .fill)
                solvableText.font = "24pt Arial"
                solvableText.alignment = .left
                solvableText.baseline = .top
                canvas.render(FillStyle(color: Color(.black)), solvableText)
            }

            let specialTileTypeString: String
            if let selectedSpecialTileType = levelEditor().selectedSpecialTileType {
                switch selectedSpecialTileType {
                case .wall: specialTileTypeString = "wall"
                case .directionShift: specialTileTypeString = "directionShift"
                case .portal: specialTileTypeString = "portal"
                case .sticky: specialTileTypeString = "sticky"
                }
            } else {
                specialTileTypeString = "N/A"
            }
            let selectedSpecialTileTypeText = Text(location: boundingBox.topLeft + Point(x: 5, y: 65),
                                               text: "Selected Tile Type: " + specialTileTypeString,
                                               fillMode: .fill)            
            selectedSpecialTileTypeText.font = "24pt Arial"
            selectedSpecialTileTypeText.alignment = .left
            selectedSpecialTileTypeText.baseline = .top
            canvas.render(FillStyle(color: Color(.black)), selectedSpecialTileTypeText)
            
            let selectedTileString: String
            if let selectedTile = levelEditor().selectedTile {
                selectedTileString = selectedTile.point.description
            } else {
                selectedTileString = "N/A"
            }
            let selectedTileText = Text(location: boundingBox.topLeft + Point(x: 5, y: 95),
                                        text: "Selected Tile Point: " + selectedTileString,
                                        fillMode: .fill)
            selectedTileText.font = "12pt Arial"
            selectedTileText.alignment = .left
            selectedTileText.baseline = .top
            canvas.render(FillStyle(color: Color(.black)), selectedTileText)

            updateRender = false
        }
    }    
}

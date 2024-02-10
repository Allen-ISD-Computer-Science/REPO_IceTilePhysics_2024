import Scenes
import Igis

class EditBackground: RenderableEntity {

    var controlPanelRect: Rect!
    var levelEditorRect: Rect!
    var clearControlPanel = false
    var clearLevelEditor = false    

    init() {
        super.init(name: "Background")
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        controlPanelRect = Rect(size: Size(width: canvasSize.width / 4, height: canvasSize.height))
        levelEditorRect = Rect(topRight: Point(x: canvasSize.width, y: 0), size: Size(width: canvasSize.width * 3 / 4, height: canvasSize.height))
        canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1))
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: controlPanelRect, fillMode: .fillAndStroke))
        canvas.render(FillStyle(color: Color(.lightgray)), Rectangle(rect: levelEditorRect, fillMode: .fillAndStroke))
    }

    override func render(canvas: Canvas) {
        if clearControlPanel {
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1))
            canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: controlPanelRect, fillMode: .fillAndStroke))
            clearControlPanel = false            
        }
        if clearLevelEditor {
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1))
            canvas.render(FillStyle(color: Color(.lightgray)), Rectangle(rect: levelEditorRect, fillMode: .fillAndStroke))
            clearLevelEditor = false
        }
    }

    func clear(controlPanel: Bool = false, levelEditor: Bool = false) {
        clearControlPanel = controlPanel
        clearLevelEditor = levelEditor
    }
}

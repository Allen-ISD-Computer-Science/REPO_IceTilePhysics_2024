import Scenes
import Igis

class Background: RenderableEntity {

    var controlPanelRect: Rect = Rect()
    var levelEditorRect: Rect = Rect()

    init() {
        super.init(name: "Background")
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        controlPanelRect = Rect(size: Size(width: canvasSize.width / 4, height: canvasSize.height))
        levelEditorRect = Rect(topRight: Point(x: canvasSize.width, y: 0), size: Size(width: canvasSize.width * 3 / 4, height: canvasSize.height))
        canvas.render(StrokeStyle(color: Color(.black)))
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: controlPanelRect, fillMode: .fillAndStroke))
        canvas.render(FillStyle(color: Color(.lightgray)), Rectangle(rect: levelEditorRect, fillMode: .fillAndStroke))
    }    
}

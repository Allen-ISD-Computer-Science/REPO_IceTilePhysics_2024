import Igis
import Scenes
import LevelGeneration

class LevelList: RenderableEntity, MouseDownHandler {

    private var selected = ""
    public var labelToLevel = [String:Level]()

    let boundingBox: Rect
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
    }

    func onMouseDown(globalLocation: Point) {
        
    }

    override func setup(canvasSize: Size, canvas: Canvas) {        
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        canvas.render(FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

        if labelToLevel.keys.count > 0 {
            
        }
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

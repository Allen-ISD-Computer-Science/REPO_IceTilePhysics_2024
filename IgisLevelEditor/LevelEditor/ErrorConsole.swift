import Scenes
import Igis

class ErrorConsole: RenderableEntity {

    let boundingBox: Rect
    private var updateRender = false
    private var errors = [String]()

    var errorBoundingBoxSize: Size!
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
        super.init(name: "ErrorConsole")
    }

    func update() {
        updateRender = true        
    }

    func throwError(_ error: String) {
        errors.insert(error, at: 0)
        if errors.count > 10 {
            errors.removeSubrange(10...)
        }
        updateRender = true
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Setup Error Bounding Box
        errorBoundingBoxSize = Size(width: boundingBox.size.width, height: boundingBox.size.height / 10)        
    }

    override func render(canvas: Canvas) {
        if updateRender {
            // Render Bounding Box Rectangle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

            for errorIndex in 0 ..< errors.count {
                let errorRect = Rect(topLeft: boundingBox.topLeft + Point(x: 0, y: errorIndex * errorBoundingBoxSize.height),
                                     size: errorBoundingBoxSize)
                let errorText = Text(location: Point(x: errorRect.topLeft.x + 5, y: errorRect.centerY),
                                     text: errors[errorIndex],
                                     fillMode: .fill)
                errorText.font = "12pt Arial"
                errorText.alignment = .left
                errorText.baseline = .middle
                canvas.render(FillStyle(color: Color(.black)), errorText)                
            }

            updateRender = false
        }
    }
    
    
}

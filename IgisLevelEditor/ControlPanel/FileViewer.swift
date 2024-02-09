import Igis
import Scenes
import LevelGeneration

class FileViewer: RenderableEntity, MouseDownHandler {

    private var fileNameToLevels = [String:Level]()

    let boundingBox: Rect
    private var updateRender = false

    var fileNameRectSize: Size!
    var buttonRectSizeHeight: Int!

    var previousButtonRect: Rect!
    var nextButtonRect: Rect!

    var loadFileNameButtonRect: Rect!
    var loadLevelButtonRect: Rect!
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
    }

    func update() {
        updateRender = true
    }

    func loadLevels(_ fileNameToLevels: [String:Level]) {
        self.fileNameToLevels = fileNameToLevels
    }

    func onMouseDown(globalLocation: Point) {
        
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Setup File Name Rect Size
        fileNameRectSize = Size(width: boundingBox.width, height: boundingBox.height / 11)

        // Setup Button Rects
        buttonRectSizeHeight = boundingBox.height / 11 + boundingBox.height % 11

        previousButtonRect = Rect(bottomLeft: Point(x: boundingBox.left, y: boundingBox.bottom),
                                  size: Size(width: boundingBox.width / 8, height: buttonRectSizeHeight))
        nextButtonRect = Rect(bottomRight: Point(x: boundingBox.right, y: boundingBox.bottom),
                              size: Size(width: boundingBox.width / 8, height: buttonRectSizeHeight))
        loadFileNameButtonRect = Rect(topLeft: previousButtonRect.topRight,
                                      size: Size(width: boundingBox.width * 3 / 8, height: buttonRectSizeHeight))
        loadLevelButtonRect = Rect(topRight: nextButtonRect.topLeft,
                                   size: Size(width: boundingBox.width * 3 / 8, height: buttonRectSizeHeight))
        
        
        // Dispatcher
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updateRender {
            // Render Bounding Box Rectangle
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.white)), Rectangle(rect: boundingBox, fillMode: .fillAndStroke))

            canvas.render(Rectangle(rect: previousButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: nextButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: loadFileNameButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: loadLevelButtonRect, fillMode: .fillAndStroke))
            
            updateRender = false
        }
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

import Igis
import Scenes

class TextInputField: RenderableEntity, MouseDownHandler, KeyDownHandler {
    static let allowedKeys: [String] = {
        let lowerCaseCharacters = (Character("a").asciiValue!...Character("z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
        let upperCaseCharacters = (Character("A").asciiValue!...Character("Z").asciiValue!).map { String(Character(UnicodeScalar($0))) }
        let numberCharacters = (0...9).map { String($0) }
        let specialCharacters = ["-", "_", "Backspace"]        
        return lowerCaseCharacters + upperCaseCharacters + numberCharacters + specialCharacters
    }()
    public var text: String = ""
    
    private var editing = false
    
    static let boundingBoxMinWidth = 100
    static let characterHeight = 15
    static let characterWidth = 12
    static let boundingBoxTopLeft = Point(x: 10, y: 60)
    private var boundingBoxRect = Rect()

    var onUpdateLevelRequested: (() -> Void)?

    init() {
        super.init(name: "TextField")        
    }

    // Protocols
    // MouseDownHandler - onMouseDown
    func onMouseDown(globalLocation: Point) {
        if boundingBoxRect.containment(target: globalLocation).contains(.containedFully) {
            editing = true
        } else {
            editing = false
        }
    }
    
    // KeyDownHandler - onKeyDown
    func onKeyDown(key: String, code: String, ctrlKey: Bool, shiftKey: Bool, altKey: Bool, metaKey: Bool) {
        if editing {
            if TextInputField.allowedKeys.contains(key) {
                if key == "Backspace" {
                    if text.count > 0 {
                        text.removeLast()
                    }
                } else {
                    text.append(key)
                }
            } 
        }
    }
    
    // RenderableEntity - setup
    override func setup(canvasSize: Size, canvas: Canvas) {
        dispatcher.registerMouseDownHandler(handler: self)
        dispatcher.registerKeyDownHandler(handler: self)
        canvas.render(StrokeStyle(color: Color(.black)))
        updateBoundingBoxRect()
    }

    // RenderableEntity - render
    override func render(canvas: Canvas) {
        if editing {            
            canvas.render(FillStyle(color: Color(.yellow)))
            updateBoundingBoxRect()
        } else {
            canvas.render(FillStyle(color: Color(.white)))
        }
        let rectangle = Rectangle(rect: boundingBoxRect, fillMode: .fillAndStroke)
        let text = Text(location: Point(x: boundingBoxRect.topLeft.x + 5, y: boundingBoxRect.center.y), text: text, fillMode: .fillAndStroke)
        text.alignment = .left
        canvas.render(rectangle, FillStyle(color: Color(.black)), text)
    }
    // Render functions
    func updateBoundingBoxRect() {
        let newBoundingBoxWidth = {
            let boundingBoxWidth = text.count * TextInputField.characterWidth
            if boundingBoxWidth < 100 {
                return 100
            }
            return boundingBoxWidth
        }()
        if newBoundingBoxWidth < boundingBoxRect.size.width {
            onUpdateLevelRequested?()
        }
        boundingBoxRect = Rect(topLeft: TextInputField.boundingBoxTopLeft, size: Size(width: newBoundingBoxWidth, height: TextInputField.characterHeight * 3))
    }
    
    // RenderableEntity - teardown
    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
        dispatcher.unregisterKeyDownHandler(handler: self)
    }
    
}

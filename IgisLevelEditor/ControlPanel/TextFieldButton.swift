import Scenes
import Igis

class TextFieldButton: RenderableEntity, MouseDownHandler, KeyDownHandler {

    let boundingBox: Rect    
    let textFieldBoundingBox: Rect
    let buttonBoundingBox: Rect
    let defaultString: String

    let buttonLabel: String

    var active = false
    var inputString: String
    var fontSize: Int = 30
    var font: String {
        return "\(fontSize)pt Arial"
    }
    var text: Text!
    var textMetric: TextMetric!
    var updatedText = true
    var resizing = true

    let allowedKeys: [String]
    let restrictions: [(String) -> Bool]
    
    init(boundingBox: Rect, defaultString: String, buttonLabel: String, allowedKeys: [String], restrictions: [(String) -> Bool] = []) {
        self.boundingBox = boundingBox
        self.textFieldBoundingBox = Rect(topLeft: boundingBox.topLeft, size: Size(width: boundingBox.size.width * 5 / 6,
                                                                                  height: boundingBox.size.height))
        self.buttonBoundingBox = Rect(topLeft: textFieldBoundingBox.topRight, size: Size(width: boundingBox.size.width / 6,
                                                                                         height: boundingBox.size.height))
        self.defaultString = defaultString        
        self.inputString = defaultString
        self.buttonLabel = buttonLabel
        self.allowedKeys = allowedKeys
        self.restrictions = restrictions        
        
        super.init(name: "TextFieldButton")
    }

    func onKeyDown(key: String, code: String, ctrlKey: Bool, shiftKey: Bool, altKey: Bool, metaKey: Bool) {
        if active, textMetric.isReady {
            if allowedKeys.contains(key) {
                if key == "Backspace" {
                    if inputString.count > 0 {
                        inputString.removeLast()
                    }
                } else {
                    if restrictions.allSatisfy({ $0(inputString + key) }) {
                        inputString += key
                    }
                }
                updatedText = true
                resizing = true        
            }
        }
    }

    func onMouseDown(globalLocation: Point) {
        if textFieldBoundingBox.containment(target: globalLocation).contains(.containedFully) {            
            active = true
            if inputString == defaultString {
                inputString = ""
            }
        } else if !buttonBoundingBox.containment(target: globalLocation).contains(.containedFully) {
            active = false
            if inputString == "" {
                inputString = defaultString
            }
        }
        updatedText = true
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        text = Text(location: Point(x: textFieldBoundingBox.left + 3, y: textFieldBoundingBox.centerY), text: inputString, fillMode: .fill)
        text.font = font
        text.alignment = .left
        textMetric = TextMetric(fromText: text)
        canvas.setup(textMetric)

        // Dispatcher
        dispatcher.registerMouseDownHandler(handler: self)
        dispatcher.registerKeyDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        let buttonLabelText = Text(location: buttonBoundingBox.center, text: buttonLabel, fillMode: .fill)
        buttonLabelText.font = "15pt Arial"
        buttonLabelText.alignment = .center
        buttonLabelText.baseline = .middle
        canvas.render(StrokeStyle(color: Color(.black)), FillStyle(color: Color(.white)),
                      Rectangle(rect: buttonBoundingBox, fillMode: .fillAndStroke),
                      FillStyle(color: Color(.black)), buttonLabelText)
        
            
        if textMetric.isReady {
            if resizing {
                canvas.render(textMetric)
            }                                                

            if updatedText {
                switch active {
                case true: canvas.render(FillStyle(color: Color(.yellow)))
                case false: canvas.render(FillStyle(color: Color(.white)))
                }
                canvas.render(StrokeStyle(color: Color(.black)),
                              LineWidth(width: 1), Rectangle(rect: textFieldBoundingBox, fillMode: .fillAndStroke))                
                text.text = inputString
                textMetric.text = inputString
                if !resizing {
                    switch inputString {
                    case defaultString: canvas.render(FillStyle(color: Color(.gray)))
                    default: canvas.render(FillStyle(color: Color(.black)))
                    }
                    canvas.render(text)
                    updatedText = false
                }
            }

            if resizing, let metrics = textMetric.mostRecentMetrics,
               let boundingBox = metrics.fontBoundingBox(location: text.location) { 
                if !textFieldBoundingBox.containment(target:boundingBox).contains(.containedHorizontally) {
                    fontSize -= 1
                    text.font = font
                    textMetric.font = font
                } else {
                    resizing = false
                }
                updatedText = true
            }             
        }                
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
        dispatcher.unregisterKeyDownHandler(handler: self)
    }
    
}

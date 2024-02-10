import Foundation
import Igis
import Scenes
import LevelGeneration

class FileViewer: RenderableEntity, MouseDownHandler {

    private var fileNames = [NSString]()
    private var levels = [Level]()
    var pageCount: Int {
        fileNames.count % 10 == 0 ? fileNames.count / 10 : fileNames.count / 10 + 1
    }
    var currentPageIndex = 0
    var activeFileIndex: Int? = nil

    let boundingBox: Rect
    private var updateRender = false

    var fileNameRectSize: Size!
    var fileNameRectButtons = [Rect]()
    
    var buttonRectSizeHeight: Int!
    var previousButtonRect: Rect!
    var nextButtonRect: Rect!
    var loadFileNameButtonRect: Rect!
    var loadLevelButtonRect: Rect!
    
    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("Scene is required to be of type EditScene for FileViewer.")
        }
        return editScene        
    }

    func levelEditor() -> LevelEditor {
        return editScene().interactionLayer.levelEditor
    }

    func controlPanel() -> ControlPanel {
        return editScene().interactionLayer.controlPanel
    }

    func background() -> EditBackground {
        return editScene().backgroundLayer.background
    }

    func update() {
        updateRender = true
    }

    func incrementPageIndex() {
        guard currentPageIndex + 1 < pageCount else {
            levelEditor().errorConsole.throwError("Cannot go to next page from last page of file viewer.")
            return
        }
        currentPageIndex += 1
        updateRender = true
    }

    func decrementPageIndex() {
        guard currentPageIndex - 1 >= 0 else {
            levelEditor().errorConsole.throwError("Cannot go to previous page from first page of file viewer.")
            return
        }
        currentPageIndex -= 1
        updateRender = true
    }

    func loadActive() {
        guard let activeFileIndex = activeFileIndex else {
                    levelEditor().errorConsole.throwError("Must select file before loading to editor.")
                    return
                }
        background().clear(levelEditor: true)
        levelEditor().levelRenderer.stageLevel(level: levels[activeFileIndex])
        levelEditor().update()
    }

    func viewActiveLevel() {
        guard let activeFileIndex = activeFileIndex else {
            return
        }
        controlPanel().levelViewer.stageLevel(level: levels[activeFileIndex])
        controlPanel().update()                    
    }

    func loadLevels(fileNames: [NSString], levels: [Level]) {
        precondition(fileNames.count == levels.count, "File Names and Levels must correspond.")
        self.fileNames = fileNames
        self.levels = levels
    }

    func onMouseDown(globalLocation: Point) {
        if boundingBox.containment(target: globalLocation).contains(.containedFully) {
            // Check File Name Button Rects
            for rectIndex in 0 ..< fileNameRectButtons.count {
                if fileNameRectButtons[rectIndex].containment(target: globalLocation).contains(.containedFully) {
                    let fileIndex = rectIndex + currentPageIndex * 10
                    guard fileIndex < fileNames.count else {
                        levelEditor().errorConsole.throwError("Cannot select non-existant file.")
                        return
                    }
                    activeFileIndex = fileIndex
                    background().clear(controlPanel: true)
                    update()
                    return
                }
            }

            // Check for previous page then next page
            if previousButtonRect.containment(target: globalLocation).contains(.containedFully) {
                decrementPageIndex()
                return
            }
            if nextButtonRect.containment(target: globalLocation).contains(.containedFully) {
                incrementPageIndex()
                return
            }

            // Check Load Level
            if loadLevelButtonRect.containment(target: globalLocation).contains(.containedFully) {
                loadActive()
            }
            // Check Load File Name
            if loadFileNameButtonRect.containment(target: globalLocation).contains(.containedFully) {
                guard let activeFileIndex = activeFileIndex else {
                    levelEditor().errorConsole.throwError("Must select a file before loading to save field.")
                    return
                }                
                controlPanel().saveFile.inputString = String(fileNames[activeFileIndex].deletingPathExtension)
            }            
        }        
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Setup File Name Rect Size
        fileNameRectSize = Size(width: boundingBox.width, height: boundingBox.height / 11)

        // Setup File Name Button Rects
        for rectIndex in 0 ..< 10 {
            fileNameRectButtons.append(Rect(topLeft: boundingBox.topLeft + Point(x: 0, y: fileNameRectSize.height * rectIndex),
                                            size: fileNameRectSize))            
        }

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

            for rectIndex in 0 ..< fileNameRectButtons.count {
                let fileIndex = rectIndex + currentPageIndex * 10
                guard fileIndex < fileNames.count else {
                    break
                }
                fileIndex == activeFileIndex ? canvas.render(FillStyle(color: Color(.yellow))) : canvas.render(FillStyle(color: Color(.white)))
                canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                              Rectangle(rect: fileNameRectButtons[rectIndex], fillMode: .fillAndStroke))                
                
                let fileString = fileNames[fileIndex]
                let fileText = Text(location: Point(x: fileNameRectButtons[rectIndex].centerX, y: fileNameRectButtons[rectIndex].top + 5),
                                text: fileString as String,
                                fillMode: .fill)
                fileText.font = "12pt Arial"
                fileText.alignment = .center
                fileText.baseline = .top                                
                canvas.render(FillStyle(color: Color(.black)), fileText)
            }
            
            canvas.render(FillStyle(color: Color(.white)), StrokeStyle(color: Color(.black)),
                          Rectangle(rect: previousButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: nextButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: loadFileNameButtonRect, fillMode: .fillAndStroke),
                          Rectangle(rect: loadLevelButtonRect, fillMode: .fillAndStroke))

            let nextArrowPath = Path(fillMode: .fillAndStroke)
            nextArrowPath.moveTo(Point(x: nextButtonRect.left + 5, y: nextButtonRect.centerY))
            nextArrowPath.lineTo(Point(x: nextButtonRect.right - 5, y: nextButtonRect.centerY))
            nextArrowPath.lineTo(Point(x: nextButtonRect.right - (nextButtonRect.width / 3), y: nextButtonRect.top + 5))
            nextArrowPath.lineTo(Point(x: nextButtonRect.right - (nextButtonRect.width / 3), y: nextButtonRect.bottom - 5))
            nextArrowPath.lineTo(Point(x: nextButtonRect.right - 5, y: nextButtonRect.centerY))
            canvas.render(FillStyle(color: Color(.black)), nextArrowPath)

            let previousArrowPath = Path(fillMode: .fillAndStroke)
            previousArrowPath.moveTo(Point(x: previousButtonRect.right - 5, y: previousButtonRect.centerY))
            previousArrowPath.lineTo(Point(x: previousButtonRect.left + 5, y: previousButtonRect.centerY))
            previousArrowPath.lineTo(Point(x: previousButtonRect.left + (previousButtonRect.width / 3), y: previousButtonRect.top + 5))
            previousArrowPath.lineTo(Point(x: previousButtonRect.left + (previousButtonRect.width / 3), y: previousButtonRect.bottom - 5))
            previousArrowPath.lineTo(Point(x: previousButtonRect.left + 5, y: previousButtonRect.centerY))
            canvas.render(FillStyle(color: Color(.black)), previousArrowPath)

            let loadLevelUILabel = Text(location: loadLevelButtonRect.center,
                                        text: "Edit Level",
                                        fillMode: .fill)
            loadLevelUILabel.font = "12pt Arial"
            loadLevelUILabel.alignment = .center
            loadLevelUILabel.baseline = .middle

            let loadFileNameUILabel = Text(location: loadFileNameButtonRect.center,
                                           text: "Load File Name",
                                           fillMode: .fill)
            loadFileNameUILabel.font = "12pt Arial"
            loadFileNameUILabel.alignment = .center
            loadFileNameUILabel.baseline = .middle
            
            canvas.render(FillStyle(color: Color(.black)), loadLevelUILabel, loadFileNameUILabel)

            
            viewActiveLevel()
            
            updateRender = false
        }
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

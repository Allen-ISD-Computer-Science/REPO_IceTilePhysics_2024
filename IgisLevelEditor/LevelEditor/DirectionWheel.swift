import Igis
import Scenes
import LevelGeneration

class DirectionWheel: RenderableEntity, MouseDownHandler {

    let boundingBox: Rect
    private var directionBoundingBoxs = [Rect]()
    private var directionPaths = [Path]()
    private var selected: [Bool] = Array(repeating: false, count: 4)
    private var updateRender = false

    init(boundingBox: Rect) {
        self.boundingBox = boundingBox
        super.init(name: "DirectionWheel")
    }

    func update() {
        updateRender = true
    }

    func editScene() -> EditScene {
        guard let editScene = scene as? EditScene else {
            fatalError("scene is required to be of type EditScene for DirectionWheel")
        }
        return editScene
    }

    func levelEditor() -> LevelEditor {
        return editScene().interactionLayer.levelEditor
    }

    func onMouseDown(globalLocation: Point) {
        for index in 0 ..< directionBoundingBoxs.count {
            if directionBoundingBoxs[index].containment(target: globalLocation).contains(.containedFully) {
                selected[index] = !selected[index]
                updateRender = true
            }
        }
    }

    func directionPair() -> DirectionPair? {
        var selectedDirections = [Direction]()
        for index in 0 ..< Direction.allCases.count {
            if selected[index] {
                selectedDirections.append(Direction.allCases[index])
            }
        }
        guard selectedDirections.count == 2 else {
            // Throw to error Console
            levelEditor().errorConsole.throwError("There must be exactly 2 selected Directions.")
            return nil
        }
        guard selectedDirections[0].toggle() != selectedDirections[1] else {
            // Throw to error Console
            levelEditor().errorConsole.throwError("Directions must not be opposites in a DirectionPair.")
            return nil
        }
        return DirectionPair(selectedDirections[0], selectedDirections[1])
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        
        // Define Direction Bounding Boxes
        let maxHeight = (boundingBox.height - 10) / 3
        let maxWidth = (boundingBox.width - 10) / 3
        let directionSize = maxHeight > maxWidth ? Size(width: maxWidth, height: maxWidth) : Size(width: maxHeight, height: maxWidth)
        let leftBoundingBox = Rect(topLeft: boundingBox.topLeft + Point(x: 5, y: 5 + maxHeight), size: directionSize)
        let upBoundingBox = Rect(bottomLeft: leftBoundingBox.topRight, size: directionSize)
        let downBoundingBox = Rect(topLeft: leftBoundingBox.bottomRight, size: directionSize)
        let rightBoundingBox = Rect(topLeft: upBoundingBox.bottomRight, size: directionSize)
        directionBoundingBoxs = [upBoundingBox, downBoundingBox, leftBoundingBox, rightBoundingBox]

        // Render Direction Wheel
        let upPath = Path(fillMode: .fillAndStroke)
        upPath.moveTo(directionBoundingBoxs[0].bottomLeft + Point(x: 5, y: -5))
        upPath.lineTo(Point(x: directionBoundingBoxs[0].centerX, y: directionBoundingBoxs[0].top))
        upPath.lineTo(directionBoundingBoxs[0].bottomRight + Point(x: -5, y: -5))
        upPath.close()
        let downPath = Path(fillMode: .fillAndStroke)
        downPath.moveTo(directionBoundingBoxs[1].topLeft + Point(x: 5, y: 5))
        downPath.lineTo(Point(x: directionBoundingBoxs[1].centerX, y: directionBoundingBoxs[1].bottom))
        downPath.lineTo(directionBoundingBoxs[1].topRight + Point(x: -5, y: 5))
        downPath.close()
        let leftPath = Path(fillMode: .fillAndStroke)
        leftPath.moveTo(directionBoundingBoxs[2].topRight + Point(x: -5, y: 5))
        leftPath.lineTo(Point(x: directionBoundingBoxs[2].left, y: directionBoundingBoxs[2].centerY))
        leftPath.lineTo(directionBoundingBoxs[2].bottomRight + Point(x: -5, y: -5))
        leftPath.close()
        let rightPath = Path(fillMode: .fillAndStroke)
        rightPath.moveTo(directionBoundingBoxs[3].topLeft + Point(x: 5, y: 5))
        rightPath.lineTo(Point(x: directionBoundingBoxs[3].right, y: directionBoundingBoxs[3].centerY))
        rightPath.lineTo(directionBoundingBoxs[3].bottomLeft + Point(x: 5, y: -5))
        rightPath.close()
        directionPaths = [upPath, downPath, leftPath, rightPath]        

        // Register Click Handler
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updateRender {
            // Render Bounding Box
            canvas.render(FillStyle(color: Color(.lightgray)),
                          StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          Rectangle(rect: boundingBox, fillMode: .fillAndStroke))
            
            for index in 0 ..< directionPaths.count {
                if selected[index] {
                    canvas.render(LineWidth(width: 3), StrokeStyle(color: Color(.red)), FillStyle(color: Color(.black)), directionPaths[index])
                } else {
                    canvas.render(LineWidth(width: 1), StrokeStyle(color: Color(.black)), FillStyle(color: Color(.black)), directionPaths[index])
                }
            }
        }
        canvas.render(StrokeStyle(color: Color(.black)))
        updateRender = false
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

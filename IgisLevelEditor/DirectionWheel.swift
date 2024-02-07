import Igis
import Scenes
import LevelGeneration

class DirectionWheel: RenderableEntity, MouseDownHandler {

    var wheelBoundingBox = Rect()
    private var directionBoundingBoxs = [Rect]()
    private var directionPaths = [Path]()
    private var selected: [Bool] = Array(repeating: false, count: 4)
    private var updated = true

    init() {        
        super.init(name: "DirectionWheel")
    }

    func setBoundingBox(rect: Rect) {
        wheelBoundingBox = rect
    }

    func onMouseDown(globalLocation: Point) {
        for index in 0 ..< directionBoundingBoxs.count {
            if directionBoundingBoxs[index].containment(target: globalLocation).contains(.containedFully) {
                selected[index] = !selected[index]
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
            print("There must be exactly 2 selected Directions.")
            return nil
        }
        guard selectedDirections[0].toggle() != selectedDirections[1] else {
            print("Directions must not be opposites in a DirectionPair.")
            return nil
        }
        return DirectionPair(selectedDirections[0], selectedDirections[1])
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        
        // Define Direction Bounding Boxes
        let maxHeight = (wheelBoundingBox.height - 10) / 3
        let maxWidth = (wheelBoundingBox.width - 10) / 3
        let directionSize = maxHeight > maxWidth ? Size(width: maxWidth, height: maxWidth) : Size(width: maxHeight, height: maxWidth)
        let leftBoundingBox = Rect(topLeft: wheelBoundingBox.topLeft + Point(x: 5, y: 5 + maxHeight), size: directionSize)
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

        // Render DirectionWheel Bounding Box Rectangle
        canvas.render(FillStyle(color: Color(.darkgray)),
                      StrokeStyle(color: Color(.black)),
                      Rectangle(rect: wheelBoundingBox, fillMode: .fillAndStroke))

        // Register Click Handler
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func render(canvas: Canvas) {
        if updated {
            for index in 0 ..< directionPaths.count {
                if selected[index] {
                    canvas.render(StrokeStyle(color: Color(.red)), directionPaths[index])
                } else {
                    canvas.render(StrokeStyle(color: Color(.black)), directionPaths[index])
                }
            }
        }
        canvas.render(StrokeStyle(color: Color(.black)))
    }

    override func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }
}

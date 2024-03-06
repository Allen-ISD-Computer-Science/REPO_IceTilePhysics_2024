import Scenes
import Igis
import LevelGeneration

class PlayBackground: RenderableEntity {

    var totalUnpainted: Double!
    var levelRenderer: LevelRenderer!

    var updateRender: Bool = false

    init() {
        super.init(name: "Background")
    }

    func playScene() -> PlayScene {
        guard let playScene = scene as? PlayScene else {
            fatalError("scene is required to be of type PlayScene for PlayBackground.")
        }
        return playScene
    }

    func update() {
        updateRender = true
        levelRenderer.update()
    }

    func calculateTotalUnpainted(level: Level) -> Double {
        return Double(level.tilePointsOfStatus(tileStatus: .unpainted).count)
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Render Background Color
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: Rect(size: canvasSize), fillMode: .fill))

        // Setup Total Unpainted Tilestate
        totalUnpainted = calculateTotalUnpainted(level: playScene().level)

        // Setup Level Renderer
        let center = Point(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let canvasSizePadding = Size(width: canvasSize.width - 10, height: canvasSize.height - 10)
        let levelRendererFaceSize = (canvasSizePadding.width / 3) > (canvasSizePadding.height / 4) ?
          Size(width: canvasSizePadding.height / 4, height: canvasSizePadding.height / 4) :
          Size(width: canvasSizePadding.width / 3, height: canvasSizePadding.width / 3)
        var levelRendererBoundingBox = Rect(size: Size(width: levelRendererFaceSize.width * 3, height: levelRendererFaceSize.height * 4))
        levelRendererBoundingBox.center = center
        levelRenderer = LevelRenderer(boundingBox: levelRendererBoundingBox, faceSize: levelRendererFaceSize)
        levelRenderer.stageLevel(level: playScene().level)
        randomizePaintColor()
        
        // Layer
        layer.insert(entity: levelRenderer, at: .front)                
    }

    func randomizePaintColor() {
        levelRenderer.paintColor = Color(red: UInt8.random(in: 0...UInt8.max),
                                         green: UInt8.random(in: 0...UInt8.max),
                                         blue: UInt8.random(in: 0...UInt8.max))
        
    }

    override func render(canvas: Canvas) {
        if updateRender, let canvasSize = canvas.canvasSize {
            canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: Rect(size: canvasSize), fillMode: .fill))
            updateRender = false
        }
        
        let currentUnpainted = Double(levelRenderer.level.tilePointsOfStatus(tileStatus: .unpainted).count)
        let percentage = Int(((totalUnpainted - currentUnpainted) / totalUnpainted) * 100.0)
        if percentage == 100, playScene().levelList != nil,  playScene().interactionLayer.player.currentSlide == nil {
            playScene().enqueueNextLevel()
        }
        let percentageRect = Rect(topLeft: Point(x: 5, y: 175), size: Size(width: 300, height: 50))
        let percentageText = Text(location: Point(x: percentageRect.left, y: percentageRect.centerY),
                                  text: String(percentage) + "% Completed",
                                  fillMode: .fill)
        percentageText.font = "20pt Arial"
        percentageText.alignment = .left
        percentageText.baseline = .middle
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: percentageRect, fillMode: .fill),
                      FillStyle(color: Color(.black)), percentageText)

        if let fileName = playScene().fileName {
            let fileNameRect = Rect(topLeft: Point(x: 5, y: 225), size: Size(width: 400, height: 50))
            let fileNameText = Text(location: Point(x: fileNameRect.left, y: fileNameRect.centerY),
                                    text: fileName,
                                    fillMode: .fill)
            fileNameText.font = "20pt Arial"
            fileNameText.alignment = .left
            fileNameText.baseline = .middle
            canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: fileNameRect, fillMode: .fill),
                          FillStyle(color: Color(.black)), fileNameText)
        }
    }
    
}

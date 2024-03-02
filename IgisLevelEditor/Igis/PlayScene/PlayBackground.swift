import Scenes
import Igis
import LevelGeneration

class PlayBackground: RenderableEntity {

    var totalInactive: Double!
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

    func slide(slide: Slide) {
        levelRenderer.level.changeTileStatusIfCurrent(levelPoints: slide.intermediates.map { $0.point }, current: .nonPaintable, new: .paintable)
        levelRenderer.level.setTileStatus(levelPoint: slide.destination.point, tileStatus: .critical)
        levelRenderer.update()
    }

    func calculateTotalInactive(level: Level) -> Double {
        return Double(level.tilePointsOfStatusAndType(tileStatus: .nonPaintable, specialTileType: nil).count)
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        // Render Background Color
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: Rect(size: canvasSize), fillMode: .fill))

        // Setup Total Inactive Tilestate
        totalInactive = calculateTotalInactive(level: playScene().level)

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
        levelRenderer.paintColor = Color(red: UInt8.random(in: 0...UInt8.max),
                                         green: UInt8.random(in: 0...UInt8.max),
                                         blue: UInt8.random(in: 0...UInt8.max))
        
        // Layer
        layer.insert(entity: levelRenderer, at: .front)                
    }

    override func render(canvas: Canvas) {
        if updateRender, let canvasSize = canvas.canvasSize {
            canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: Rect(size: canvasSize), fillMode: .fill))
            updateRender = false
        }
        
        let currentInactive = Double(levelRenderer.level.tilePointsOfStatusAndType(tileStatus: .nonPaintable, specialTileType: nil).count)
        let percentage = Int(((totalInactive - currentInactive) / totalInactive) * 100.0)
        if percentage == 100, playScene().levelList != nil,  playScene().interactionLayer.player.currentSlide == nil {
            playScene().enqueueNextLevel()
        }
        let percentageRect = Rect(topLeft: Point(x: 5, y: 140), size: Size(width: 300, height: 50))
        let percentageText = Text(location: Point(x: percentageRect.left, y: percentageRect.centerY),
                                  text: String(percentage) + "% Completed",
                                  fillMode: .fill)
        percentageText.font = "20pt Arial"
        percentageText.alignment = .left
        percentageText.baseline = .middle
        canvas.render(FillStyle(color: Color(.lightblue)), Rectangle(rect: percentageRect, fillMode: .fill),
                      FillStyle(color: Color(.black)), percentageText)

        if let fileName = playScene().fileName {
            let fileNameRect = Rect(topLeft: Point(x: 5, y: 200), size: Size(width: 400, height: 50))
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

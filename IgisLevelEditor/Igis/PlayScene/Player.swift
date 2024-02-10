import Scenes
import Igis
import LevelGeneration

class Player: RenderableEntity {

    var location: LevelPoint
    let levelGraph: Graph
    var currentSlide: Slide? = nil
    var currentFrame: Int? = nil
    
    init(startingLocation: LevelPoint, levelGraph: Graph) {
        self.location = startingLocation
        self.levelGraph = levelGraph
        super.init(name: "Player")
    }

    func playScene() -> PlayScene {
        guard let playScene = scene as? PlayScene else {
            fatalError("scene is required to be of type PlayScene for Player")            
        }
        return playScene
    }

    func levelRenderer() -> LevelRenderer {
        return playScene().backgroundLayer.background.levelRenderer
    }

    func slide(_ direction: Direction) {
        let possibleSlides = levelGraph.slides.filter { $0.originPoint == location && $0.originDirection == direction }
        guard possibleSlides.count == 1, let slide = possibleSlides.first else {
            return
        }
        currentSlide = slide
        currentFrame = 0
        playScene().backgroundLayer.background.slide(slide: slide)
    }

    override func render(canvas: Canvas) {
        if currentSlide != nil,
           currentFrame != nil {
            let animationPoints = currentSlide!.activatedTilePoints + [currentSlide!.destinationPoint]
            if currentFrame! < animationPoints.count {
                location = animationPoints[currentFrame!]
            } else {
                self.currentSlide = nil
                self.currentFrame = nil
                return
            }
            levelRenderer().playerLocation = location
            levelRenderer().update()
            self.currentFrame! += 1
        }
    }
}

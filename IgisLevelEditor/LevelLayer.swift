import Scenes
import Igis
import LevelGeneration

class LevelLayer: Layer, MouseDownHandler {

    let renderableLevel: RenderableLevel

    init() {        
        let levelSize = LevelSize(edgeLength: 7)
        let startingPosition = LevelPoint(x: 1, y: 1, cubeFace: .front)        
        self.renderableLevel = RenderableLevel(level: Level(levelSize: levelSize, startingPosition: startingPosition))

        super.init(name:"Level")
        
        insert(entity:renderableLevel, at: .front)
    }

    func onMouseDown(globalLocation: Point) {
        print(globalLocation)
    }

    func setup(canvasSize: Size, canvas: Canvas) {
        dispatcher.registerMouseDownHandler(handler: self)
    }

    func teardown() {
        dispatcher.unregisterMouseDownHandler(handler: self)
    }    
}

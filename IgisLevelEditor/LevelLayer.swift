import Scenes
import LevelGeneration

class LevelLayer: Layer {

    let renderableLevel: RenderableLevel

    init() {        
        let levelSize = LevelSize(edgeLength: 7)
        let startingPosition = LevelPoint(x: 1, y: 1, cubeFace: .front)        
        self.renderableLevel = RenderableLevel(level: Level(levelSize: levelSize, startingPosition: startingPosition))

        super.init(name:"Level")
        
        insert(entity:renderableLevel, at: .front)
    }
    
}

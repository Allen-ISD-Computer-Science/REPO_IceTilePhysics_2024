import Scenes
import Igis
import LevelGeneration

class LevelLayer: Layer {

    let renderableLevel: RenderableLevel

    init() {        
        let levelSize = LevelSize(edgeLength: 8)
        let startingPosition = LevelPoint(face: .back, x: 1, y: 1)        
        self.renderableLevel = RenderableLevel(level: Level(levelSize: levelSize, startingPosition: startingPosition))

        super.init(name:"Level")
        
        insert(entity:renderableLevel, at: .back)
    }
}

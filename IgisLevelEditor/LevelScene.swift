import Scenes

class LevelScene: Scene {
    let levelLayer = LevelLayer()

    init() {
        super.init(name:"Level")

        insert(layer:levelLayer, at: .back)
    }
}

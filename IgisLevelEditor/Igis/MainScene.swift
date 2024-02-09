import Scenes

class MainScene: Scene {

    let interactionLayer = InteractionLayer()
    let backgroundLayer = BackgroundLayer()

    init() {
        super.init(name: "MainScene")

        insert(layer:interactionLayer, at:.front)
        insert(layer:backgroundLayer, at:.back)
    }
    
}

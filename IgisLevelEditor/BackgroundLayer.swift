import Scenes

class BackgroundLayer: Layer {

    let background = Background()
    
    init() {
        super.init(name: "Background")

        insert(entity: background, at: .back)
    }
    
}

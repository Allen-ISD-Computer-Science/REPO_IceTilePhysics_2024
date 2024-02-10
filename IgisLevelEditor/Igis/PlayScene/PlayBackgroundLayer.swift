import Scenes

class PlayBackgroundLayer: Layer {

    let background = PlayBackground()
    
    init() {
        super.init(name: "PlayBackground")

        insert(entity: background, at: .back)
    }
    
}

import Scenes

class EditBackgroundLayer: Layer {

    let background = EditBackground()
    
    init() {
        super.init(name: "EditBackground")

        insert(entity: background, at: .back)
    }
    
}

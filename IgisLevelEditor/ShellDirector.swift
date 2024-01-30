import Igis
import Scenes

class ShellDirector: Director {
    required init() {
        super.init()
        enqueueScene(scene:MainScene())
    }

    override func framesPerSecond() -> Int {
        return 30
    }
}

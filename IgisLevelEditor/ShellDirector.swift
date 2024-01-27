import Igis
import Scenes

class ShellDirector: Director {
    required init() {
        super.init()
        enqueueScene(scene:LevelScene())
    }

    override func framesPerSecond() -> Int {
        return 30
    }
}

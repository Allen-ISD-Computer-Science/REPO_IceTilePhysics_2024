import Igis
import Scenes
import LevelGeneration

class ShellDirector: Director {
    required init() {
        super.init()
        edit()
    }

    func edit(level: Level? = nil) {
        enqueueScene(scene:EditScene(level: level))
    }

    func play(level: Level) {
        enqueueScene(scene:PlayScene(level: level))
    }

    override func framesPerSecond() -> Int {
        return 30
    }
}

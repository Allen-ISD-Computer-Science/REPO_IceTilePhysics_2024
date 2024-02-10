import Igis
import Scenes
import LevelGeneration

class ShellDirector: Director {
    required init() {
        super.init()
        edit()
    }

    func edit(fileName: String? = nil, level: Level? = nil) {
        enqueueScene(scene:EditScene(fileName: fileName, level: level))
    }

    func play(fileName: String? = nil, level: Level) {
        enqueueScene(scene:PlayScene(fileName: fileName, level: level))
    }

    override func framesPerSecond() -> Int {
        return 30
    }
}

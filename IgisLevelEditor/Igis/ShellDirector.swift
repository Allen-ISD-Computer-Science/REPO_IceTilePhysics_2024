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
    func play(fileNameList: [String]? = nil, levelList: [Level]) {
        enqueueScene(scene: PlayScene(fileNameList: fileNameList, levelList: levelList))
    }

    override func framesPerSecond() -> Int {
        return 30
    }
}

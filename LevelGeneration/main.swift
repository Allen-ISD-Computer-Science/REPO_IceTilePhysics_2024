func main() {
    LevelRandomizer.initialize()
    guard let levelRandomizer = LevelRandomizer.shared else {
        fatalError("Level Randomizer must be initialized prior to being used.")
    }
    let levelSeed = Level(levelSize: LevelSize(edgeLength: 11), startingPosition: LevelPoint(x: 1, y: 1, cubeFace: .back))
    let complexLevels = levelRandomizer.createComplexCubeFaceLevels(seed: levelSeed)
    complexLevels.last?.printTileStates()
}
main()

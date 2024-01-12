func main() {
    LevelRandomizer.initialize()
    guard let levelRandomizer = LevelRandomizer.shared else {
        fatalError("Level Randomizer must be initialized prior to being used.")
    }
    let levelSeed = Level(levelSize: LevelSize(edgeLength: 8), startingPosition: LevelPoint(x: 1, y: 1, cubeFace: .top))
    levelSeed.printTileStates()
    /*
    var complexLevels = [[Level]]()
    var maxWallCount = 0
    for i in 0 ..< 2 {
        let complexLevel = levelRandomizer.createComplexCubeFaceLevels(seed: levelSeed)
        print("done")
        complexLevels.append(complexLevel)
        if complexLevel.count > maxWallCount {
            maxWallCount = complexLevel.count
        }
    }
    print(complexLevels.count, maxWallCount)
    
     */
}
main()

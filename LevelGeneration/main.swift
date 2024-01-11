func main() {
    LevelRandomizer.initialize()
    guard let levelRandomizer = LevelRandomizer.shared else {
        fatalError("Level Randomizer must be initialized prior to being used.")
    }
    let levelSeed = CubeFaceLevel(size: GridSize(sideLength: 13), startingPosition: GridPoint(x: 1, y: 1), cubeFace: .top)
    var complexLevels = [[CubeFaceLevel]]()
    var maxWallCount = 0
    for i in 0 ..< 1000 {
        let complexLevel = levelRandomizer.createComplexCubeFaceLevels(seed: levelSeed)
        complexLevels.append(complexLevel)
        if complexLevel.count > maxWallCount {
            maxWallCount = complexLevel.count
        }
    }
    print(complexLevels.count, maxWallCount)
}
main()

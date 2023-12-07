func main() {
    LevelRandomizer.initialize()
    guard let levelRandomizer = LevelRandomizer.shared else {
        fatalError("Level Radnomizer must be initialized prior to be accessed.")
    }
    
    var level = Level(size: GridSize(sideLength: 9), startingPosition: GridPoint(x: 1, y: 1))
    level.printGrid()    
    print("Level is solvable? \(level.solvable())")

    let complexLevels = levelRandomizer.createComplexLevels(seed: level)
    print(complexLevels.count)
    complexLevels[complexLevels.count - 1].printGrid()
}

main()

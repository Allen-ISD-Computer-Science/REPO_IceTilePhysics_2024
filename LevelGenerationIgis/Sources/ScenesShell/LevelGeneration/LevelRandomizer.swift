public class LevelRandomizer {
    public static var shared: LevelRandomizer? = nil
    static let randomizerIterationCap: Int = 10

    private init() {
        
    }

    public static func initialize() {
        shared = LevelRandomizer()
    }

    public func createComplexLevels(seed: Level) -> [Level] {
        var levels = [seed]
        var randomizeIterationCount = 0
        
        // Interupt slide with a wall
        repeat {            
            precondition(levels.count > 0, "There must be a level seed to randomize")
            var complexLevel = levels[levels.count - 1]
            let viableActiveGridPoints = Set(complexLevel.tilePointsOfState(tileState: .active)).subtracting(complexLevel.activeTilePointsAdjacentToCriticals())
            guard randomizeIterationCount < LevelRandomizer.randomizerIterationCap else {
                return levels
            }
            guard let randomViableActiveGridPoint = viableActiveGridPoints.randomElement() else {
                return levels
            }
            complexLevel.setTileState(levelPoint: randomViableActiveGridPoint, tileState: .wall)
            complexLevel.resetLevel()
            if complexLevel.solvable() {                
                levels.append(complexLevel)
                randomizeIterationCount = 0
            } else {
                randomizeIterationCount += 1
            }            
        } while true
    }    
}


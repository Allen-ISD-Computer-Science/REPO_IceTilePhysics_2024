public class LevelRandomizer {
    public static var shared: LevelRandomizer? = nil

    private init() {
        
    }

    public static func initialize() {
        shared = LevelRandomizer()
    }

    public func createComplexLevels(seed: Level) -> [Level] {
        var levels = [seed]        
        // Interupt slide with a wall
        repeat {
            var complexLevel = levels[levels.count - 1]
            let viableActiveGridPoints = Set(complexLevel.tileGridPointsOfState(tileState: .active)).subtracting(complexLevel.activesAdjacentToCriticals())
            guard let randomViableActiveGridPoint = viableActiveGridPoints.randomElement() else {
                return levels
            }
            complexLevel.setTileState(point: randomViableActiveGridPoint, tileState: .wall)
            complexLevel.resetLevel()
            if complexLevel.solvable() {                
                levels.append(complexLevel)
            }
        } while true
    }    
}


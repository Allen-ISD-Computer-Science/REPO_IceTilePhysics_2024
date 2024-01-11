public class LevelRandomizer {
    public static var shared: LevelRandomizer? = nil
    static let randomizerIterationCap: Int = 100

    private init() {
        
    }

    public static func initialize() {
        shared = LevelRandomizer()
    }

    public func createComplexCubeFaceLevels(seed: CubeFaceLevel) -> [CubeFaceLevel] {
        var levels = [seed]
        var randomizeIterationCount = 0
        
        // Interupt slide with a wall
        repeat {            
            precondition(levels.count > 0, "Must be a level seed to randomize")
            var complexLevel = levels[levels.count - 1]
            let viableActiveGridPoints = Set(complexLevel.tileGridPointsOfState(tileState: .active)).subtracting(complexLevel.activesAdjacentToCriticals())
            guard randomizeIterationCount < LevelRandomizer.randomizerIterationCap else {
                return levels
            }
            guard let randomViableActiveGridPoint = viableActiveGridPoints.randomElement() else {
                return levels
            }
            complexLevel.setTileState(point: randomViableActiveGridPoint, tileState: .wall)
            complexLevel.resetCubeFaceLevel()
            if complexLevel.solvable() {                
                levels.append(complexLevel)
                randomizeIterationCount = 0
            } else {
                print("Not solvable, trying again, level number: \(levels.count + 1)")
                randomizeIterationCount += 1
            }            
        } while true
    }    
}


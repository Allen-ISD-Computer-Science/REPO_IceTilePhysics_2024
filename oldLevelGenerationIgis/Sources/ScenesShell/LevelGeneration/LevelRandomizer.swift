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
        func interruptSlides() {
            repeat {            
                precondition(levels.count > 0, "There must be a level seed to randomize")
                var complexLevel = levels[levels.count - 1]
                let viableActiveGridPoints = Set(complexLevel.tilePointsOfState(tileState: .active)).subtracting(complexLevel.activeTilePointsAdjacentToCriticals())
                guard randomizeIterationCount < LevelRandomizer.randomizerIterationCap else {
                    break
                }
                guard let randomViableActiveGridPoint = viableActiveGridPoints.randomElement() else {
                    break
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
        func unlockCubeFace() {
            precondition(levels.count > 0, "There must be a level seed to randomize")
            var complexLevel = levels[levels.count - 1]
            let borderPoints = Set(complexLevel.faceLevels.flatMap { $0.borderPoints() })
            let eligiblePoints = complexLevel.tilePointsOfState(tileState: .critical).filter {
                let adjacentPoints = Set(complexLevel.adjacentPoints(levelPoint: $0).map { $0.adjacentPoint })
                // There must be an adjacent point that is also a border tile, sets must not be disjoint
                if adjacentPoints.isDisjoint(with: borderPoints) {
                    return false
                }
                // There must be exactly one wall state                
                let adjacentWallPoints = adjacentPoints.filter { complexLevel.faceLevels[$0.cubeFace.rawValue].tiles[$0.x][$0.y].tileState == .wall } 
                if adjacentWallPoints.count == 1 {
                    return true                    
                }
                return false
            }
            guard let randomEligiblePoint = eligiblePoints.randomElement() else {
                fatalError()
            }
            let adjacentPoints = complexLevel.adjacentPoints(levelPoint: randomEligiblePoint)
            let (adjacentWallPoint, direction) = adjacentPoints.filter {
                complexLevel.faceLevels[$0.adjacentPoint.cubeFace.rawValue].tiles[$0.adjacentPoint.x][$0.adjacentPoint.y].tileState == .wall
            }[0]
            complexLevel.faceLevels[adjacentWallPoint.cubeFace.rawValue].tiles[adjacentWallPoint.x][adjacentWallPoint.y].tileState = .inactive
            let secondAdjacentWallPoint = complexLevel.adjacentPoint(from: adjacentWallPoint, direction: direction).adjacentPoint
            complexLevel.faceLevels[secondAdjacentWallPoint.cubeFace.rawValue].tiles[secondAdjacentWallPoint.x][secondAdjacentWallPoint.y].tileState = .inactive
            complexLevel.resetLevel()
            levels.append(complexLevel)
        }        
        interruptSlides()
        unlockCubeFace()
        return levels        
    }
}


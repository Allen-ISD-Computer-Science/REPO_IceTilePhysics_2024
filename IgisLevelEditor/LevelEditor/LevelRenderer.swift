import Foundation
import Scenes
import Igis
import LevelGeneration

// Can be utilized by Edit and Play Scenes
class LevelRenderer: RenderableEntity {
   
    // LevelGeneration
    var level: Level!

    // Editable
    var levelEditor: LevelEditor? = nil

    // Player
    var playerLocation: LevelPoint? = nil
    var paintColor: Color = Color(.red)

    // Igis
    public enum RenderMode {
        case fullLevel
        case singleFace(face: Face, rotations: Int)
    }
    public var renderMode: RenderMode = .fullLevel
    let boundingBox: Rect // Full Bounding Box accreditted to LevelRenderer
    var tileSize: Size! // Default size of a tile
    
    // Igis - FullLevel
    let initialFaceBoundingBoxs: [Rect] // Used as constant to dynamically resize tiles when staging new levels
    var faceBoundingBoxs: [Rect]

    // Igis - SingleFace
    var singleFaceBoundingBox: Rect!
    var updatedFace = false
    var currentFacePoints = [[LevelPoint?]]()

    public private(set) var levelStaged = false    
    private var updateRender = true

    init(boundingBox: Rect, faceSize: Size) {
        let backFaceRect = Rect(topLeft: boundingBox.topLeft + Point(x: faceSize.width, y: 0), size: faceSize)
        let leftFaceRect = Rect(topRight: backFaceRect.bottomLeft, size: faceSize)
        let topFaceRect = Rect(topLeft: leftFaceRect.topRight, size: faceSize)
        let rightFaceRect = Rect(topLeft: topFaceRect.topRight, size: faceSize)
        let frontFaceRect = Rect(topRight: rightFaceRect.bottomLeft, size: faceSize)
        let bottomFaceRect = Rect(topLeft: frontFaceRect.bottomLeft, size: faceSize)
        self.initialFaceBoundingBoxs = [backFaceRect, leftFaceRect, topFaceRect, rightFaceRect, frontFaceRect, bottomFaceRect]
        self.faceBoundingBoxs = initialFaceBoundingBoxs
        self.boundingBox = boundingBox
        super.init(name: "LevelRenderer")
    }

    func update() {
        updateRender = true
    }

    func claimAsEditor(levelEditor: LevelEditor) {
        self.levelEditor = levelEditor
    }
    
    // Stages a level, must be called prior to setup
    func stageLevel(level: Level) {
        self.level = level
        levelStaged = true
        updateRender = true
        setupToRender(level: level)
    }

    func setupToRender(level: Level) {
        switch renderMode {
        case .fullLevel:
            self.tileSize = Size(width: initialFaceBoundingBoxs[Face.back.rawValue].size.width / level.levelSize.faceSize(face: .back).maxX,
                                 height: initialFaceBoundingBoxs[Face.back.rawValue].size.height / level.levelSize.faceSize(face: .back).maxY)
            for faceIndex in 0 ..< faceBoundingBoxs.count {
                let faceSize = level.levelSize.faceSize(face: Face.allCases[faceIndex])
                faceBoundingBoxs[faceIndex] = Rect(topLeft: initialFaceBoundingBoxs[faceIndex].topLeft,
                                                   size: Size(width: tileSize.width * faceSize.maxX, height: tileSize.height * faceSize.maxY))
            }
        case .singleFace(let face, _):            
            let singleFaceBoundingBoxSize = boundingBox.size.width < boundingBox.size.height ? Size(width: boundingBox.size.width * 2 / 3, height: boundingBox.size.width * 2 / 3) : Size(width: boundingBox.size.height * 2 / 3, height: boundingBox.size.height * 2 / 3)
            singleFaceBoundingBox = Rect(size: singleFaceBoundingBoxSize)
            singleFaceBoundingBox.center = boundingBox.center
            let currentFaceSize = level.levelSize.faceSize(face: face)
            // Tile Size will account for one extra tile, allows space for adjacent tiles on each edge
            tileSize = Size(width: singleFaceBoundingBoxSize.width / (currentFaceSize.maxX + 1),
                            height: singleFaceBoundingBoxSize.width / (currentFaceSize.maxY + 1))
        }
        
    }

    // Called by Level Editor to edit level
    func setSpecialTileType(levelPoint: LevelPoint, specialTileType: SpecialTileType?) {
        level.setSpecialTileType(levelPoint: levelPoint, specialTileType: specialTileType)
        level.resetLevel()
        updateRender = true
    }

    func setSingleFaceRenderMode(face: Face, rotations: Int) {
        guard levelStaged else {
            fatalError("Cannot change render mode prior to loading a level")
        }
        renderMode = .singleFace(face: face, rotations: rotations)
        updatedFace = true
        setupToRender(level: level)
        updateRender = true
    }
    func setFullLevelRenderMode() {
        guard levelStaged else {
            fatalError("Cannot change render mode prior to loading a level")
        }
        renderMode = .fullLevel
        setupToRender(level: level)        
        updateRender = true
    }

    
    // Render Player Location, if nil, render starting location
    func drawStar(path: Path, center: Point, spikes: Int, innerRadius: Int, outerRadius: Int) {
        var rotation = Double.pi * 3 / 2
        var x = center.x
        var y = center.y
        let angleStep = Double.pi / Double(spikes)

        for _ in 0 ..< spikes {
            x = center.x + Int(cos(rotation) * Double(outerRadius))
            y = center.y + Int(sin(rotation) * Double(outerRadius))
            path.lineTo(Point(x: x, y: y))
            rotation += angleStep

            x = center.x + Int(cos(rotation) * Double(innerRadius))
            y = center.y + Int(sin(rotation) * Double(innerRadius))
            path.lineTo(Point(x: x, y: y))
            rotation += angleStep                    
        }
        path.lineTo(Point(x: center.x, y: center.y - outerRadius))
        path.close()                
    }
    

    override func render(canvas: Canvas) {
        if levelStaged, updateRender {            
            switch renderMode {
            case .fullLevel:
                for faceIndex in 0 ..< Face.allCases.count {
                    for x in 0 ..< level.faceLevels[faceIndex].tiles.count {
                        for y in 0 ..< level.faceLevels[faceIndex].tiles[x].count {
                            let tile = level.faceLevels[faceIndex].tiles[x][y]
                            let tileRect = Rect(topLeft: faceBoundingBoxs[faceIndex].topLeft +
                                                  Point(x: x * tileSize.width, y: y * tileSize.height),
                                                size: tileSize)                        
                            let tileRectangle = Rectangle(rect: tileRect,
                                                          fillMode: .fillAndStroke)
                            // Styles
                            canvas.render(FillStyle(color: tileToColor(tile: tile)),
                                          StrokeStyle(color: Color(.black)),
                                          LineWidth(width: 1))
                            // Rectangle
                            canvas.render(tileRectangle)                        
                        }
                    }
                }            

                // Render Paths on top of Grid
                // Render SpecialTileType paths that lie on the tile
                for (levelPoint, associatedSpecialTileData) in level.associatedSpecialData {
                    if let directionPair = associatedSpecialTileData as? DirectionPair {
                        renderSpecialTileDataPath(to: canvas, specialTileType: .directionShift(pair: directionPair), tileRect: tileRect(levelPoint))
                    }
                    if let destination = associatedSpecialTileData as? LevelPoint {
                        renderSpecialTileDataPath(to: canvas, specialTileType: .portal(to: destination), tileRect: tileRect(destination))
                    }
                }
                // If claimed by editor, render selected tile
                if let levelEditor = levelEditor,
                   let selectedTilePoint = levelEditor.selectedTile?.point {
                    let selectionPath = Path(rect: tileRect(selectedTilePoint))
                    canvas.render(LineWidth(width: 3), StrokeStyle(color: Color(.red)), selectionPath)            
                }

                let playerPath = Path(fillMode: .fillAndStroke)
                drawStar(path: playerPath, center: tileRect(playerLocation ?? level.startingPosition).center, spikes: 5,
                         innerRadius: tileSize.height / 2 - 7, outerRadius: tileSize.height / 2 - 2)
                canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                              FillStyle(color: Color(.yellow)), playerPath)
            

            case .singleFace(let currentFace, let rotationCount):

                if updatedFace {
                    var levelPoints: [[LevelPoint?]] = level.faceLevels[currentFace.rawValue].tiles.map { $0.map { $0.point } }
                    let (upFace, upNewDirection, _) = Level.crossEdgeMap(Edge(currentFace, .up))
                    let upBorderPoints = level.faceLevels[upFace.rawValue].borderPointsByDirection(upNewDirection.toggle(), reversed: isReversed(.up, upNewDirection))
                    let (downFace, downNewDirection, _) = Level.crossEdgeMap(Edge(currentFace, .down))
                    let downBorderPoints = level.faceLevels[downFace.rawValue].borderPointsByDirection(downNewDirection.toggle(), reversed: isReversed(.down, downNewDirection))
                    let (leftFace, leftNewDirection, _) = Level.crossEdgeMap(Edge(currentFace, .left))
                    let leftBorderPoints = level.faceLevels[leftFace.rawValue].borderPointsByDirection(leftNewDirection.toggle(), reversed: isReversed(.left, leftNewDirection))
                    let (rightFace, rightNewDirection, _) = Level.crossEdgeMap(Edge(currentFace, .right))
                    let rightBorderPoints = level.faceLevels[rightFace.rawValue].borderPointsByDirection(rightNewDirection.toggle(), reversed: isReversed(.right, rightNewDirection))

                    // Determines whether the border points should be reversed based on arbitrary coordinate system
                    func isReversed(_ directionOne: Direction, _ directionTwo: Direction) -> Bool {
                        switch (directionOne, directionTwo) {
                        case (.down, .right): return true
                        case (.left, .up): return true
                        case (.up, .left): return true
                        case (.right, .down): return true
                        case (.left, .right): return true
                        case (.right, .left): return true
                        default: return false                    
                        }
                    }
                    
                    for x in 0 ..< levelPoints.count {
                        guard upBorderPoints.count == downBorderPoints.count,
                              upBorderPoints.count == levelPoints.count else {
                            fatalError("Border Points count must be equal.")
                        }
                        levelPoints[x].insert(upBorderPoints[x], at: 0)
                        levelPoints[x].append(downBorderPoints[x])                        
                    }
                    
                    // Prepend/append leftBorderPoints and rightborderpoints respectively, add nil values as placeholders at the start and end of the array for the purpose of iteration
                    levelPoints.insert([nil] + leftBorderPoints + [nil], at: 0)
                    levelPoints.append([nil] + rightBorderPoints + [nil])
                    updatedFace = false
                    self.currentFacePoints = levelPoints.rotateClockwise(times: rotationCount)
                }

                // Add 2 to maxX and maxY to account for borderPoints
                var currentPoint: Point = singleFaceBoundingBox.topLeft
                
                for x in 0 ..< currentFacePoints.count {
                    
                    let isXBorder: Bool = (x == 0) || (x == currentFacePoints.count - 1)
                    
                    for y in 0 ..< currentFacePoints[x].count {
                        
                        let isYBorder: Bool = (y == 0) || (y == currentFacePoints[x].count - 1)

                        if let levelPoint = currentFacePoints[x][y] {
                            let tile = level.faceLevels[levelPoint.face.rawValue].tiles[levelPoint.x][levelPoint.y]
                            let tileRect = Rect(topLeft: currentPoint,
                                                size: Size(width: isXBorder ? tileSize.width / 2 : tileSize.width,
                                                           height: isYBorder ? tileSize.height / 2 : tileSize.height))
                            let tileRectangle = Rectangle(rect: tileRect, fillMode: .fillAndStroke)
                            let tileColor = tileToColor(tile: tile)
                            canvas.render(FillStyle(color: tileColor), StrokeStyle(color: Color(.black)),
                                          LineWidth(width: 1), tileRectangle)

                            if let associatedSpecialTileData = level.associatedSpecialData[levelPoint] {
                                if let directionPair = associatedSpecialTileData as? DirectionPair {
                                    renderSpecialTileDataPath(to: canvas,
                                                              specialTileType: .directionShift(pair: DirectionPair(directionPair.exitOne.rotatedClockwise(times: rotationCount),
                                                                                                                   directionPair.exitTwo.rotatedClockwise(times: rotationCount))!),
                                                              tileRect: tileRect)
                                }
                                if let portalDestination = associatedSpecialTileData as? LevelPoint {
                                    renderSpecialTileDataPath(to: canvas, specialTileType: .portal(to: portalDestination), tileRect: tileRect)
                                }
                            }

                            if (playerLocation ?? level.startingPosition) == levelPoint {
                                let playerPath = Path(fillMode: .fillAndStroke)
                                drawStar(path: playerPath, center: tileRect.center,
                                         spikes: 5,
                                         innerRadius: tileSize.height / 2 - 7, outerRadius: tileSize.height / 2 - 2)
                                canvas.render(FillStyle(color: Color(.yellow)), StrokeStyle(color: Color(.black)),
                                              LineWidth(width: 1), playerPath)
                            }
                        }
                        currentPoint += Point(x: 0, y: isYBorder ? tileSize.height / 2 : tileSize.height)
                    }
                    currentPoint.y = singleFaceBoundingBox.topLeft.y
                    currentPoint += Point(x: isXBorder ? tileSize.width / 2 : tileSize.width, y: 0)
                }
                updateRender = false
            }
        }        
    }

    func tileToColor(tile: Tile) -> Color {
        if let specialTileType = tile.specialTileType {
            switch specialTileType {
            case .wall: return Color(.black)
            case .portal: return Color(.lightblue)
            case .sticky: return Color(.lightgreen)
            default: break // Special Tile Types that have no color to indicate their type
            }
        }
        switch tile.tileStatus {
        case .paintable: return Color(.yellow)
        case .nonPaintable, .unpainted: return Color(.gray)
        case .critical: return Color(.purple)
        case .painted: return paintColor
        }
    }

    func tileRect(_ levelPoint: LevelPoint) -> Rect {
        return Rect(topLeft: faceBoundingBoxs[levelPoint.face.rawValue].topLeft +
                      Point(x: levelPoint.x * tileSize.width, y: levelPoint.y * tileSize.height),
                    size: tileSize)                                                            
    }

    func renderSpecialTileDataPath(to canvas: Canvas, specialTileType: SpecialTileType, tileRect: Rect) {
        switch specialTileType {
        case .directionShift(let directionPair):
            let directionShiftPath = directionShiftPath(directionPair: directionPair, tileRect: tileRect)
            canvas.render(StrokeStyle(color: Color(.black)), FillStyle(color: Color(.black)), directionShiftPath)
        case .portal:
            let portalPath = Path(fillMode: .fillAndStroke)
            portalPath.arc(center: tileRect.center, radius: tileRect.size.width / 3)
            canvas.render(StrokeStyle(color: Color(.black)), FillStyle(color: Color(.lightblue)), portalPath)
        default: return
        }
    }

    func directionShiftPath(directionPair: DirectionPair, tileRect: Rect) -> Path {
        let path = Path(fillMode: .fillAndStroke)
        switch (directionPair.exitOne, directionPair.exitTwo) {
        case (.left, .up), (.up, .left):
            path.moveTo(tileRect.bottomLeft)
            path.lineTo(tileRect.bottomRight)
            path.lineTo(tileRect.topRight)
            path.arc(center: tileRect.topLeft, radius: tileRect.size.height, startAngle: 0, endAngle: Double.pi / 2)
        case (.left, .down), (.down, .left):
            path.moveTo(tileRect.bottomRight)
            path.lineTo(tileRect.topRight)
            path.lineTo(tileRect.topLeft)
            path.arc(center: tileRect.bottomLeft, radius: tileRect.size.width, startAngle: Double.pi * 3 / 2, endAngle: 0)
        case (.right, .up), (.up, .right):
            path.moveTo(tileRect.topLeft)
            path.lineTo(tileRect.bottomLeft)
            path.lineTo(tileRect.bottomRight)
            path.arc(center: tileRect.topRight, radius: tileRect.size.height, startAngle: Double.pi / 2, endAngle: Double.pi)
        case (.right, .down), (.down, .right):
            path.moveTo(tileRect.topRight)
            path.lineTo(tileRect.topLeft)
            path.lineTo(tileRect.bottomLeft)
            path.arc(center: tileRect.bottomRight, radius: tileRect.size.width, startAngle: Double.pi, endAngle: Double.pi * 3 / 2)
        default:
            fatalError("Cannot have DirectionPair with opposite directions.")
        }
        return path
    }
}

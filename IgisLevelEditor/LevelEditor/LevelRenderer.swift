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
    var paintColor: Color? = nil

    // Igis
    let initialFaceBoundingBoxs: [Rect] // Used as constant to dynamically resize tiles when staging new levels
    var faceBoundingBoxs: [Rect]
    var tileSize: Size!

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

        self.tileSize = Size(width: initialFaceBoundingBoxs[Face.back.rawValue].size.width / level.levelSize.faceSize(face: .back).maxX,
                             height: initialFaceBoundingBoxs[Face.back.rawValue].size.height / level.levelSize.faceSize(face: .back).maxY)
        for faceIndex in 0 ..< faceBoundingBoxs.count {
            let faceSize = level.levelSize.faceSize(face: Face.allCases[faceIndex])
            faceBoundingBoxs[faceIndex] = Rect(topLeft: initialFaceBoundingBoxs[faceIndex].topLeft,
                                               size: Size(width: tileSize.width * faceSize.maxX, height: tileSize.height * faceSize.maxY))
        }
    }

    // Called by Level Editor to edit level
    func setSpecialTileType(levelPoint: LevelPoint, specialTileType: SpecialTileType?) {
        level.setSpecialTileType(levelPoint: levelPoint, specialTileType: specialTileType)
        level.resetLevel()
        updateRender = true
    }

    override func render(canvas: Canvas) {
        if levelStaged, updateRender {
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
            let playerPath = Path(fillMode: .fillAndStroke)
            drawStar(path: playerPath, center: tileRect(playerLocation ?? level.startingPosition).center, spikes: 5,
                     innerRadius: tileSize.height / 2 - 7, outerRadius: tileSize.height / 2 - 2)
            canvas.render(StrokeStyle(color: Color(.black)), LineWidth(width: 1),
                          FillStyle(color: Color(.yellow)), playerPath)
            updateRender = false
        }
    }

    func tileToColor(tile: Tile) -> Color {
        if let specialTileType = tile.specialTileType {
            switch specialTileType {
            case .wall: return Color(.black)
            case .directionShift: return Color(.orange)
            case .portal: return Color(.lightblue)
            case .sticky: return Color(.lightgreen)
            }
        }
        switch tile.tileStatus {
        case .paintable:
            if let color = paintColor {
                return color
            }
            return Color(.yellow)
        case .nonPaintable: return Color(.gray)
        case .critical:
            if let color = paintColor {
                return color
            }
            return Color(.purple)
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

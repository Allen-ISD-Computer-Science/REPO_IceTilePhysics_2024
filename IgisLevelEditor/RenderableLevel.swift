import Igis
import Scenes
import LevelGeneration

class RenderableLevel: RenderableEntity {
    let level: Level
    private var updatedLevel = true

    // Private variable that stores the size of a single square tile on a renderable level
    private var tileSize = Size(width: 20, height: 20)
    private var faceLevelRects: [Rect] = []
    
    init(level: Level) {
        self.level = level
        super.init(name:"RenderableLevel")
    }
    
    // Setup
    override func setup(canvasSize: Size, canvas: Canvas) {
        let center = Point(x: canvasSize.width / 2, y: canvasSize.height / 2)
        faceLevelRects = faceLevelRects(center: center)
        canvas.render(StrokeStyle(color: Color(.black)))
    }

    // Setup Functions
    // Function that returns the size of a bounding box for a face on a level
    func faceLevelSize(cubeFace: CubeFace) -> Size {
        let faceSize = level.levelSize.faceSize(cubeFace: cubeFace)
        return Size(width: tileSize.width * faceSize.maxX, height: tileSize.height * faceSize.maxY)
    }

    // Returns an array of Rect that contain the topLeft Point and Size of each FaceLevel
    func faceLevelRects(center: Point) -> [Rect] {
        // CubeFace.allCases = [.back, .left, .top, .right, .front, .bottom]
        let faceSizes: [Size] = CubeFace.allCases.map { faceLevelSize(cubeFace: $0) }
        let faceTopLefts = {
            // Center Point is located closest to the Front face topLeft, located half of the width of the top to the left
            let frontTopLeft = center - Point(x: faceSizes[4].width / 2, y: 0)
            // Bottom is full height of Front down
            let bottomTopLeft = frontTopLeft + Point(x: 0, y: faceSizes[4].height)
            // Top is full height of Top up
            let topTopLeft = frontTopLeft - Point(x: 0, y: faceSizes[2].height)
            // Left is full width of Left left
            let leftTopLeft = topTopLeft - Point(x: faceSizes[1].width, y: 0)
            // Right is full width of Top right
            let rightTopLeft = topTopLeft + Point(x: faceSizes[2].width, y: 0)
            // Back is full height of Back up
            let backTopLeft = topTopLeft - Point(x: 0, y: faceSizes[0].height)
            return [backTopLeft, leftTopLeft, topTopLeft, rightTopLeft, frontTopLeft, bottomTopLeft]
        }()
        return zip(faceTopLefts, faceSizes).map { Rect(topLeft: $0, size: $1) }
    }

    // Calculate
    override func calculate(canvasSize: Size) {
        
    }

    // Render
    override func render(canvas: Canvas) {

        if updatedLevel {
            for cubeFace in CubeFace.allCases {
                let faceTopLeft = faceLevelRects[cubeFace.rawValue].topLeft
                let faceLevelTiles = level.faceLevels[cubeFace.rawValue].tiles
                let colorGrid = tilesToColorGrid(tiles: faceLevelTiles)
                for tileColumnIndex in 0 ..< faceLevelTiles.count {
                    for tileRowIndex in 0 ..< faceLevelTiles[tileColumnIndex].count {
                        canvas.render(FillStyle(color: colorGrid[tileColumnIndex][tileRowIndex]))
                        let tileTopLeft = faceTopLeft + Point(x: tileColumnIndex * tileSize.width, y: tileRowIndex * tileSize.height)
                        let tileRect = Rect(topLeft: tileTopLeft, size: tileSize)
                        canvas.render(Rectangle(rect: tileRect, fillMode: .fillAndStroke))
                    }
                }
            }
            updatedLevel = false
        }

    }

    // Render Functions
    func tilesToColorGrid(tiles: [[Tile]]) -> [[Color]] {
        let colorGrid: [[Color]] = tiles.map { tileColumn in
            tileColumn.map { tile in
                switch tile.tileState {
                case .active:
                    return Color(.yellow)
                case .critical:
                    return Color(.purple)
                case .wall:
                    return Color(.black)
                case .inactive:
                    return Color(.gray)                    
                }
            }
        }
        return colorGrid
    }
}

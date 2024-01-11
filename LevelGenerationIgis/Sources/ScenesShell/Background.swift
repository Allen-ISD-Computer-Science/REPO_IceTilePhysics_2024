import Scenes
import Igis

  /*
     This class is responsible for rendering the background.
   */


class Background : RenderableEntity {
    typealias RenderableGrid = (rectGrid: [[Rect]], colorGrid: [[Color.Name]])

    static let gridRectSize = Size(width: 30, height: 30)
    static let gridRectStartingPoint = Point(x: 100, y: 100)

    let levelRandomizer: LevelRandomizer
    let topTopLevelseed: CubeFaceLevel
    var topLevels: [CubeFaceLevel]
    var renderableGrids = [RenderableGrid]()

    private var levelIndex = 0

    static let tileStateToColorNameMap: [TileState: Color.Name] = [
      .wall: .black,
      .critical: .purple,
      .active: .yellow,
      .inactive: .gray
    ]

    init() {
        LevelRandomizer.initialize()
        guard let levelRandomizer = LevelRandomizer.shared else {
            fatalError("Level Radomizer must be initialized prior to being used.")
        }
        self.levelRandomizer = levelRandomizer

        let topLevelseed = CubeFaceLevel(size: GridSize(sideLength: 11), startingPosition: GridPoint(x: 1, y: 1), cubeFace: .top)
        self.topTopLevelseed = topLevelseed
        let complexCubeFaceTopLevels = levelRandomizer.createComplexCubeFaceLevels(seed: topLevelseed)
        self.topLevels = complexCubeFaceTopLevels
        
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")
    }

    func levelToRenderGrid(level: CubeFaceLevel) -> RenderableGrid {
            var rectGrid = [[Rect]]()
            var colorGrid = [[Color.Name]]()
            for tileColumnIndex in 0 ..< level.size.width {
                var rectColumn = [Rect]()
                var colorColumn = [Color.Name]()
                for tileIndex in 0 ..< level.size.height {
                    let rect = Rect(topLeft: Point(x: Background.gridRectStartingPoint.x + Background.gridRectSize.width * tileColumnIndex,
                                                   y: Background.gridRectStartingPoint.y + Background.gridRectSize.height * tileIndex),
                                    size: Background.gridRectSize)

                    let tileState = level.gridTiles[tileColumnIndex][tileIndex].tileState
                    guard let colorName = Background.tileStateToColorNameMap[tileState] else {
                        fatalError("Unrecognized tile state of \(tileState).")
                }
                    rectColumn.append(rect)
                    colorColumn.append(colorName)
                }
                rectGrid.append(rectColumn)
                colorGrid.append(colorColumn)
            }
            return RenderableGrid(rectGrid: rectGrid, colorGrid: colorGrid)
        }

    func incrementTopCubeFaceLevelIndex() {
        if levelIndex + 1 < topLevels.count {
            levelIndex += 1
        }
    }
    func decrementTopCubeFaceLevelIndex() {
        if levelIndex - 1 >= 0 {
            levelIndex -= 1
        }
    }
    func maxTopLevelIndex() {
        levelIndex = topLevels.count - 1
        print(topLevels.count, levelIndex)
    }
    func resetTopCubeFaceLevels() {
        levelIndex = 0
        topLevels = levelRandomizer.createComplexCubeFaceLevels(seed: topTopLevelseed)
        renderableGrids = topLevels.map { levelToRenderGrid(level: $0) }
        maxTopLevelIndex()
    }    

    override func setup(canvasSize: Size, canvas: Canvas) {
        precondition(topLevels.count > 0, "There must be topLevels to generate.")
        renderableGrids = topLevels.map { levelToRenderGrid(level: $0) }
        precondition(topLevels.count == renderableGrids.count, "The amount of topLevels, amount of rect grids, and amount of colors, must all be equal.")
        let strokeStyle = StrokeStyle(color: Color(.black))
        canvas.render(strokeStyle)
        levelIndex = topLevels.count - 1
    }

    override func render(canvas: Canvas) {

        if let canvasSize = canvas.canvasSize {
            let clearRectangle = Rectangle(rect: Rect(size: canvasSize), fillMode: .clear)
            canvas.render(clearRectangle)
            let levelText = Text(location: Point(x: 300, y: 25), text: "CubeFaceLevel \(levelIndex + 1) of \(topLevels.count)", fillMode: .stroke)
            canvas.render(levelText)
            func renderCubeFaceLevel(levelIndex: Int) {
                let renderableGrid = renderableGrids[levelIndex]
                let rectGrid = renderableGrid.rectGrid
                let colorGrid = renderableGrid.colorGrid


                for x in 0 ..< rectGrid.count {
                    for y in 0 ..< rectGrid[x].count {
                        let fillStyle = FillStyle(color: Color(colorGrid[x][y]))
                        let rectangle = Rectangle(rect: rectGrid[x][y], fillMode: .fillAndStroke)
                        canvas.render(fillStyle, rectangle)
                    }
                }
            }

            renderCubeFaceLevel(levelIndex: levelIndex)
        }
    }
}

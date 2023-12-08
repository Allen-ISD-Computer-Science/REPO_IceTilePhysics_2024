import Scenes
import Igis

  /*
     This class is responsible for rendering the background.
   */


class Background : RenderableEntity {

    static let gridRectSize = Size(width: 30, height: 30)
    static let gridRectStartingPoint = Point(x: 100, y: 100)

    let levelRandomizer: LevelRandomizer
    let levelSeed: Level
    var levels: [Level]
    let rectGrids: [[[Rect]]]
    let colorGrids: [[[Color.Name]]]

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

        let levelSeed = Level(size: GridSize(sideLength: 11), startingPosition: GridPoint(x: 1, y: 1))
        self.levelSeed = levelSeed
        let complexLevels = levelRandomizer.createComplexLevels(seed: levelSeed)
        self.levels = complexLevels

        func levelToRenderGrids(level: Level) -> (rectGrid: [[Rect]], colorGrid: [[Color.Name]]) {
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
            return (rectGrid, colorGrid)
        }
        let renderGrids = complexLevels.map { levelToRenderGrids(level: $0) }
        self.rectGrids = renderGrids.map { $0.rectGrid }
        self.colorGrids = renderGrids.map { $0.colorGrid }
        
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")
    }

    func incrementLevelIndex() {
        if levelIndex + 1 < levels.count {
            levelIndex += 1
        }
    }
    func decrementLevelIndex() {
        if levelIndex - 1 >= 0 {
            levelIndex -= 1
        }
    }
    func resetLevels() {
        levelIndex = 0
        levels = levelRandomizer.createComplexLevels(seed: levelSeed)
    }

    override func setup(canvasSize: Size, canvas: Canvas) {
        precondition(levels.count > 0, "There must be levels to generate.")
        precondition(levels.count == rectGrids.count &&
                       levels.count == colorGrids.count, "The amount of levels, amount of rect grids, and amount of colors, must all be equal.")
        
        let strokeStyle = StrokeStyle(color: Color(.black))
        canvas.render(strokeStyle)
        levelIndex = levels.count - 1
    }

    override func render(canvas: Canvas) {

        if let canvasSize = canvas.canvasSize {
            let clearRectangle = Rectangle(rect: Rect(size: canvasSize), fillMode: .clear)
            canvas.render(clearRectangle)
            let levelText = Text(location: Point(x: 300, y: 25), text: "Level \(levelIndex + 1) of \(levels.count)", fillMode: .stroke)
            canvas.render(levelText)
            func renderLevel(levelIndex: Int) {
                let rectGrid = rectGrids[levelIndex]
                let colorGrid = colorGrids[levelIndex]

                for x in 0 ..< rectGrid.count {
                    for y in 0 ..< rectGrid[x].count {
                        let fillStyle = FillStyle(color: Color(colorGrid[x][y]))
                        let rectangle = Rectangle(rect: rectGrid[x][y], fillMode: .fillAndStroke)
                        canvas.render(fillStyle, rectangle)
                    }
                }
            }

            renderLevel(levelIndex: levelIndex)
        }
    }
}

import Scenes
import Igis

  /*
     This class is responsible for rendering the background.
   */


class Background : RenderableEntity {
    typealias RenderableGrid = (rectGrid: [[Rect]], colorGrid: [[Color.Name]])

    private var gridUpdated = true
    static let gridRectSize = Size(width: 15, height: 15)

    let levelRandomizer: LevelRandomizer
    let levelSeed: Level
    var levels: [Level]
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

        let levelseed = Level(levelSize: LevelSize(edgeLength: 11), startingPosition: LevelPoint(x: 1, y: 1, cubeFace: .back))
        self.levelSeed = levelseed
        let complexLevels = levelRandomizer.createComplexLevels(seed: levelseed)
        self.levels = complexLevels
        
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")
    }

    func levelToRenderGrid(gridRectStartingPoint: Point, level: Level) -> RenderableGrid {
        let cubeFace = level.startingPosition.cubeFace
        var rectGrid = [[Rect]]()
        var colorGrid = [[Color.Name]]()
        for tileColumnIndex in 0 ..< level.levelSize.faceSize(cubeFace: cubeFace).maxX {
            var rectColumn = [Rect]()
            var colorColumn = [Color.Name]()
            for tileIndex in 0 ..< level.levelSize.faceSize(cubeFace: cubeFace).maxY {
                let rect = Rect(topLeft: Point(x: gridRectStartingPoint.x + Background.gridRectSize.width * tileColumnIndex,
                                               y: gridRectStartingPoint.y + Background.gridRectSize.height * tileIndex),
                                size: Background.gridRectSize)
                let tileState = level.faceLevels[level.startingPosition.cubeFace.rawValue].tiles[tileColumnIndex][tileIndex].tileState
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
    func maxLevelIndex() {
        levelIndex = levels.count - 1
        print(levels.count, levelIndex)
    }
    func resetLevels() {
        levelIndex = 0
        levels = levelRandomizer.createComplexLevels(seed: levelSeed)
        gridUpdated = true
        maxLevelIndex()
    }
    
    override func setup(canvasSize: Size, canvas: Canvas) {
        precondition(levels.count > 0, "There must be levels to generate.")
        precondition(levels.count == renderableGrids.count, "The amount of levels, amount of rect grids, and amount of colors, must all be equal.")

        // set StrokeStyle to Black
        let strokeStyle = StrokeStyle(color: Color(.black))
        canvas.render(strokeStyle)

        // Set levelIndex to Max        
        levelIndex = levels.count - 1
    }

    override func calculate(canvasSize: Size) {
        if gridUpdated {
            let gridRectStartingPoint = Point(x: canvasSize.width / 2, y: 100)
            renderableGrids = levels.map { levelToRenderGrid(gridRectStartingPoint: gridRectStartingPoint, level: $0) }
            gridUpdated = false
        }
    }

    override func render(canvas: Canvas) {

        if let canvasSize = canvas.canvasSize {

            let clearRectangle = Rectangle(rect: Rect(size: canvasSize), fillMode: .clear)
            canvas.render(clearRectangle)
            let levelText = Text(location: Point(x: 300, y: 25), text: "CubeFaceLevel \(levelIndex + 1) of \(levels.count)", fillMode: .stroke)
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

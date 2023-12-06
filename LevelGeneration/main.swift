func main() {
    let grid = Level(size: Size(sideLength: 7), startingPosition: Point(x: 1, y: 1))
    grid.printGrid()
    print("Level is solvable? \(grid.solvable())")
}

main()

struct Size {
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init(sideLength: Int) {
        self.width = sideLength
        self.height = sideLength
    }
}

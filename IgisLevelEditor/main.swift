import Igis

class Painter: PainterBase {
    required init() {
    }

    override func setup(canvas: Canvas) {
    }
}

print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:Painter.self)
} catch (let error) {
    print("Error: \(error)")
}

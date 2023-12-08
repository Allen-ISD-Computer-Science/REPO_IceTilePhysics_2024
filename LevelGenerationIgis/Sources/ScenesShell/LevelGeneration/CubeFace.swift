public enum CubeFace {
    case top
    case bottom
    case front
    case back
    case left
    case right

    static let cubeFacePointers: [CubeFace: [Direction: CubeFace]] = [
      .top: [
        .up: .back,
        .down: .front,
        .left: .left,
        .right: .right    
      ],
      .bottom: [
        .up: .front,
        .down: .back,
        .left: .left,
        .right: .right
      ],
      .front: [
        .up: .top,
        .down: .bottom,
        .left: .left,
        .right: .right
      ],
      .back: [
        .up: .top,
        .down: .bottom,
        .left: .right,
        .right: .left
      ],
      .left: [
        .up: .top,
        .down: .bottom,
        .left: .back,
        .right: .front
      ],
      .right: [
        .up: .top,
        .down: .bottom,
        .left: .front,
        .right: .back
      ]
    ]
}

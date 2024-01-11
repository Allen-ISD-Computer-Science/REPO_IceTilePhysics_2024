public enum CubeFace: Int { // Represents a face on the cube, associated values correspond to the order in which faces appear in an array    

    case back = 0
    case left = 1
    case top = 2
    case right = 3
    case front = 4
    case bottom = 5
    
    static let cubeFacePointers: [CubeFace: [Direction: CubeFace]] = [
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
      .top: [
        .up: .back,
        .down: .front,
        .left: .left,
        .right: .right    
      ],
      .right: [
        .up: .top,
        .down: .bottom,
        .left: .front,
        .right: .back
      ],
      .front: [
        .up: .top,
        .down: .bottom,
        .left: .left,
        .right: .right
      ],
      .bottom: [
        .up: .front,
        .down: .back,
        .left: .left,
        .right: .right
      ]      
    ]
}

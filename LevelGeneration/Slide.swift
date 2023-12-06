struct Slide {    
    let origin: Point
    let destination: Point

    let activatedTilePoints: [Point]
}

extension Slide: Hashable, Equatable {    

    public static func ==(lhs: Slide, rhs: Slide) -> Bool {
        return lhs.origin == rhs.origin &&
          lhs.destination == rhs.destination &&
          lhs.activatedTilePoints == rhs.activatedTilePoints       
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(destination)
        hasher.combine(activatedTilePoints)
    }
}

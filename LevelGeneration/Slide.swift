struct Slide { // Represents a "slide" that connects two critical points
    let origin: Point // Where the slide begins
    let destination: Point // Where the slide ends

    let activatedTilePoints: [Point] // All of the points along the slide other than the origin and destination
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

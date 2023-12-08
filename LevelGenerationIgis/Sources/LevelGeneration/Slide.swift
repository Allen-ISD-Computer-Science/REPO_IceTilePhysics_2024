public struct Slide { // Represents a "slide" that connects two critical points
    let origin: GridPoint // Where the slide begins
    let destination: GridPoint // Where the slide ends

    let activatedTileGridPoints: [GridPoint] // All of the points along the slide other than the origin and destination
}

extension Slide: Hashable, Equatable {    

    public static func ==(lhs: Slide, rhs: Slide) -> Bool {
        return lhs.origin == rhs.origin &&
          lhs.destination == rhs.destination &&
          lhs.activatedTileGridPoints == rhs.activatedTileGridPoints       
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(destination)
        hasher.combine(activatedTileGridPoints)
    }
}

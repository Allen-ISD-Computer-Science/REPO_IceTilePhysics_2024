public struct Slide { // Represents a "slide" that connects two critical points
    public let origin: LevelPoint // Where the slide begins
    public let destination: LevelPoint // Where the slide ends
    
    public let activatedTilePoints: [LevelPoint] // All of the points along the slide other than the origin and destination

    /*
    private var protected = false // A slide is protected when it is manually created rather than randomly generated
    
    mutating func protectSlide() {
        protected = true
        }
        
     */
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

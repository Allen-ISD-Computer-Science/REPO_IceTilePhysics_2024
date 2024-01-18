struct Graph { // Represents the relationship between slides on a level grid
    private var slides = Set<Slide>()

    mutating func insertSlide(_ slide: Slide) {
        slides.insert(slide)
    }

    mutating func clearGraph() {
        slides = []
    }
    
    func breadthFirstSearch(origin: LevelPoint, destination: LevelPoint) -> [Slide]? {
        var stack: [LevelPoint] = [origin]

        enum Visit {
            case origin
            case slide(Slide)
        }

        var visits: Dictionary<LevelPoint, Visit> = [origin: .origin]

        while let currentLevelPoint = stack.popLast() { // Gather a point and remove it from the stack
            if currentLevelPoint == destination { // If we have made it to the destination
                var point = destination // Used to traverse visits dictionary
                var route: [Slide] = [] // route taken to get from origin to destination

                while let visit = visits[point], case .slide(let slide) = visit { // Gather visit from the visits dictionary, must be a slide
                    route = [slide] + route // Prepdestination the slide onto the route, order must be reverse (destination -> origin)                    
                    point = slide.origin // change point to the origin of the slide to continue traversing the dictionary
                }
                return route
            }
            // If we haven't made it to the destination, continue to explore slides from current point breadth first
            let slidesFromOrigin = slides.filter { $0.origin == currentLevelPoint }
            for slide in slidesFromOrigin {
                if visits[slide.destination] == nil { // Only add points to explore if we haven't already visited them
                    stack.append(slide.destination) // Add the destination as a place to be explored
                    visits[slide.destination] = .slide(slide) // Tell the visits dictionary how we got here
                }
            }
        }
        return nil // Will return nil once all points have been explored and the destination has not been reached
    }
}

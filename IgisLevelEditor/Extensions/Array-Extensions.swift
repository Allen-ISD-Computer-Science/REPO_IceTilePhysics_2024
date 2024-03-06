extension Array where Element: Collection {
    var isRectangular: Bool {
        guard let firstRowLength = self.first?.count else {
            return true // An empty array is considered Rectangular
        }
        return self.allSatisfy { $0.count == firstRowLength }
    }
}

extension Array where Element: Collection, Element.Index == Int, Element.Iterator.Element: Equatable {
    func rotateClockwise() -> [[Element.Iterator.Element]] {
        guard let firstRow = self.first else { return [] }
        var rotated: [[Element.Iterator.Element]] = []

        // Start iterating from the last column to the first
        for columnIndex in stride(from: firstRow.count - 1, through: 0, by: -1) {
            var newRow: [Element.Iterator.Element] = []
            // Iterate through rows from first to last
            for rowIndex in 0..<self.count {
                let element = self[rowIndex][columnIndex]
                newRow.append(element)
            }
            rotated.append(newRow)
        }

        return rotated
    }

    func rotateClockwise(times: Int) -> [[Element.Iterator.Element]] {
        guard times > 0 else { return self as? [[Element.Iterator.Element]] ?? [] }

        var rotatedArray = self
        for _ in 0..<times {
            rotatedArray = rotatedArray.rotateClockwise() as! [Element]
        }

        return rotatedArray as? [[Element.Iterator.Element]] ?? []
    }
}

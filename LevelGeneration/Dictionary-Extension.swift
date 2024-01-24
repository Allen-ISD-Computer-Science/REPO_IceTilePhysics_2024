extension Dictionary where Value: Equatable {
    func allKeysForValue(value: Value) -> [Key] {
        return self.filter { $0.value == value}.map { $0.key }
    }
}

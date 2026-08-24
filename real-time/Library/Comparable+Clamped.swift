extension Comparable {
    /// Confines a value to a range. Clearer at the call site than a nested
    /// `min(max(_:_:)_:)`, which reads backwards.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

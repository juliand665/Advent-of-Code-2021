public func autoFlippedRange(_ a: Int, _ b: Int) -> [Int] {
	a <= b ? Array(a...b) : (b...a).reversed()
}

extension Optional {
	@inlinable
	public mutating func take() -> Self {
		if let wrapped = self {
			self = nil
			return wrapped
		} else {
			return self
		}
	}
}

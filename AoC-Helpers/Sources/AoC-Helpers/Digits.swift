extension BinaryInteger where Stride: SignedInteger {
	@inlinable
	public func digits(base: Self = 10) -> [Self] {
		Array(sequence(state: self) { rest -> Self? in
			guard rest > 0 else { return nil }
			let remainder: Self
			(rest, remainder) = rest.quotientAndRemainder(dividingBy: base)
			return remainder
		}).reversed()
	}
	
	@inlinable
	public init<S: Sequence>(digits: S, base: Self = 10) where S.Element == Self {
		self = digits.reduce(0) { $0 * base + $1 }
	}
	
	@inlinable
	public var bits: [Bool] {
		digits(base: 2).map { $0 == 1 }
	}
	
	@inlinable
	public init<S: Sequence>(bits: S) where S.Element == Bool {
		self = bits.reduce(0) { $0 << 1 | ($1 ? 1 : 0) }
	}
}

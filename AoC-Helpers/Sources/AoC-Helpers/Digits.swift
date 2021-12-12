extension BinaryInteger where Stride: SignedInteger {
	public func digits(base: Self = 10) -> [Self] {
		Array(sequence(state: self) { rest -> Self? in
			guard rest > 0 else { return nil }
			let remainder: Self
			(rest, remainder) = rest.quotientAndRemainder(dividingBy: base)
			return remainder
		}).reversed()
	}
	
	public init(digits: [Self], base: Self = 10) {
		self = digits.reduce(0) { $0 * base + $1 }
	}
}

extension Sequence {
	public func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		try lazy.filter(isIncluded).count
	}
	
	func sorted<C>(on accessor: (Element) -> C) -> [Element] where C: Comparable {
		self
			.map { ($0, accessor($0)) }
			.sorted { $0.1 < $1.1 }
			.map { $0.0 }
	}
}


extension Sequence where Element: Equatable {
	public func count(of element: Element) -> Int {
		count { $0 == element }
	}
}

extension Sequence where Element: Hashable {
	public func mostCommonElement() -> Element? {
		let counts = Dictionary(lazy.map { ($0, 1) }, uniquingKeysWith: +)
		let descending = counts.sorted { -$0.value }
		guard descending.count > 1 else { return descending.first?.key }
		guard descending[0].value > descending[1].value else { return nil }
		return descending.first!.key
	}
}

extension Collection where Element: Collection, Index == Element.Index {
	public func transposed() -> [[Element.Element]] {
		first!.indices.map { i in map { $0[i] } }
	}
}

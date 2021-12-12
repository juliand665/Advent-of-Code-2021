extension Sequence {
	public func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		try lazy.filter(isIncluded).count
	}
	
	public func sorted<C>(on accessor: (Element) -> C) -> [Element] where C: Comparable {
		self
			.map { ($0, accessor($0)) }
			.sorted { $0.1 < $1.1 }
			.map { $0.0 }
	}
	
	public func onlyElement(where isIncluded: (Element) throws -> Bool) rethrows -> Element? {
		try filter(isIncluded).onlyElement()
	}
}

extension Sequence where Element: AdditiveArithmetic {
	public func sum() -> Element {
		reduce(.zero, +)
	}
}

extension Sequence where Element: Equatable {
	public func count(of element: Element) -> Int {
		count { $0 == element }
	}
}

extension Sequence where Element: Hashable {
	public func occurrenceCounts() -> [Element: Int] {
		Dictionary(lazy.map { ($0, 1) }, uniquingKeysWith: +)
	}
	
	public func mostCommonElement() -> Element? {
		let counts = occurrenceCounts()
		let descending = counts.sorted { -$0.value }
		guard descending.count > 1 else { return descending.first?.key }
		guard descending[0].value > descending[1].value else { return nil }
		return descending.first!.key
	}
}

extension Collection {
	public func onlyElement() -> Element? {
		return count == 1 ? first! : nil
	}
}

extension Collection where Element: Collection, Index == Element.Index {
	public func transposed() -> [[Element.Element]] {
		first!.indices.map { i in map { $0[i] } }
	}
}

extension MutableCollection {
	public mutating func forEachMutate(_ transform: (inout Element) -> Void) {
		// can't use self.indices because that might keep a reference to self, preventing copy-on-write!
		var index = startIndex
		while index != endIndex {
			transform(&self[index])
			index = self.index(after: index)
		}
	}
}

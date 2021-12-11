extension Sequence {
	public func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		try lazy.filter(isIncluded).count
	}
}

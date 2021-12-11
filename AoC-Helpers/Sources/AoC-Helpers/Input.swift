import Foundation

public func input(filename: String = "input") -> String {
	let url = URL(fileURLWithPath: Bundle.main.path(forResource: filename, ofType: "txt")!)
	let rawInput = try! Data(contentsOf: url)
	return String(data: rawInput, encoding: .utf8)!
}

extension String {
	public func lines() -> [Substring] {
		split(separator: "\n", omittingEmptySubsequences: false).dropLast()
	}
}

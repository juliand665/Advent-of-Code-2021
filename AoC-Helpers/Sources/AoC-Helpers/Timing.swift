import Foundation

public func measureTime<Result>(for block: () throws -> Result) rethrows -> Result {
	let start = Date()
	defer {
		print("time taken: \(-start.timeIntervalSinceNow) seconds")
	}
	
	return try block()
}

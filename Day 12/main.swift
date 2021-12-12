import AoC_Helpers
import SimpleParser

enum Cave: Hashable, Parseable {
	case start, end
	case small(String), large(String)
	
	init(from parser: inout Parser) {
		switch parser.readWord() {
		case "start":
			self = .start
		case "end":
			self = .end
		case let name:
			self = name.first!.isUppercase
			? .large(String(name))
			: .small(String(name))
		}
	}
	
	var canBeRevisited: Bool {
		guard case .large = self else { return false }
		return true
	}
	
	var isSmallCave: Bool {
		guard case .small = self else { return false }
		return true
	}
}

let paths: [(Cave, Cave)] = input().lines().map {
	var parser = Parser(reading: $0)
	let one = parser.readValue(of: Cave.self)
	parser.consume("-")
	let two = parser.readValue(of: Cave.self)
	return (one, two)
}

let connected: [Cave: Set<Cave>] = paths.reduce(into: [:]) { paths, connection in
	paths[connection.0, default: []].insert(connection.1)
	paths[connection.1, default: []].insert(connection.0)
}

typealias Path = [Cave]
func pathsToEnd(from start: Cave, visited: Set<Cave> = []) -> [Path] {
	guard start != .end else { return [[start]] }
	let newVisited = visited.union([start])
	return connected[start]!
		.filter { $0.canBeRevisited || !visited.contains($0) }
		.flatMap { pathsToEnd(from: $0, visited: newVisited) }
		.map { [start] + $0 }
}

let foundPaths = pathsToEnd(from: .start)
print(foundPaths.count, "paths found")

func pathsToEndWithRevisit(from start: Cave, hasVisitedTwice: Bool = false, visited: Set<Cave> = []) -> [Path] {
	guard start != .end else { return [[start]] }
	let newVisited = visited.union([start])
	return connected[start]!
		.flatMap { next -> [Path] in
			if next.canBeRevisited || !visited.contains(next) {
				return pathsToEndWithRevisit(from: next, hasVisitedTwice: hasVisitedTwice, visited: newVisited)
			} else if !hasVisitedTwice, next.isSmallCave {
				return pathsToEndWithRevisit(from: next, hasVisitedTwice: true, visited: newVisited)
			} else {
				return []
			}
		}
		.map { [start] + $0 }
}
let foundPathsWithRevisit = pathsToEndWithRevisit(from: .start)
print(foundPathsWithRevisit.count, "paths with double visit found")

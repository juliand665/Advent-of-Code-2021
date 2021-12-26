import AoC_Helpers
import HandyOperators
import Collections

enum AmphipodType: String, CustomStringConvertible {
	case a = "A"
	case b = "B"
	case c = "C"
	case d = "D"
	
	var costMultiplier: Int {
		switch self {
		case .a: return 1
		case .b: return 10
		case .c: return 100
		case .d: return 1000
		}
	}
	
	var roomIndex: Int {
		switch self {
		case .a: return 0
		case .b: return 1
		case .c: return 2
		case .d: return 3
		}
	}
	
	var description: String { rawValue }
}

typealias Destination = (Location, distance: Int)

struct Amphipod: Hashable {
	var type: AmphipodType
	var location: Location
	var hasMoved = false
	
	var isSolved: Bool {
		guard case .room(let position) = location else { return false }
		return position.index == type.roomIndex
	}
	
	func destinations(in state: State) -> [Destination] {
		switch location {
		case .hallway(let position):
			let top = RoomPosition(index: type.roomIndex, isTop: true)
			let entrance = top.hallwayNeighbor
			guard
				state.isFree(top),
				position.hasPath(to: entrance, in: state)
			else { return [] }
			let topWithCost = (top.asLocation, distance: abs(entrance.index - position.index) + 1)
			let bottom = top.other
			let bottomWithCost = (bottom.asLocation, topWithCost.distance + 1)
			return [topWithCost] + (state.isFree(bottom) ? [bottomWithCost] : [])
		case .room(let position):
			guard !hasMoved else { return [] }
			if !position.isTop {
				guard state.isFree(position.other) else { return [] }
			}
			let exitDistance = position.isTop ? 1 : 2
			return position.hallwayNeighbor
				.reachableNeighbors(in: state)
				.map { ($0.asLocation, distance: $1 + exitDistance) }
		}
	}
}

let hallwayLength = 11
let roomCount = 4

protocol LocationConvertible {
	var asLocation: Location { get }
}

enum Location: Hashable, LocationConvertible {
	case hallway(HallwayPosition)
	case room(RoomPosition)
	
	var asLocation: Location { self }
}

struct HallwayPosition: Hashable, LocationConvertible, CustomStringConvertible {
	static let all = (0..<hallwayLength).map(Self.init)
	
	var index: Int
	
	var asLocation: Location { .hallway(self) }
	
	var isValidDestination: Bool {
		index % 2 == 1 || index == 0 || index == hallwayLength - 1
	}
	
	var roomNeighbor: RoomPosition? {
		guard index > 1, index < hallwayLength - 2, index % 2 == 0 else { return nil }
		return RoomPosition(index: index / 2 - 1, isTop: true)
	}
	
	func reachableNeighbors(in state: State) -> [(Self, distance: Int)] {
		let left = Self.all.prefix(upTo: index).reversed().prefix(while: state.isFree)
		let right = Self.all.suffix(from: index + 1).prefix(while: state.isFree)
		return (left + right)
			.lazy
			.filter(\.isValidDestination)
			.map { ($0, distance: abs($0.index - index)) }
	}
	
	func hasPath(to other: Self, in state: State) -> Bool {
		autoFlippedRange(index, other.index).dropFirst().lazy.map(Self.init).allSatisfy(state.isFree)
	}
	
	var description: String {
		"\(index)"
	}
}

struct RoomPosition: Hashable, LocationConvertible, CustomStringConvertible {
	static let all = (0..<roomCount).flatMap { i in
		[true, false].map { Self(index: i, isTop: $0) }
	}
	
	var index: Int
	var isTop: Bool
	
	var asLocation: Location { .room(self) }
	
	var hallwayNeighbor: HallwayPosition {
		.init(index: index * 2 + 2)
	}
	
	var other: Self {
		.init(index: index, isTop: !isTop)
	}
	
	var description: String {
		"\(index) \(isTop ? "↑" : "↓")"
	}
}

struct State: Hashable, CustomStringConvertible {
	var occupation: [Location: Amphipod]
	
	var isSolved: Bool {
		occupation.values.allSatisfy(\.isSolved)
	}
	
	func isFree(_ location: LocationConvertible) -> Bool {
		occupation[location.asLocation] == nil
	}
	
	func movingPod(at old: Location, to new: Location) -> Self {
		self <- {
			assert($0.occupation[new] == nil)
			$0.occupation[new] = $0.occupation[old].take()! <- {
				$0.location = new
				$0.hasMoved = true
			}
		}
	}
	
	var description: String {
		"\t" + occupation.values
			.sorted(on: \.type.rawValue)
			.map { "\($0.type): \($0.location)" }
			.joined(separator: ",\t")
	}
}



let (topRow, bottomRow) = input()
	.lines()
	.dropFirst(2)
	.prefix(2)
	.map { $0.map(String.init).compactMap(AmphipodType.init) }
	.bothElements()!

print(topRow)
print(bottomRow)

let pods = [
	(topRow, true),
	(bottomRow, false),
].flatMap { types, isTop in
	types.enumerated().map {
		Amphipod(
			type: $1,
			location: .room(.init(index: $0, isTop: isTop))
		)
	}
}

let initial = State(occupation: .init(uniqueKeysWithValues: pods.map { ($0.location, $0) }))

var knownCosts: [State: Int?] = [:]

struct Candidate: Comparable {
	var state: State
	var cost: Int
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.cost < rhs.cost
	}
}

var skips = 0
var checks = 0
var searched: Set<State> = []
func minSolutionCost(startingFrom initial: State) -> Int? {
	var toSearch: Heap = [Candidate(state: initial, cost: 0)]
	while let start = toSearch.popMin() {
		let state = start.state
		guard !state.isSolved else { return start.cost }
		guard !searched.contains(state) else { skips += 1; continue }
		checks += 1
		searched.insert(state)
		
		let reachable = state.occupation.values.lazy.flatMap { pod in
			pod.destinations(in: state).map { destination, distance in
				Candidate(
					state: state.movingPod(at: pod.location, to: destination),
					cost: start.cost + distance * pod.type.costMultiplier
				)
			}
		}
		toSearch.insert(contentsOf: reachable)
	}
	
	return nil
}

measureTime {
	let minCost = minSolutionCost(startingFrom: initial)!
	print("skips:", skips, "checks:", checks)
	print(searched.count)
	print("min cost:", minCost)
}

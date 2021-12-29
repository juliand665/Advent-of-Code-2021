import AoC_Helpers
import HandyOperators
import Collections
import Darwin

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
	var hasMoved = false
	
	func destinations(from location: Location, in state: State) -> [Destination] {
		switch location {
		case .hallway(let position):
			let top = RoomPosition(roomIndex: type.roomIndex, indexFromTop: 0)
			let entrance = top.hallwayNeighbor
			guard position.hasPath(to: entrance, in: state) else { return [] }
			
			let room = state.rooms[type.roomIndex]
			guard room.lazy.compactMap(\.?.type).allSatisfy({ $0 == type }) else { return [] }
			let indexFromTop = room.lastIndex(of: nil)!
			let xDistance = abs(entrance.index - position.index)
			return [(
				.room(.init(roomIndex: type.roomIndex, indexFromTop: indexFromTop)),
				distance: xDistance + indexFromTop + 1
			)]
		case .room(let position):
			guard !hasMoved else { return [] }
			let room = state.rooms[position.roomIndex]
			guard room.prefix(upTo: position.indexFromTop).allNil() else { return [] }
			let exitDistance = position.indexFromTop + 1
			return position.hallwayNeighbor
				.reachableNeighbors(in: state)
				.map { (Location.hallway($0), distance: $1 + exitDistance) }
		}
	}
}

let hallwayLength = 11
let roomCount = 4

enum Location: Hashable {
	case hallway(HallwayPosition)
	case room(RoomPosition)
}

struct HallwayPosition: Hashable, CustomStringConvertible {
	static let all = (0..<hallwayLength).map(Self.init)
	
	var index: Int
	
	var isValidDestination: Bool {
		index % 2 == 1 || index == 0 || index == hallwayLength - 1
	}
	
	var roomNeighbor: RoomPosition? {
		guard index > 1, index < hallwayLength - 2, index % 2 == 0 else { return nil }
		return RoomPosition(roomIndex: index / 2 - 1, indexFromTop: 0)
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

struct RoomPosition: Hashable, CustomStringConvertible {
	var roomIndex: Int
	var indexFromTop: Int
	
	var hallwayNeighbor: HallwayPosition {
		.init(index: roomIndex * 2 + 2)
	}
	
	var description: String {
		"\(roomIndex) \(indexFromTop)"
	}
}

struct State: Hashable, CustomStringConvertible {
	var hallway: [Amphipod?]
	var rooms: [[Amphipod?]]
	
	var isSolved: Bool {
		rooms.enumerated().allSatisfy { roomIndex, pods in
			pods.allSatisfy {
				$0?.type.roomIndex == roomIndex
			}
		}
	}
	
	init(roomRows: [[AmphipodType]]) {
		hallway = .init(repeating: nil, count: hallwayLength)
		rooms = roomRows.transposed().map { $0.map { .init(type: $0) } }
	}
	
	subscript(_ location: Location) -> Amphipod? {
		// compiler crashes if i use _read/_modify here in release mode lol
		get {
			switch location {
			case .hallway(let position):
				return hallway[position.index]
			case .room(let position):
				return rooms[position.roomIndex][position.indexFromTop]
			}
		}
		set {
			switch location {
			case .hallway(let position):
				hallway[position.index] = newValue
			case .room(let position):
				rooms[position.roomIndex][position.indexFromTop] = newValue
			}
		}
	}
	
	func isFree(_ position: HallwayPosition) -> Bool {
		self.hallway[position.index] == nil
	}
	
	func movingPod(at old: Location, to new: Location) -> Self {
		self <- {
			assert($0[new] == nil)
			$0[new] = $0[old].take()! <- {
				$0.hasMoved = true
			}
			//print($0)
		}
	}
	
	var description: String {
		([hallway] + rooms).map {
			$0.map { $0?.type.rawValue ?? "·" }.joined()
		}.joined(separator: ", ")
	}
	
	var withLocations: [(Location, Amphipod)] {
		hallway.enumerated().compactMap { i, pod in pod.map {
			(Location.hallway(.init(index: i)), $0)
		} }
		+ rooms.enumerated().flatMap { roomIndex, pods in
			pods.enumerated().compactMap { i, pod in pod.map {
				(Location.room(.init(roomIndex: roomIndex, indexFromTop: i)), $0)
			} }
		}
	}
}

struct Candidate: Comparable {
	var state: State
	var cost: Int
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.cost < rhs.cost
	}
}

func minSolutionCost(startingFrom initial: State) -> Int? {
	var toSearch: Heap = [Candidate(state: initial, cost: 0)]
	var searched: Set<State> = []
	while let start = toSearch.popMin() {
		let state = start.state
		guard !state.isSolved else {
			print("searched:", searched.count)
			return start.cost
		}
		guard !searched.contains(state) else { continue }
		searched.insert(state)
		
		let reachable = state.withLocations.flatMap { location, pod in
			pod.destinations(from: location, in: state).map { destination, distance in
				Candidate(
					state: state.movingPod(at: location, to: destination),
					cost: start.cost + distance * pod.type.costMultiplier
				)
			}
		}
		toSearch.insert(contentsOf: reachable)
	}
	
	return nil
}



let rows = input()
	.lines()
	.dropFirst(2)
	.prefix(2)
	.map { $0.map(String.init).compactMap(AmphipodType.init) }

print(rows)
let (topRow, bottomRow) = rows.bothElements()!

let initial = State(roomRows: rows)
print(initial)

measureTime {
	let minCost = minSolutionCost(startingFrom: initial)!
	print("min cost:", minCost)
}

let part2Additions: [[AmphipodType]] = [
	[.d, .c, .b, .a],
	[.d, .b, .a, .c],
]
let part2Rows = [topRow] + part2Additions + [bottomRow]
let part2Initial = State(roomRows: part2Rows)

measureTime {
	let minCost = minSolutionCost(startingFrom: part2Initial)!
	print("full min cost:", minCost)
}

import AoC_Helpers
import HandyOperators

// helpful for tracking associated values across functional chains
@dynamicMemberLookup
struct Tagged<Value, Tag>: CustomStringConvertible {
	var value: Value
	var tag: Tag
	
	subscript<T>(dynamicMember member: KeyPath<Value, T>) -> Tagged<T, Tag> {
		.init(value: value[keyPath: member], tag: tag)
	}
	
	var description: String {
		"Tagged(\(value), tag: \(tag))"
	}
}

extension Tagged where Value: _Optional {
	var lifted: Tagged<Value.Wrapped, Tag>? {
		value._optional.map { .init(value: $0, tag: tag) }
	}
}

extension Tagged where Tag: BinaryInteger {
	func tagIncremented(by increment: Tag = 1) -> Self {
		self <- { $0.tag += increment }
	}
}

extension Tagged: Equatable where Value: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.value == rhs.value
	}
}

extension Tagged: Comparable where Value: Comparable {
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.value < rhs.value
	}
}

protocol _Optional {
	associatedtype Wrapped
	var _optional: Wrapped? { get }
}

extension Optional: _Optional {
	var _optional: Wrapped? { self }
}

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

typealias Destination = Tagged<Location, Int>

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
			let bottom = top.other
			let topWithCost = Tagged(value: top, tag: abs(entrance.index - position.index)).tagIncremented()
			let bottomWithCost = topWithCost.other.tagIncremented()
			let reachable = [topWithCost] + (state.isFree(bottom) ? [bottomWithCost] : [])
			return reachable.map(\.asLocation)
		case .room(let position):
			guard !hasMoved else { return [] }
			if !position.isTop {
				guard state.isFree(position.other) else { return [] }
			}
			let exitCost = position.isTop ? 1 : 2
			return position.hallwayNeighbor
				.reachableNeighbors(in: state)
				.map { $0.tagIncremented(by: exitCost) }
				.map(\.asLocation)
		}
	}
}

let hallwayLength = 11
let roomCount = 4

protocol LocationConvertible {
	var asLocation: Location { get }
}

extension Tagged: LocationConvertible where Value: LocationConvertible {
	var asLocation: Location { value.asLocation }
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
	
	func reachableNeighbors(in state: State) -> [Tagged<Self, Int>] {
		let left = Self.all.prefix(upTo: index).reversed().prefix(while: state.isFree)
		let right = Self.all.suffix(from: index + 1).prefix(while: state.isFree)
		return (left + right)
			.lazy
			.filter(\.isValidDestination)
			.map { Tagged(value: $0, tag: abs($0.index - index)) }
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

typealias Solution = Tagged<Int, [State]>

// TODO: branch and bound
var knownCosts: [State: Solution?] = [:]
var knownUses = 0
func minSolutionCost(startingFrom state: State) -> Solution? {
	func compute() -> Solution? {
		state.occupation.values.lazy.flatMap { pod in
			pod.destinations(in: state).lazy.compactMap { destination in
				minSolutionCost(
					startingFrom: state.movingPod(at: pod.location, to: destination.value)
				).map { Tagged(
					value: $0.value + destination.tag * pod.type.costMultiplier,
					tag: [state] + $0.tag
				) }
			}
		}.min()
	}
	
	guard !state.isSolved else { return .init(value: 0, tag: [state]) }
	
	return (knownCosts[state] <- { _ in knownUses += 1 }) ?? (compute() <- {
		knownCosts[state] = $0
		if knownCosts.count % 1000 == 0 {
			print(knownCosts.count)
		}
	})
}

measureTime {
	let minCost = minSolutionCost(startingFrom: initial)!
	print("known uses:", knownUses)
	print("min cost:", minCost.value)
	print(minCost.tag.map(String.init).joined(separator: "\n"))
}

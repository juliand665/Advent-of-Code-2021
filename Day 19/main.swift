import AoC_Helpers
import Algorithms
import Collections
import HandyOperators

let overlapThreshold = 12

struct Scanner {
	var number: Int
	var beaconOffsets: [Vector3]
	var adjustment = Vector3.zero
	
	func allOrientations() -> [Self] {
		beaconOffsets
			.map(\.allOrientations)
			.transposed()
			.map(self.withOffsets(_:))
	}
	
	func withOffsets(_ offsets: [Vector3]) -> Self {
		self <- { $0.beaconOffsets = offsets }
	}
	
	func adjusted(by offset: Vector3) -> Self {
		.init(number: number, beaconOffsets: beaconOffsets.map { $0 + offset }, adjustment: offset)
	}
	
	func connecting(anyOrientationOf other: Self) -> Self? {
		other
			.allOrientations()
			.compactMap(connecting(_:))
			.asOptional()
	}
	
	func connecting(_ other: Self) -> Self? {
		beaconOffsets
			// interestingly, adding .lazy here makes it take twice as long!
			.flatMap { reference in
				other.beaconOffsets.lazy.map { (reference - $0) }
			}
			.occurrenceCounts()
			.filter { $0.value >= overlapThreshold }
			.asOptional()
			.map { other.adjusted(by: $0.key) }
	}
}

let scanners = input()
	.lines()
	.split(whereSeparator: \.isEmpty)
	.map { $0.dropFirst().map(Vector3.init) }
	.enumerated()
	.map { Scanner(number: $0, beaconOffsets: $1) }

var connected = [scanners.first!]
var toSearch: Deque = [scanners.first!]
var unconnected = Array(scanners.dropFirst())
while let reference = toSearch.popFirst() {
	let new = unconnected.compactMap(reference.connecting(anyOrientationOf:))
	print("found:", new.map(\.number))
	toSearch.append(contentsOf: new)
	connected.append(contentsOf: new)
	let toRemove = Set(new.map(\.number))
	unconnected.removeAll { toRemove.contains($0.number) }
}
assert(unconnected.isEmpty)

let allBeacons = Set(connected.flatMap(\.beaconOffsets))
print(allBeacons.count, "beacons")

let maxDistance = connected
	.pairwiseCombinations()
	.map { ($0.adjustment - $1.adjustment).absolute }
	.max()!
print("max distance:", maxDistance)

import AoC_Helpers
import SimpleParser
import Algorithms

var parser = Parser(reading: input())
parser.consume("target area: x=")
let minX = parser.readInt()
parser.consume("..")
let maxX = parser.readInt()
parser.consume(", y=")
let minY = parser.readInt()
parser.consume("..")
let maxY = parser.readInt()

let xPositions = Array((1...).lazy.reductions(0, +).prefix { $0 < minX })
assert(xPositions.last! <= maxX)

// e.g. 6 for end 3 (1 + 2 + 3)
func naturalSum(through end: Int) -> Int {
	end * (end + 1) / 2
}

let startY = -minY - 1
let highestY = naturalSum(through: startY)
print("highest y reached:", highestY)

// could probably just try them all lmao, startY range is minY to -minY - 1. startX range would be good to define based on startY range maybe? or just filter once…

func timesInTarget(startY: Int) -> [Int] {
	return sequence(state: (position: 0, velocity: startY)) { state in
		state.position += state.velocity
		state.velocity -= 1
		guard state.position >= minY else { return nil }
		return state.position
	}
	.enumerated()
	.drop { $0.element > maxY }
	.map(\.offset)
}

let startYsInTarget = Dictionary(
	(minY ..< -minY)
		.lazy
		.flatMap { startY in timesInTarget(startY: startY).map { ($0, [startY]) } },
	uniquingKeysWith: +
)
let startYCountsInTarget = (minY ..< -minY)
	.lazy
	.flatMap(timesInTarget(startY:))
	.occurrenceCounts()
let maxTime = startYsInTarget.keys.max()!

let startYsInTargetAt: [Set<Int>] = (0...maxTime)
	.map { Set(startYsInTarget[$0] ?? []) }

func solutionCount(startX: Int) -> Int {
	guard naturalSum(through: startX) >= minX else { return 0 } // can never reach min x
	let positions = (1...startX).lazy.reversed().reductions(+)
	let restingPosition = naturalSum(through: startX)
	let atRest = (minX...maxX).contains(restingPosition)
		? Set(startYsInTargetAt.dropFirst(startX).joined())
		: []
	let inMotion = zip(positions, startYsInTargetAt)
		.lazy
		.drop { $0.0 < minX }
		.prefix { $0.0 <= maxX }
		.flatMap(\.1)
	let solutions = Set(inMotion).union(atRest)
	// print("for startX = \(startX):", solutions)
	return solutions.count
}

let totalCount = (1...maxX).lazy.map(solutionCount(startX:)).sum()
print("total count:", totalCount)

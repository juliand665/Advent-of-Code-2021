import AoC_Helpers
import SimpleParser
import HandyOperators

extension Range {
	func intersection(with other: Self) -> Self? {
		let lower = Swift.max(lowerBound, other.lowerBound)
		let upper = Swift.min(upperBound, other.upperBound)
		return lower < upper ? lower..<upper : nil
	}
}

struct Cuboid {
	var x, y, z: Range<Int>
	
	var volume: Int {
		x.count * y.count * z.count
	}
	
	func intersection(with other: Self) -> Self? {
		guard
			let x = x.intersection(with: other.x),
			let y = y.intersection(with: other.y),
			let z = z.intersection(with: other.z)
		else { return nil }
		return .init(x: x, y: y, z: z)
	}
}

extension Cuboid: CustomStringConvertible {
	var description: String {
		"Cuboid(x: \(x.lowerBound)..\(x.upperBound - 1), y: \(y.lowerBound)..\(y.upperBound - 1), z: \(z.lowerBound)..\(z.upperBound - 1))"
	}
}

struct Step {
	var state: Bool
	var cuboid: Cuboid
	
	var isForInitialization: Bool {
		[cuboid.x, cuboid.y, cuboid.z].allSatisfy {
			-50 <= $0.lowerBound && $0.upperBound <= 51
		}
	}
}

extension Range: Parseable where Bound == Int{
	public init(from parser: inout Parser) {
		let lower = parser.readInt()
		parser.consume("..")
		let upper = parser.readInt()
		self = lower..<upper + 1
	}
}

extension Cuboid: Parseable {
	init(from parser: inout Parser) {
		parser.consume("x=")
		x = parser.readValue()
		parser.consume(",y=")
		y = parser.readValue()
		parser.consume(",z=")
		z = parser.readValue()
	}
}

extension Step: Parseable {
	init(from parser: inout Parser) {
		state = parser.readWord() == "on"
		parser.consume(" ")
		cuboid = parser.readValue()
	}
}

struct State {
	var regions: [(cuboid: Cuboid, adjustment: Int)] = []
	
	var cubeCount: Int {
		regions.map { $0.volume * $1 }.sum()
	}
	
	mutating func apply(_ step: Step) {
		regions += regions
			.lazy
			.compactMap { cuboid, adjustment in
				step.cuboid
					.intersection(with: cuboid)
					.map { ($0, -adjustment) }
			}
		if step.state {
			regions.append((step.cuboid, 1))
		}
	}
}

func state(after steps: [Step]) -> State {
	steps.reduce(into: .init()) { $0.apply($1) }
}

let steps = input().lines().map(Step.init)
let initSteps = steps.prefix(while: \.isForInitialization)

let afterInit = state(after: Array(initSteps))
print("after initialization, \(afterInit.cubeCount) cubes are on")

let full = state(after: steps)
print("after reboot, \(full.cubeCount) cubes are on")

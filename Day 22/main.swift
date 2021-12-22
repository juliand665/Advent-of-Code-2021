import AoC_Helpers
import SimpleParser
import HandyOperators

extension Range {
	func split(at split: Bound) -> [Range] {
		contains(split) ? [lowerBound..<split, split..<upperBound] : [self]
	}
}

struct Cuboid {
	var x, y, z: Range<Int>
	
	var volume: Int {
		x.count * y.count * z.count
	}
	
	var lowerBound: Vector3 {
		.init(x.lowerBound, y.lowerBound, z.lowerBound)
	}
	
	var upperBound: Vector3 {
		.init(x.upperBound, y.upperBound, z.upperBound)
	}
	
	func allPositions() -> [Vector3] {
		x.flatMap { x in
			y.flatMap { y in
				z.map { z in
					Vector3(x, y, z)
				}
			}
		}
	}
	
	func contains(_ position: Vector3) -> Bool {
		x.contains(position.x) && y.contains(position.y) && z.contains(position.z)
	}
	
	func split(at split: Vector3) -> [Self] {
		x.split(at: split.x).flatMap { x in
			y.split(at: split.y).flatMap { y in
				z.split(at: split.z).map { z in
					Cuboid(x: x, y: y, z: z)
				}
			}
		}
	}
	
	private func split(atBoundsOf other: Self) -> [Self] {
		split(at: other.lowerBound)
			.flatMap { $0.split(at: other.upperBound) }
	}
	
	func overlaps(with other: Self) -> Bool {
		x.overlaps(other.x) && y.overlaps(other.y) && z.overlaps(other.z)
	}
	
	func subtracting(_ other: Self) -> [Self] {
		split(atBoundsOf: other)
			.filter { !other.overlaps(with: $0) }
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
	var cuboids: [Cuboid] = []
	
	var cubeCount: Int {
		cuboids.map(\.volume).sum()
	}
	
	func applying(_ step: Step) -> Self {
		.init(
			cuboids: cuboids
				.flatMap { $0.subtracting(step.cuboid) }
				+ (step.state ? [step.cuboid] : [])
		)
	}
}

func state(after steps: [Step]) -> State {
	steps.enumerated().reduce(.init()) { state, step in
		let (index, step) = step
		print("applying step \(index)/\(steps.count)")
		return state.applying(step)
	}
}

let steps = input().lines().map(Step.init)

let initSteps = steps.prefix(while: \.isForInitialization)

print("starting...")
let afterInit = state(after: Array(initSteps))
print("after initialization, \(afterInit.cubeCount) cubes are on")

let full = state(after: steps)
print("after reboot, \(full.cubeCount) cubes are on")

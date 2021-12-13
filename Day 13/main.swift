import AoC_Helpers
import SimpleParser
import HandyOperators

struct Fold {
	var fixedAxis: Axis
	var offset: Int
	
	func applied(to dots: Set<Vector2>) -> Set<Vector2> {
		Set(dots.map(applied(to:)))
	}
	
	func applied(to dot: Vector2) -> Vector2 {
		switch fixedAxis {
		case .x:
			let delta = max(dot.x - offset, 0) // ignore negative deltas
			return dot.with(x: dot.x - 2 * delta)
		case .y:
			let delta = max(dot.y - offset, 0) // ignore negative deltas
			return dot.with(y: dot.y - 2 * delta)
		}
	}
	
	enum Axis: String {
		case x, y
	}
}

extension Fold: Parseable {
	init(from parser: inout Parser) {
		parser.consume("fold along ")
		fixedAxis = .init(rawValue: String(parser.consumeNext()))!
		parser.consume("=")
		offset = parser.readInt()
	}
}

let parts = input().lines().split(whereSeparator: \.isEmpty)
let coordinates = Set(parts.first!.map(Vector2.init))
let folds = parts.last!.map(Fold.init)

let afterFirstFold = folds.first!.applied(to: coordinates)
print(afterFirstFold.count, "dots after first fold")

let final = folds.reduce(coordinates) { $1.applied(to: $0) }
print(Matrix(positions: final))

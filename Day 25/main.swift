import AoC_Helpers
import HandyOperators

enum Facing: Hashable {
	case east, south
	
	var offset: Vector2 {
		switch self {
		case .east:
			return Vector2(1, 0)
		case .south:
			return Vector2(0, 1)
		}
	}
}

typealias State = Matrix<Facing?>

extension State {
	func stepped() -> Self {
		self.stepped(facing: .east)
			.stepped(facing: .south)
	}
	
	func stepped(facing: Facing) -> Self {
		self <- {
			for position in positions() where self[position] == facing {
				let nextPosition = wrap(position + facing.offset)
				guard self[nextPosition] == nil else { continue }
				$0[nextPosition] = $0[position].take()!
			}
		}
	}
	
	func wrap(_ offset: Vector2) -> Vector2 {
		.init(
			offset.x < 0 ? width - 1 : offset.x == width ? 0 : offset.x,
			offset.y < 0 ? height - 1 : offset.y == height ? 0 : offset.y
		)
	}
}

var facings: [Character: Facing] = [">": .east, "v": .south]
let initial: State = Matrix(input().lines()).map { facings[$0] }

var current = initial
for step in 1... {
	let next = current.stepped()
	guard next != current else {
		print("nothing moved on step", step)
		break
	}
	current = next
}

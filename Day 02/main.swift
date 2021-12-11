import AoC_Helpers
import SimpleParser
import HandyOperators

enum Direction: String {
	case forward
	case down
	case up
}

struct Command: Parseable {
	var direction: Direction
	var delta: Int
	
	init(from parser: inout Parser) {
		direction = .init(rawValue: parser.readWord())!
		parser.consume(" ")
		delta = parser.readInt()
	}
}

let commands = input().lines().map(Command.init)

let deltas = Dictionary(
	commands.map { ($0.direction, $0.delta) },
	uniquingKeysWith: +
)
let x = deltas[.forward]!
let depth = deltas[.down]! - deltas[.up]!
print("x times depth:", x * depth)

let actualDepth = 0 <- { depth in
	var aim = 0
	for command in commands {
		switch command.direction {
		case .up:
			aim -= command.delta
		case .down:
			aim += command.delta
		case .forward:
			depth += aim * command.delta
		}
	}
}
print("x times actual depth:", x * actualDepth)

import AoC_Helpers
import SimpleParser

struct VentLine {
	var start, end: Vector2
	
	var xRange: [Int] {
		autoFlippedRange(start.x, end.x)
	}
	
	var yRange: [Int] {
		autoFlippedRange(start.y, end.y)
	}
	
	func positions(allowDiagonal: Bool) -> [Vector2] {
		if start.x == end.x {
			return yRange.map { Vector2(start.x, $0) }
		} else if start.y == end.y {
			return xRange.map { Vector2($0, start.y) }
		} else if allowDiagonal {
			return zip(xRange, yRange).map(Vector2.init)
		} else {
			return []
		}
	}
}

extension VentLine: Parseable {
	init(from parser: inout Parser) {
		start = parser.readValue()
		parser.consume(" -> ")
		end = parser.readValue()
	}
}

let lines = input().lines().map(VentLine.init)

func autoFlippedRange(_ a: Int, _ b: Int) -> [Int] {
	a <= b ? Array(a...b) : (b...a).reversed()
}

var layers = lines
	.flatMap { $0.positions(allowDiagonal: false) }
	.occurrenceCounts()
print("overlaps:", layers.values.count { $0 > 1 })

var layersWithDiagonals = lines
	.flatMap { $0.positions(allowDiagonal: true) }
	.occurrenceCounts()
print("overlaps with diagonals:", layersWithDiagonals.values.count { $0 > 1 })

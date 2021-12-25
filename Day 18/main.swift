import AoC_Helpers
import SimpleParser
import HandyOperators
import Algorithms

typealias Side = WritableKeyPath<Pair, PairElement>

struct Explosion {
	var left, right: Int?
}

struct Pair: CustomStringConvertible {
	var left, right: PairElement
	
	var description: String {
		"[\(left), \(right)]"
	}
	
	func magnitude() -> Int {
		3 * left.magnitude() + 2 * right.magnitude()
	}
	
	mutating func add(_ number: Int, on side: Side) {
		self[keyPath: side].add(number, on: side)
	}
	
	mutating func explode(depth: Int = 1) -> Explosion? {
		if var explosion = left.explode(depth: depth) {
			if let r = explosion.right.take() {
				right.add(r, on: \.left)
			}
			return explosion
		} else if var explosion = right.explode(depth: depth) {
			if let l = explosion.left.take() {
				left.add(l, on: \.right)
			}
			return explosion
		} else {
			return nil
		}
	}
	
	mutating func split() -> Bool {
		left.split() || right.split()
	}
	
	mutating func reduce() {
		while explode() != nil || split() {}
	}
	
	static func + (lhs: Self, rhs: Self) -> Self {
		Self(left: .pair(lhs), right: .pair(rhs)) <- { $0.reduce() }
	}
}

extension Pair: Parseable {
	init(from parser: inout Parser) {
		parser.consume("[")
		self.left = parser.readValue()
		parser.consume(",")
		self.right = parser.readValue()
		parser.consume("]")
	}
}

enum PairElement: Parseable, CustomStringConvertible {
	indirect case pair(Pair)
	case number(Int)
	
	var description: String {
		switch self {
		case .pair(let pair):
			return String(describing: pair)
		case .number(let int):
			return String(describing: int)
		}
	}
	
	init(from parser: inout Parser) {
		if parser.next == "[" {
			self = .pair(parser.readValue())
		} else {
			self = .number(parser.readInt())
		}
	}
	
	func magnitude() -> Int {
		switch self {
		case .pair(let pair):
			return pair.magnitude()
		case .number(let int):
			return int
		}
	}
	
	mutating func add(_ number: Int, on side: Side) {
		switch self {
		case .pair(let pair):
			self = .pair(pair <- { $0.add(number, on: side) })
		case .number(let int):
			self = .number(int + number)
		}
	}
	
	mutating func explode(depth: Int) -> Explosion? {
		switch self {
		case .pair(var pair):
			if depth >= 4 {
				guard
					case .number(let l) = pair.left,
					case .number(let r) = pair.right
				else { fatalError() }
				self = .number(0)
				return Explosion(left: l, right: r)
			} else {
				guard let explosion = pair.explode(depth: depth + 1) else { return nil }
				self = .pair(pair)
				return explosion
			}
		case .number:
			return nil
		}
	}
	
	mutating func split() -> Bool {
		switch self {
		case .pair(var pair):
			guard pair.split() else { return false }
			self = .pair(pair)
			return true
		case .number(let int):
			guard int >= 10 else { return false }
			self = .pair(.init(
				left: .number(int / 2),
				right: .number((int + 1) / 2)
			))
			return true
		}
	}
}

let pairs = input().lines().map(Pair.init)

let sum = pairs.dropFirst().reduce(pairs.first!, +)
print("sum magnitude:", sum.magnitude())

let largestMagnitude = pairs
	.pairwiseCombinations()
	.map { ($0 + $1).magnitude() }
	.max()!
print("largest magnitude:", largestMagnitude)

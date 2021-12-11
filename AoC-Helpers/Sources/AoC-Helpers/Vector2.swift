import Foundation
import SimpleParser
import HandyOperators

public struct Vector2: Hashable {
	public static let zero = Vector2(0, 0)
	public static let unitX = Vector2(1, 0)
	public static let unitY = Vector2(0, 1)
	
	public var x, y: Int
	
	public var absolute: Int {
		abs(x) + abs(y)
	}
	
	public var neighbors: [Vector2] {
		applyingOffsets(.distance1)
	}
	
	public var angle: Double {
		atan2(Double(y), Double(x))
	}
	
	public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
		lhs <- { $0 += rhs }
	}
	
	public static func += (lhs: inout Vector2, rhs: Vector2) {
		lhs.x += rhs.x
		lhs.y += rhs.y
	}
	
	public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
		lhs <- { $0 -= rhs }
	}
	
	public static func -= (lhs: inout Vector2, rhs: Vector2) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
	}
	
	public static func * (vec: Vector2, scale: Int) -> Vector2 {
		vec <- { $0 *= scale }
	}
	
	public static func * (scale: Int, vec: Vector2) -> Vector2 {
		vec <- { $0 *= scale }
	}
	
	public static func *= (vec: inout Vector2, scale: Int) {
		vec.x *= scale
		vec.y *= scale
	}
	
	public func distance(to other: Vector2) -> Int {
		(self - other).absolute
	}
}

extension Vector2 {
	public init(_ x: Int, _ y: Int) {
		self.init(x: x, y: y)
	}
}

extension Vector2: Comparable {
	public static func < (lhs: Vector2, rhs: Vector2) -> Bool {
		(lhs.y, lhs.x) < (rhs.y, rhs.x)
	}
}

extension Vector2: Parseable {
	public init(from parser: inout Parser) {
		parser.consumeWhitespace()
		x = parser.readInt()
		parser.consume(",")
		parser.consumeWhitespace()
		y = parser.readInt()
	}
}

public enum Direction: CaseIterable, Rotatable {
	case up
	case right
	case down
	case left
	
	public var offset: Vector2 {
		switch self {
		case .up:
			return Vector2(x: 00, y: -1)
		case .right:
			return Vector2(x: +1, y: 00)
		case .down:
			return Vector2(x: 00, y: +1)
		case .left:
			return Vector2(x: -1, y: 00)
		}
	}
}

extension Direction: CustomStringConvertible {
	public var description: String {
		switch self {
		case .up:
			return "↑"
		case .right:
			return "→"
		case .down:
			return "↓"
		case .left:
			return "←"
		}
	}
}

extension Array where Element == Vector2 {
	public static let distance1 = [
		Vector2(00, -1),
		Vector2(+1, 00),
		Vector2(00, +1),
		Vector2(-1, 00),
	]
	
	public static let distance1orDiagonal = [
		Vector2(00, -1),
		Vector2(+1, -1),
		Vector2(+1, 00),
		Vector2(+1, +1),
		Vector2(00, +1),
		Vector2(-1, +1),
		Vector2(-1, 00),
		Vector2(-1, -1),
	]
}

extension Vector2 {
	public func applyingOffsets(_ offsets: [Vector2]) -> [Vector2] {
		offsets.map { $0 + self }
	}
}

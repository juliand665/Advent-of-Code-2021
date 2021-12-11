import Foundation
import HandyOperators

public struct Matrix<Element> {
	public let width, height: Int
	/// row-major list of elements in the matrix
	private(set) public var elements: [Element]
	
	public init(_ elements: [[Element]]) {
		let width = elements.first!.count
		self.width = width
		self.height = elements.count
		assert(elements.allSatisfy { $0.count == width })
		self.elements = Array(elements.joined())
	}
	
	public init(width: Int, height: Int, repeating element: Element) {
		self.init(
			width: width, height: height,
			elements: Array(repeating: element, count: width * height)
		)
	}
	
	public init(width: Int, height: Int, elements: [Element]) {
		assert(elements.count == width * height)
		self.width = width
		self.height = height
		self.elements = elements
	}
	
	public subscript(x: Int, y: Int) -> Element {
		get { self[Vector2(x: x, y: y)] }
		set { self[Vector2(x: x, y: y)] = newValue }
	}
	
	public subscript(position: Vector2) -> Element {
		get { elements[position.x + width * position.y] }
		set { elements[position.x + width * position.y] = newValue }
	}
	
	public func element(at position: Vector2) -> Element? {
		guard case 0..<width = position.x, case 0..<height = position.y else { return nil }
		return elements[position.x + width * position.y]
	}
	
	public func row(at y: Int) -> ArraySlice<Element> {
		elements[width * y ..< width * (y + 1)]
	}
	
	public func rows() -> [ArraySlice<Element>] {
		(0..<height).map(row(at:))
	}
	
	public func column(at x: Int) -> [Element] {
		(0..<height).map { self[x, $0] }
	}
	
	public func columns() -> [[Element]] {
		(0..<width).map(column(at:))
	}
	
	public func positions() -> [Vector2] {
		(0..<height).flatMap { y in
			(0..<width).map { x in Vector2(x: x, y: y) }
		}
	}
	
	public func enumerated() -> [(position: Vector2, element: Element)] {
		Array(zip(positions(), elements))
	}
	
	public func transposed() -> Self {
		guard let first = self.element(at: .zero) else { return self }
		
		return Matrix(width: height, height: width, repeating: first) <- { copy in
			for (position, element) in enumerated() {
				copy[Vector2(x: position.y, y: position.x)] = element
			}
		}
	}
	
	public func map<T>(_ transform: (Element) throws -> T) rethrows -> Matrix<T> {
		.init(
			width: width, height: height,
			elements: try elements.map(transform)
		)
	}
}

extension Matrix: RandomAccessCollection {
	public var startIndex: Vector2 { .zero }
	
	public var endIndex: Vector2 { .init(0, height) }
	
	public func index(before i: Vector2) -> Vector2 {
		if i.x - 1 >= 0 {
			return Vector2(i.x - 1, i.y)
		} else {
			return Vector2(width - 1, i.y - 1)
		}
	}
	
	public func index(after i: Vector2) -> Vector2 {
		if i.x + 1 < width {
			return Vector2(i.x + 1, i.y)
		} else {
			return Vector2(0, i.y + 1)
		}
	}
}

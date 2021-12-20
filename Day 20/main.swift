import AoC_Helpers

extension Matrix {
	func extended(radius: Int, filledWith filler: Element) -> Self {
		let offset = Vector2(radius, radius)
		return Matrix(
			width: width + 2 * radius,
			height: height + 2 * radius
		) {
			element(at: $0 - offset) ?? filler
		}
	}
	
	func convolved<T>(radius: Int, filter: ([ArraySlice<Element>]) -> T) -> Matrix<T> {
		.init((radius ..< height - radius).map { y in
			(radius ..< width - radius).map { x in
				filter((y - radius ... y + radius).map {
					row(at: $0).dropFirst(x - radius).prefix(2 * radius + 1)
				})
			}
		})
	}
}

struct InfiniteImage: CustomStringConvertible {
	var pixels: Matrix<Bool>
	var infiniteValue: Bool
	
	var description: String {
		pixels.binaryImage().description
	}
	
	var litCount: Int {
		pixels.elements.count(of: true)
	}
	
	func enhanced(with algorithm: [Bool]) -> Self {
		print("enhancing")
		let infiniteIndex = Int(bits: repeatElement(infiniteValue, count: 9))
		return .init(
			pixels: pixels
				.extended(radius: 2, filledWith: infiniteValue)
				.convolved(radius: 1) { square in
					algorithm[Int(bits: square.joined())]
				},
			infiniteValue: algorithm[infiniteIndex]
		)
	}
}

let (rawAlgorithm, rawImage) = input()
	.lines()
	.map { $0.map { $0 == "#" } }
	.split(whereSeparator: \.isEmpty)
	.bothElements()!
let algorithm = rawAlgorithm.onlyElement()!
let image = InfiniteImage(pixels: Matrix(rawImage), infiniteValue: false)

let enhanced = Array(sequence(first: image) { $0.enhanced(with: algorithm) }.prefix(51))
print(enhanced[2].litCount, "pixels lit after 2 steps")
print(enhanced[50].litCount, "pixels lit after 50 steps")

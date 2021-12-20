import AoC_Helpers

extension Matrix {
	func extended(by padding: Int, filledWith filler: Element) -> Self {
		let paddedRow = Array(repeating: filler, count: width + 2 * padding)
		let rowPadding = repeatElement(filler, count: padding)
		return .init(
			[]
			+ repeatElement(paddedRow, count: padding)
			+ rows.map { rowPadding + $0 + rowPadding }
			+ repeatElement(paddedRow, count: padding)
		)
	}
	
	func convolved<T>(radius: Int, filter: ([ArraySlice<Element>]) -> T) -> Matrix<T> {
		.init((radius ..< height - radius).map { y in
			(radius ..< width - radius).map { x in
				filter((y - radius ... y + radius).map {
					row(at: $0)[x - radius ... x + radius]
				})
			}
		})
	}
}

let kernelOffsets = (Vector2.zero.neighborsWithDiagonals + [.zero]).sorted()

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
		.init(
			pixels: pixels
				.extended(by: 2, filledWith: infiniteValue)
				.convolved(radius: 1) { square in
					algorithm[Int(bits: square.joined())]
				},
			infiniteValue: algorithm[Int(
				bits: repeatElement(infiniteValue, count: 9)
			)]
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

print("starting")
let enhanced = measureTime {
	Array(sequence(first: image) { $0.enhanced(with: algorithm) }.prefix(51))
}
print(enhanced[2].litCount, "pixels lit after 2 steps")
print(enhanced[50].litCount, "pixels lit after 50 steps")

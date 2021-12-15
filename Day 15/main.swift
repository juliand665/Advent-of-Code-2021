import AoC_Helpers
import HandyOperators
import Collections

let riskLevels = Matrix(digitsOf: input().lines())

func pathRisks(in riskLevels: Matrix<Int>) -> Matrix<Int> {
	Matrix(
		width: riskLevels.width,
		height: riskLevels.height,
		repeating: Int.max
	) <- { pathRisks in
		pathRisks[.zero] = 0
		var toSearch: Deque = [Vector2.zero]
		while let start = toSearch.popFirst() {
			for neighbor in start.neighbors where riskLevels.isInMatrix(neighbor) {
				let cost = pathRisks[start] + riskLevels[neighbor]
				if cost < pathRisks[neighbor] {
					pathRisks[neighbor] = cost
					toSearch.append(neighbor)
				}
			}
		}
	}
}

let smallPathRisks = pathRisks(in: riskLevels)
print("lowest-risk path to end in small version:", smallPathRisks.elements.last!)

let fullMap = Matrix(width: 5, height: 5) { pos in
	riskLevels.map { ($0 + pos.absolute - 1) % 9 + 1 }
}.flattened()
let fullPathRisks = pathRisks(in: fullMap)
print("lowest-risk path to end in full version:", fullPathRisks.elements.last!)

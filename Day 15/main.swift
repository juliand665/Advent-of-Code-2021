import AoC_Helpers
import HandyOperators
import Collections

let riskLevels = Matrix(digitsOf: input().lines())

struct Candidate: Comparable {
	var position: Vector2
	var cost: Int
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.cost < rhs.cost
	}
}

func pathRiskToEnd(in riskLevels: Matrix<Int>) -> Int {
	let target = Vector2(riskLevels.width - 1, riskLevels.height - 1)
	var toSearch: Heap = [Candidate(position: .zero, cost: 0)]
	var searched = Set<Vector2>()
	while let start = toSearch.popMin() {
		guard !searched.contains(start.position) else { continue }
		searched.insert(start.position)
		for neighbor in start.position.neighbors {
			guard let neighborRisk = riskLevels.element(at: neighbor) else { continue }
			let cost = start.cost + neighborRisk
			guard neighbor != target else { return cost }
			toSearch.insert(Candidate(position: neighbor, cost: cost))
		}
	}
	fatalError("target not reached!")
}

measureTime {
	let smallPathRisk = pathRiskToEnd(in: riskLevels)
	print("lowest-risk path to end in small version:", smallPathRisk)
	
	let fullMap = Matrix(width: 5, height: 5) { pos in
		riskLevels.map { ($0 + pos.absolute - 1) % 9 + 1 }
	}.flattened()
	let fullPathRisk = pathRiskToEnd(in: fullMap)
	print("lowest-risk path to end in full version:", fullPathRisk)
}

import AoC_Helpers
import Algorithms

let heightmap = Matrix(input().lines().map { $0.map(String.init).asInts() })
let lowPoints = heightmap.indexed().filter { position, height in
	heightmap.neighbors(of: position)
		.allSatisfy { height < $0 }
}

let lowSum = lowPoints.map { $0.element + 1 }.sum()
print("sum of low point risk levels:", lowSum)

func findBasin(start: Vector2) -> Set<Vector2> {
	var toExplore: Set<Vector2> = [start]
	var basin: Set<Vector2> = []
	while let base = toExplore.popFirst() {
		basin.insert(base)
		let neighborsInBasin = base.neighbors
			.filter { (heightmap.element(at: $0) ?? 9) < 9 }
		toExplore.formUnion(Set(neighborsInBasin).subtracting(basin))
	}
	return basin
}
let basinSizes = lowPoints.map { findBasin(start: $0.index).count }
let product = basinSizes.sorted().suffix(3).product()
print("product of 3 largest sizes:", product)

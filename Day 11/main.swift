import AoC_Helpers

var levels = Matrix(digitsOf: input().lines())

/// - returns: number of flashes in this step
func simulate() -> Int {
	levels.elements.forEachMutate { $0 += 1 }
	
	var flashed: Set<Vector2> = []
	func checkForFlash(at position: Vector2) {
		guard levels[position] > 9 else { return }
		let (inserted, _) = flashed.insert(position)
		guard inserted else { return } // already flashed
		
		for neighbor in position.neighborsWithDiagonals where levels.isInMatrix(neighbor) {
			levels[neighbor] += 1
			checkForFlash(at: neighbor)
		}
	}
	
	levels.positions().forEach(checkForFlash(at:))
	
	for flashed in flashed {
		levels[flashed] = 0
	}
	
	return flashed.count
}

var totalFlashes = 0
for step in 1...100 {
	let flashCount = simulate()
	totalFlashes += flashCount
	
	if step == 100 {
		print(totalFlashes, "flashes in 100 steps")
	}
}

for step in 101... {
	let flashCount = simulate()
	if flashCount == levels.count {
		print("synchronized at step", step)
		break
	}
}

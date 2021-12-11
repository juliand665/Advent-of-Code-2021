import AoC_Helpers
import HandyOperators

let positions = input().dropLast().split(separator: ",").asInts()
let average = positions.sum() / positions.count

func linearFuelCost(of position: Int) -> Int {
	positions.map { abs($0 - position) }.sum()
}

func optimalCost(scale: (Int) -> Int) -> Int {
	func cost(of target: Int) -> Int {
		positions.map { scale(abs($0 - target)) }.sum()
	}
	
	let target = average <- { target in
		let lowCost = cost(of: target)
		let highCost = cost(of: target + 1)
		let adjustment = highCost < lowCost ? +1 : -1
		while true {
			let adjusted = target + adjustment
			guard cost(of: adjusted) < cost(of: target) else { break }
			target = adjusted
		}
	}
	return cost(of: target)
}

let linearOptimum = optimalCost { $0 }
print("best linear target has cost", linearOptimum)

let quadraticOptimum = optimalCost { $0 * ($0 + 1) / 2 }
print("best quadratic target has cost", quadraticOptimum)

import AoC_Helpers

let ages = input().dropLast().split(separator: ",").asInts()

var byTimer = (0...8).map { ages.count(of: $0) }
func simulate() {
	let reproducing = byTimer[0]
	byTimer.removeFirst()
	byTimer[6] += reproducing
	byTimer.append(reproducing)
}

for _ in 1...80 { simulate() }
print("after 80 days:", byTimer.sum())

for _ in 81...256 { simulate() }
print("after 256 days:", byTimer.sum())

import AoC_Helpers
import HandyOperators

let boardSize = 10

struct Player: Hashable {
	var position: Int
	var score = 0
	
	mutating func advance(by roll: Int) {
		position += roll
		position %= boardSize
		score += position + 1
	}
}

struct State: Hashable {
	var nextPlayer, lastPlayer: Player
	
	mutating func swapPlayers() {
		swap(&nextPlayer, &lastPlayer)
	}
	
	func swapped() -> Self {
		.init(nextPlayer: lastPlayer, lastPlayer: nextPlayer)
	}
	
	mutating func advance(by roll: Int) {
		nextPlayer.advance(by: roll)
		swapPlayers()
	}
	
	func advanced(by roll: Int) -> Self {
		self <- { $0.advance(by: roll) }
	}
}

extension State {
	init(start1: Int, start2: Int) {
		nextPlayer = .init(position: start1 - 1)
		lastPlayer = .init(position: start2 - 1)
	}
}

let (start1, start2) = input().lines()
	.map { Int($0.words().last!)! }
	.bothElements()!
let start = State(start1: start1, start2: start2)

var deterministicRolls = (0...).lazy.map { $0 % 100 + 1 }
var state = start
for turn in 1... {
	let rollCount = 3 * turn
	let roll = 3 * (rollCount - 1)
	state.advance(by: roll)
	guard state.lastPlayer.score < 1000 else {
		print("product:", rollCount * state.nextPlayer.score)
		break
	}
}

struct Tally: Hashable, AdditiveArithmetic {
	typealias Stride = Self
	
	static let zero = Self(wins: 0, losses: 0)
	
	var wins, losses: Int
	
	func swapped() -> Self {
		.init(wins: losses, losses: wins)
	}
	
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(wins: lhs.wins + rhs.wins, losses: lhs.losses + rhs.losses)
	}
	
	static func - (lhs: Self, rhs: Self) -> Self {
		.init(wins: lhs.wins - rhs.wins, losses: lhs.losses - rhs.losses)
	}
	
	static func * (factor: Int, tally: Self) -> Self {
		.init(wins: factor * tally.wins, losses: factor * tally.losses)
	}
}

let winningScore = 21

let rolls = (1...3).flatMap { a in
	(1...3).flatMap { b in
		(1...3).map { a + b + $0 }
	}
}
.occurrenceCounts()

var tallies: [State: Tally] = [:]
func tally(state: State) -> Tally {
	assert(state.nextPlayer.score < winningScore)
	guard state.lastPlayer.score < winningScore
	else { return .init(wins: 0, losses: 1) }
	
	func compute() -> Tally {
		rolls
			.lazy
			.map { roll, count in
				count * tally(state: state.advanced(by: roll))
			}
			.sum()
			.swapped()
	}
	
	return tallies[state]
		?? (compute() <- { tallies[state] = $0 })
}

let finalTally = tally(state: start)
print("final tally:", finalTally)

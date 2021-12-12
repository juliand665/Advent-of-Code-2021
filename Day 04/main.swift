import AoC_Helpers

struct Board {
	var storage: Matrix<(number: Int, isMarked: Bool)>
	
	init<S: Sequence>(lines: S) where S.Element: StringProtocol {
		self.storage = .init(lines.map {
			$0.words().asInts().map { ($0, false) }
		})
	}
	
	func hasBingo() -> Bool {
		false
		|| storage.rows().contains { $0.allSatisfy(\.isMarked) }
		|| storage.columns().contains { $0.allSatisfy(\.isMarked) }
	}
	
	mutating func call(_ number: Int) {
		guard let index = storage.map(\.number).firstIndex(of: number) else { return }
		storage[index].isMarked = true
	}
	
	func unmarkedSum() -> Int {
		storage
			.filter { !$0.isMarked }
			.map(\.number)
			.sum()
	}
}

let lines = input().lines()
let order = lines.first!
	.split(separator: ",")
	.asInts()
let boards = lines.dropFirst()
	.split(whereSeparator: \.isEmpty)
	.map(Board.init(lines:))

var currentBoards = boards
var winningScores: [Int] = []
for number in order {
	currentBoards.forEachMutate { $0.call(number) }
	winningScores += currentBoards.filter { $0.hasBingo() }.map { $0.unmarkedSum() * number }
	currentBoards.removeAll { $0.hasBingo() }
}

print("winning score:", winningScores.first!)
print("losing score:", winningScores.last!)

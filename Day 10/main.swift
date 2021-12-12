import AoC_Helpers

let pairs = ["()", "[]", "{}", "<>"]
let closers = Dictionary(uniqueKeysWithValues: pairs.map { ($0.first!, $0.last!) })

let illegalValues: [Character: Int] = [
	")": 3,
	"]": 57,
	"}": 1197,
	">": 25137,
]

let autocompleteValues: [Character: Int] = [
	")": 1,
	"]": 2,
	"}": 3,
	">": 4,
]

enum ParseResult {
	case corrupted(illegal: Character)
	case incomplete(remaining: String)
	
	var errorScore: Int? {
		guard case .corrupted(let illegal) = self else { return nil }
		return illegalValues[illegal]!
	}
	
	var autocompleteScore: Int? {
		guard case .incomplete(let remaining) = self else { return nil }
		return remaining.reduce(0) { $0 * 5 + autocompleteValues[$1]! }
	}
}

let lines = input().lines()

func parse(_ line: Substring) -> ParseResult {
	var expectedClosers: [Character] = []
	for character in line {
		if let closer = closers[character] {
			expectedClosers.append(closer)
		} else if let expected = expectedClosers.popLast(), character == expected {
			// all good
		} else {
			return .corrupted(illegal: character)
		}
	}
	return .incomplete(remaining: String(expectedClosers.reversed()))
}

let parseResults = lines.map(parse)
let totalScore = parseResults.compactMap(\.errorScore).sum()
print("total syntax error score:", totalScore)

let autocompleteScores = parseResults.compactMap(\.autocompleteScore)
assert(autocompleteScores.count % 2 == 1)
let median = autocompleteScores.sorted()[autocompleteScores.count / 2]
print("middle autocomplete score:", median)

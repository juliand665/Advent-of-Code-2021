import AoC_Helpers
import SimpleParser
import HandyOperators

struct InsertionRule: Parseable {
	var pair: Pair
	var insertion: Character
	
	init(from parser: inout Parser) {
		pair = .init(parser.consumeNext(), parser.consumeNext())
		parser.consume(" -> ")
		insertion = parser.consumeNext()
	}
}

struct Pair: Hashable, CustomStringConvertible {
	var first, second: Character
	
	init(_ first: Character, _ second: Character) {
		self.first = first
		self.second = second
	}
	
	var description: String {
		"\(first)\(second)"
	}
}

struct Polymer {
	var pairCounts: [Pair: Int] = [:]
	
	func occurrenceCountDiff() -> Int {
		let counts = Dictionary(pairCounts.map { ($0.key.first, $0.value) }, uniquingKeysWith: +)
		return counts.values.max()! - counts.values.min()!
	}
}

extension Polymer {
	init<S: StringProtocol>(_ string: S) {
		pairCounts = zip(string, string.dropFirst() + "_") // pseudo-pair for last character
			.map(Pair.init)
			.occurrenceCounts()
		
		print(pairCounts)
	}
}

let parts = input().lines().split(whereSeparator: \.isEmpty)
let template = Polymer(parts.first!.onlyElement()!)
let rules = parts.last!.map(InsertionRule.init)
let insertions: [Pair: Character] = .init(
	uniqueKeysWithValues: rules.map { ($0.pair, $0.insertion) }
)

func applyRules(to polymer: Polymer) -> Polymer {
	Polymer() <- { new in
		for (pair, count) in polymer.pairCounts {
			if let insertion = insertions[pair] {
				new.pairCounts[.init(pair.first, insertion), default: 0] += count
				new.pairCounts[.init(insertion, pair.second), default: 0] += count
			} else {
				new.pairCounts[pair, default: 0] += count
			}
		}
	}
}

var polymer = template
for step in 1...40 {
	polymer = applyRules(to: polymer)
	if step % 10 == 0 {
		print("step \(step):", polymer.occurrenceCountDiff())
	}
}

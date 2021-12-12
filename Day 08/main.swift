import AoC_Helpers
import SimpleParser

// Might be cleaner to work with an enum, but this works decently enough.
let digitPatterns = [
	"abc efg", // 0
	"  c  f ", // 1
	"a cde g", // 2
	"a cd fg", // 3
	" bcd f ", // 4
	"ab d fg", // 5
	"ab defg", // 6
	"a c  f ", // 7
	"abcdefg", // 8
	"abcd fg", // 9
].map { Set($0.filter(\.isLetter)) }

let segments = "abcdefg"

let byCount = Dictionary(grouping: digitPatterns, by: \.count)
print(
	byCount
		.mapValues { $0.reduce(Set(segments)) { $0.intersection($1) } }
		.sorted(on: \.key)
		.map { "\($0.key): \(String($0.value.sorted()))" }
		.joined(separator: "\n")
)

// i ended up just hardcoding the process, but if i wanted to generalize it, this is where i would start:
/*
let identifyingIntersections = segments.map { target in
	digitPatterns
		.filter { $0.contains(target) }
		.reduce(Set(segments)) { $0.intersection($1) }
}
dump(identifyingIntersections)
*/

typealias Pattern = Set<Character>

struct Display: Parseable {
	var patterns: Set<Pattern>
	var output: [Pattern]
	
	init(from parser: inout Parser) {
		patterns = Set(parser.consume(through: "|")!.words().map(Set.init))
		output = parser.consumeRest().words().map(Set.init)
	}
	
	func computeConnections() -> [Character: Character] {
		let intersectionsByCount = Dictionary(grouping: patterns, by: \.count)
			.mapValues { $0.reduce(Set(segments)) { $0.intersection($1) } }
		
		// taken from the output printed above
		let cf = intersectionsByCount[2]!
		let acf = intersectionsByCount[3]!
		let bcdf = intersectionsByCount[4]!
		let adg = intersectionsByCount[5]!
		let abfg = intersectionsByCount[6]!
		let abcdefg = intersectionsByCount[7]!
		
		let a = acf.subtracting(cf).onlyElement()!
		
		let bd = bcdf.subtracting(cf)
		let b = bd.intersection(abfg).onlyElement()!
		let d = bd.subtracting(abfg).onlyElement()!
		
		let c = cf.subtracting(abfg).onlyElement()!
		let f = cf.intersection(abfg).onlyElement()!
		
		let g = adg.subtracting([a, d]).onlyElement()!
		
		let e = abcdefg.subtracting([a, b, c, d, f, g]).onlyElement()!
		
		return [
			a: "a",
			b: "b",
			c: "c",
			d: "d",
			e: "e",
			f: "f",
			g: "g",
		]
	}
	
	func decodedOutput() -> [Pattern] {
		let connections = computeConnections()
		return output.map {
			Set($0.map { connections[$0]! })
		}
	}
	
	func outputNumber() -> Int {
		let digits = decodedOutput().map { digitPatterns.firstIndex(of: $0)! }
		return Int(digits: digits)
	}
}

let displays = input().lines().map(Display.init)

let uniqueCounts = Set(
	digitPatterns
		.map(\.count)
		.occurrenceCounts()
		.filter { $0.value == 1 }
		.map(\.key)
)
let simpleOccurrences = displays.map {
	$0.output.count { uniqueCounts.contains($0.count) }
}.sum()

print(simpleOccurrences, "occurrences of unique digits in output")

let outputSum = displays.map { $0.outputNumber() }.sum()
print("output sum:", outputSum)

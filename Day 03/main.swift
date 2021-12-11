import AoC_Helpers

enum Bit: Int {
	case zero, one
	
	init?(rawValue: Character) {
		switch rawValue {
		case "0":
			self = .zero
		case "1":
			self = .one
		default:
			return nil
		}
	}
	
	var flipped: Self {
		switch self {
		case .zero:
			return .one
		case .one:
			return .zero
		}
	}
}

extension BinaryInteger {
	init<S: Sequence>(bits: S) where S.Element == Bit {
		self = bits.reduce(0) { $0 << 1 | Self($1.rawValue) }
	}
}

let bitLines = input().lines().map {
	$0.map { Bit(rawValue: $0)! }
}

let mostCommon = bitLines.transposed().map { $0.mostCommonElement()! }
let leastCommon = mostCommon.map(\.flipped)

let gammaRate = Int(bits: mostCommon)
let epsilonRate = Int(bits: leastCommon)
print("gamma x epsilon:", gammaRate * epsilonRate)

func rating(shouldFlipTarget: Bool) -> Int {
	var candidates = bitLines
	var index = 0
	while candidates.count > 1 {
		let mostCommon = candidates.map { $0[index] }.mostCommonElement() ?? .one
		let target = shouldFlipTarget ? mostCommon.flipped : mostCommon
		candidates = candidates.filter { $0[index] == target }
		index += 1
	}
	return Int(bits: candidates.first!)
}

let oxygenGeneratorRating = rating(shouldFlipTarget: false)
let co2ScrubberRating = rating(shouldFlipTarget: true)
let lifeSupportRating = oxygenGeneratorRating * co2ScrubberRating
print("life support rating:", lifeSupportRating)

print([[1, 2], [3, 4]].transposed())

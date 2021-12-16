import AoC_Helpers
import HandyOperators

typealias BitSlice = ArraySlice<Bool>

struct BitParser {
	var remaining: BitSlice
	
	var isDone: Bool {
		remaining.isEmpty
	}
	
	init(parsing bits: [Bool]) {
		self.remaining = bits[...]
	}
	
	init(parsing bits: BitSlice) {
		self.remaining = bits
	}
	
	@discardableResult
	public mutating func consumeNext() -> Bool {
		remaining.removeFirst()
	}
	
	@discardableResult
	mutating func consumeNext(_ count: Int) -> BitSlice {
		defer { remaining.removeFirst(count) }
		return remaining.prefix(count)
	}
	
	mutating func readInt(bitWidth: Int) -> Int {
		.init(bits: consumeNext(bitWidth))
	}
	
	mutating func readDynamicLengthInt() -> Int {
		0 <- { value in
			while true {
				let group = consumeNext(5)
				value = value << 4 | .init(bits: group.dropFirst())
				guard group.first! else { break }
			}
		}
	}
}

extension StringProtocol {
	func hexBits() -> [Bool] {
		map(String.init).flatMap { hex -> [Bool] in
			let bits = Int(hex, radix: 16)!.bits
			let padding = Array(repeating: false, count: 4 - bits.count)
			return padding + bits
		}
	}
}

struct Packet {
	var version: Int
	var typeID: Int
	var contents: Contents
	
	init(from parser: inout BitParser) {
		version = parser.readInt(bitWidth: 3)
		typeID = parser.readInt(bitWidth: 3)
		
		switch typeID {
		case 4: // literal
			contents = .literal(parser.readDynamicLengthInt())
		default: // operator
			let packets: [Packet]
			if parser.consumeNext() {
				let packetCount = parser.readInt(bitWidth: 11)
				packets = (0..<packetCount).map { _ in Packet(from: &parser) }
			} else {
				let bitCount = parser.readInt(bitWidth: 15)
				let rawPackets = parser.consumeNext(bitCount)
				packets = Array(sequence(state: BitParser(parsing: rawPackets)) { parser in
					guard !parser.isDone else { return nil }
					return Packet(from: &parser)
				})
			}
			contents = .operator(packets)
		}
	}
	
	var children: [Packet] {
		switch contents {
		case .literal:
			return []
		case .operator(let children):
			return children
		}
	}
	
	func evaluate() -> Int {
		switch contents {
		case .literal(let int):
			return int
		case .operator(let children):
			let values = children.map { $0.evaluate() }
			switch typeID {
			case 0:
				return values.sum()
			case 1:
				return values.product()
			case 2:
				return values.min()!
			case 3:
				return values.max()!
			case 5...7:
				assert(values.count == 2)
				let boolOps: [(Int, Int) -> Bool] = [(>), (<), (==)]
				let op = boolOps[typeID - 5]
				return op(values[0], values[1]) ? 1 : 0
			case let other:
				fatalError("bad operator type ID \(other)!")
			}
		}
	}
	
	enum Contents {
		case literal(Int)
		case `operator`([Packet])
	}
}

let bits = input().lines().first!.hexBits()
var parser = BitParser(parsing: bits)
let rootPacket = Packet(from: &parser)

func versionSum(of packet: Packet) -> Int {
	packet.version + packet.children.map(versionSum(of:)).sum()
}
let sum = versionSum(of: rootPacket)
print("version sum:", sum)

let value = rootPacket.evaluate()
print("evaluated:", value)

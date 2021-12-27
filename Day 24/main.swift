import AoC_Helpers
import SimpleParser
import HandyOperators

enum Variable: String {
	case w, x, y, z
	
	init?(rawValue: Character) {
		self.init(rawValue: String(rawValue))
	}
}

enum Operand: Parseable {
	case immediate(Int)
	case variable(Variable)
	
	init(from parser: inout Parser) {
		if parser.next!.isLetter {
			self = .variable(.init(rawValue: parser.consumeNext())!)
		} else {
			self = .immediate(parser.readInt())
		}
	}
}

enum Instruction: Parseable {
	case input(Variable)
	case operation(op: Operation, lhs: Variable, rhs: Operand)
	
	enum Operation: String {
		case add, mul, div, mod
		case eql
		
		func apply(lhs: Int, rhs: Int) -> Int {
			switch self {
			case .add: return lhs + rhs
			case .mul: return lhs * rhs
			case .div: return lhs / rhs
			case .mod: return lhs % rhs
			case .eql: return lhs == rhs ? 1 : 0
			}
		}
	}
	
	init(from parser: inout Parser) {
		let opcode: String = parser.readWord()
		parser.consume(" ")
		let destination = Variable(rawValue: parser.consumeNext())!
		if opcode == "inp" {
			self = .input(destination)
		} else {
			parser.consume(" ")
			self = .operation(
				op: .init(rawValue: opcode)!,
				lhs: destination,
				rhs: parser.readValue()
			)
		}
	}
}

struct ALU {
	var inputs: ArraySlice<Int>
	var x = 0
	var y = 0
	var z = 0
	var w = 0
	
	// for best performance
	subscript(variable: Variable) -> Int {
		get {
			switch variable {
			case .w: return w
			case .x: return x
			case .y: return y
			case .z: return z
			}
		}
		set {
			switch variable {
			case .w: w = newValue
			case .x: x = newValue
			case .y: y = newValue
			case .z: z = newValue
			}
		}
	}
	
	func resolve(_ operand: Operand) -> Int {
		switch operand {
		case .immediate(let int):
			return int
		case .variable(let variable):
			return self[variable]
		}
	}
	
	mutating func execute(_ instruction: Instruction) {
		switch instruction {
		case .input(let variable):
			print(z.digits(base: 26))
			self[variable] = inputs.removeFirst()
		case .operation(let op, let lhs, let rhs):
			self[lhs] = op.apply(lhs: self[lhs], rhs: resolve(rhs))
		}
	}
}

func isValidSerial(_ digits: [Int]) -> Bool {
	print("trying", digits.map(String.init).joined())
	let final = ALU(inputs: digits[...]) <- {
		for instruction in instructions {
			$0.execute(instruction)
		}
	}
	print(final)
	print(final.z.digits(base: 26))
	return final.z == 0
}

let instructions = input().lines().map(Instruction.init)

// ok so i ended up just inspecting the code manually lmao, but this was useful to verify quickly
// would be reasonably simple to extend my knowledge to a general approach though
print(isValidSerial(98491959997994.digits()))
print(isValidSerial(61191516111321.digits()))

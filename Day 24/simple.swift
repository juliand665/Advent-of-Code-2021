stack.append(input + 2)
stack.append(input + 16)
stack.append(input + 9)
stack.append(input + 0)
assert(input == stack.removeLast() - 8)
stack.append(input + 12)
assert(input == stack.removeLast() - 16)
assert(input == stack.removeLast() - 4)
stack.append(input + 3)
assert(input == stack.removeLast() - 3)
stack.append(input + 9)
assert(input == stack.removeLast() - 7)
assert(input == stack.removeLast() - 15)
assert(input == stack.removeLast() - 7)

stack.append(input) // 6..9 <-- A
stack.append(input) // 8..1 <-- B
stack.append(input) // 1..4 <-- C
stack.append(input) // 9..9 <-- D
assert(input == stack.removeLast() - 8) // 1..1 <-- D
stack.append(input) // 5..9 <-- E
assert(input == stack.removeLast() - 4) // 1..5 <-- E
assert(input == stack.removeLast() + 5) // 6..9 <-- C
stack.append(input) // 9..1 <-- F
assert(input == stack.removeLast() + 0) // 9..1 <-- F
stack.append(input) // 7..1 <-- G
assert(input == stack.removeLast() + 2) // 9..3 <-- G
assert(input == stack.removeLast() + 1) // 9..2 <-- B
assert(input == stack.removeLast() - 5) // 1..4 <-- A

98491959997994
ABCDDEECFFGGBA
61191516111321

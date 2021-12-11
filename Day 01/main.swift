import Foundation
import AoC_Helpers

let numbers = input().lines().map { Int($0)! }

let increaseCount = zip(numbers, numbers.dropFirst()).count(where: <)
print(increaseCount, "increases")

let sumIncreaseCount = zip(numbers, numbers.dropFirst(3)).count(where: <)
print(sumIncreaseCount, "sum increases")

var w = 0
var rest = 0
var y = 0
var total = 0


w = input()
rest = total % 26
//total /= 1
rest += 10 // 10
total *= 25 * (rest != w) + 1
y = w + 2
total += y * (rest != w)
// total = 3...11

w = input()
rest = total % 26
//total /= 1
rest += 15 // 18...26
total *= 25 * (rest != w) + 1
y = w + 16
total += y * (rest != w)
// total = prev * 26 + (17...25)

w = input()
rest = total % 26
//total /= 1
rest += 14 // 31...39
total *= 25 * (rest != w) + 1
y = w + 9
total += y * (rest != w)
// total = prev * 26 + (10...18)

w = input()
rest = total % 26
//total /= 1
rest += 15 // 25...33
total *= 25 * (rest != w) + 1
y = w + 0
total += y * (rest != w)
// total = prev * 26 + (1...9)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 8
total *= 25 * (rest != w) + 1
y = w + 1
total += y * (rest != w)

w = input()
rest = total % 26
//total /= 1
rest += 10
total *= 25 * (rest != w) + 1
y = w + 12
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 16
total *= 25 * (rest != w) + 1
y = w + 6
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 4
total *= 25 * (rest != w) + 1
y = w + 6
total += y * (rest != w)

w = input()
rest = total % 26
//total /= 1
rest += 11
total *= 25 * (rest != w) + 1
y = w + 3
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 3
total *= 25 * (rest != w) + 1
y = w + 5
total += y * (rest != w)

w = input()
rest = total % 26
//total /= 1
rest += 12
total *= 25 * (rest != w) + 1
y = w + 9
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 7
total *= 25 * (rest != w) + 1
y = w + 3
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 15
total *= 25 * (rest != w) + 1
y = w + 2
total += y * (rest != w)

w = input()
rest = total % 26
total /= 26 // <----------------- pop
rest -= 7
total *= 25 * (rest != w) + 1
y = w + 3
total += y * (rest != w)

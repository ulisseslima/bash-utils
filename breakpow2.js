var args = process.argv.slice(2)

let n = args[0]
let remainders = []
let pow2s = []

while (n > 0) {
	remainders.push(parseInt(n%2))
	n = parseInt(n/2)
}

for (let i in remainders) {
	let remainder = remainders[i]
	if (remainder == 1) {
		pow2s.push(parseInt(Math.pow(2, i)))
	}
}

console.log(pow2s)

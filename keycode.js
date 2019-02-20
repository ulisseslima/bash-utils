const readline = require('readline')

readline.emitKeypressEvents(process.stdin)
process.stdin.setRawMode(true)

process.stdin.on('keypress', (str, key) => {
	if (key.sequence === '\u0003') {
   		process.exit()
  	}

	console.log('var '+str+' = '+str.charCodeAt(0)+'; key.set('+str+', "'+str+'");')
})

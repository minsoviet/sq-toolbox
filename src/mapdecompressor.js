//  Module:     server
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const { Logger } = require('sq-lib')

const fs = require('fs')
const zlib = require('zlib')
const package = require('./shared/Package.js')

async function main() {
	Logger.setOptions({info: 1, system: 1})
	Logger.setLevels({system: '\x1b[1m'})

	Logger.system(`mapuncompress`, `${package.name} rev. ${package.getRevisionData().revision} ${package.getRevisionData().date}`)
    Logger.system(`mapuncompress`, `<Ctrl-C> to stop.\n`)
	Logger.system(`mapuncompress`, `  ____   ___    _____ ___   ___  _     ____   _____  __`)
	Logger.system(`mapuncompress`, ` / ___| / _ \\  |_   _/ _ \\ / _ \\| |   | __ ) / _ \\ \\/ /`)
	Logger.system(`mapuncompress`, ` \\___ \\| | | |   | || | | | | | | |   |  _ \\| | | \\  / `)
	Logger.system(`mapuncompress`, `  ___) | |_| |   | || |_| | |_| | |___| |_) | |_| /  \\ `)
 	Logger.system(`mapuncompress`, ` |____/ \\__\\_\\   |_| \\___/ \\___/|_____|____/ \\___/_/\\_\\`)
	Logger.system(`mapuncompress`, `                                                 v${package.version}`)
	Logger.system(`mapuncompress`, `${package.author}`)
	Logger.system(`mapuncompress`, ``)
	
	Logger.system(`mapuncompress`, `Используется файл конфигурации ${package.config.replace(/\\/g, '/')}`)
	Logger.system(`mapuncompress`, `Используется Node версии: Node.JS ${package.nodeVersion} (V8: ${package.v8Version})`)
	Logger.system(`mapuncompress`, `Используется sq-lib версии: sq-lib ${package.sqLibVersion}`)
	
	Logger.system('mapuncompress', 'Загрузка карты..')
	let map = fs.readFileSync('round.map')
	zlib.unzip(map, function(err, buf) {
		Logger.system('mapuncompress', 'Распаковка карты..')
		let newMap = Buffer.allocUnsafe(buf.length + 10)
		buf.copy(newMap, 2)
		newMap.writeUInt16BE(buf.length, 0)
		newMap.writeUInt32BE(180, buf.length + 2)
		newMap.writeUInt32BE(0, buf.length + 6)
		fs.writeFileSync('round_decompressed.map', newMap)
		Logger.system('mapuncompress', 'Карта распакована.')
	})
}

main()

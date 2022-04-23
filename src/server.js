//  Module:     server
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const { Logger } = require('sq-lib')
const { WtfFileFormat } = require('sq-lib')

const package = require('./shared/Package.js')
const createWebServer = require('./server/WebServer.js')
const createPolicyServer = require('./server/PolicyServer.js')
const createGameServer = require('./server/GameServer.js')

const OPTIONS_FILE = 'Сonfig.wtf'

async function main() {
	const options = WtfFileFormat.read(OPTIONS_FILE)

	Logger.setOptions({... options.logging, system: 1})
	Logger.setLevels({... Logger.levels, system: '\x1b[1m'})

	Logger.system(`server`, `${package.name} rev. ${package.getRevisionData().revision} ${package.getRevisionData().date}`)
    Logger.system(`server`, `<Ctrl-C> to stop.\n`)
	Logger.system(`server`, `  ____   ___    _____ ___   ___  _     ____   _____  __`)
	Logger.system(`server`, ` / ___| / _ \\  |_   _/ _ \\ / _ \\| |   | __ ) / _ \\ \\/ /`)
	Logger.system(`server`, ` \\___ \\| | | |   | || | | | | | | |   |  _ \\| | | \\  / `)
	Logger.system(`server`, `  ___) | |_| |   | || |_| | |_| | |___| |_) | |_| /  \\ `)
 	Logger.system(`server`, ` |____/ \\__\\_\\   |_| \\___/ \\___/|_____|____/ \\___/_/\\_\\`)
	Logger.system(`server`, `                                                 v${package.version}`)
	Logger.system(`server`, `${package.author}`)
	Logger.system(`server`, ``)
	
	Logger.system(`server`, `Используется файл конфигурации ${package.config.replace(/\\/g, '/')}`)
	Logger.system(`server`, `Используется Node версии: Node.JS ${package.nodeVersion} (V8: ${package.v8Version})`)
	Logger.system(`server`, `Используется sq-lib версии: sq-lib ${package.sqLibVersion}`)
	
	const { httpServer, httpsServer } = createWebServer(options)
	const policyServer = createPolicyServer(options)
	const gameServer = createGameServer(options)
	httpServer.listen(options.web.port, options.web.host, () => Logger.system(`server`, `Веб-сервер запущен на ${options.web.host}:${options.web.port}`))
	httpsServer.listen(options.web.portSsl, options.web.host, () => Logger.system(`server`, `Веб-сервер запущен на ${options.web.host}:${options.web.portSsl}`))
	policyServer.on('server.listening', (server) => Logger.system(`server`, `Сервер политики запущен на ${server.address().address}:${server.address().port}`))
	policyServer.listen()
	gameServer.on('server.listening', (server) => Logger.system(`server`, `Игровой сервер запущен на ${server.address().address}:${server.address().port}`))
	gameServer.listen()
}

main()

//  Module:     GameServer
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const package = require('../shared/Package.js')
const fs = require('fs')

const {
	Logger,
	GameServer,
	GameClient,
	ClientData
} = require('sq-lib')
const {
	PacketClient,
	PacketServer,
	ConfigData,
	ExpirationsManager,
	ClanRoom
} = ClientData

module.exports = function(options) {
	if (!fs.existsSync(options.local.cacheDir))
		fs.mkdirSync(options.local.cacheDir)

	const constants = JSON.parse(fs.readFileSync(options.local.dataDir + '/constants.json', 'utf8'))
	const scripts = {
		inject: fs.readFileSync(options.local.dataDir + '/scripts/inject.hx', 'utf8'),
		onAnyUpdate: fs.readFileSync(options.local.dataDir + '/scripts/onAnyUpdate.hx', 'utf8'),
		onSettingsUpdate: fs.readFileSync(options.local.dataDir + '/scripts/onSettingsUpdate.hx', 'utf8'),
		onChangeRound: fs.readFileSync(options.local.dataDir + '/scripts/onChangeRound.hx', 'utf8'),
		setMenu: fs.readFileSync(options.local.dataDir + '/scripts/setMenu.hx', 'utf8'),
		setHotkeys: fs.readFileSync(options.local.dataDir + '/scripts/setHotkeys.hx', 'utf8'),
		setHighlightObjects: fs.readFileSync(options.local.dataDir + '/scripts/setHighlightObjects.hx', 'utf8'),
		setSpy: fs.readFileSync(options.local.dataDir + '/scripts/setSpy.hx', 'utf8')
	}

	function getTime() {
		return Date.now() / 1000 | 0
	}

	function showMessage(client, message) {
		if (client.settings.scriptOutput && client.storage.injected)
			client.sendData('PacketRoundCommand', {
				playerId: client.uid,
				dataJson: {
					'est': ['showMessage', message]
				}
			})
		else
			client.sendData('PacketAdminMessage', {
				message: message
			})
	}

	function createMapTimer(client, isHaxe, script) {
		script = script + 'try{self.enabled = false;}catch(e:Dynamic){};try {self.dispose();}catch(e:Dynamic){};Type.resolveClass("game.mainGame.SquirrelGame").instance.map.gameObjects().pop();'
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'Create': [73, [
					['', script, true, 1, 1, 0, false, true, [0, 0], isHaxe]
				], true]
			}
		})
	}

	function createMapSensor(client, isHaxe, script) {
		script = script + 'try{self.enabled = false;}catch(e:Dynamic){};try {self.dispose();}catch(e:Dynamic){};Type.resolveClass("game.mainGame.SquirrelGame").instance.map.gameObjects().pop();'
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'Create': [57, [
					[0, 0], 0, false, [script, '', [1048575, 1048575], true, true, true, true, false, isHaxe]
				], true]
			}
		})
	}

	function createMapSensorRect(client, isHaxe, script) {
		script = script + 'try{self.enabled = false;}catch(e:Dynamic){};try {self.dispose();}catch(e:Dynamic){};Type.resolveClass("game.mainGame.SquirrelGame").instance.map.gameObjects().pop();'
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'Create': [74, [
					[0, 0], 0, false, [script, '', [1048575, 1048575], true, true, true, true, false, isHaxe]
				], true]
			}
		})
	}

	function runScript(client, isHaxe, script) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est': ['runScript', isHaxe, script]
			}
		})
	}

	function runScriptFast(client, isHaxe, script) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est__fastActivate': ['runScript', isHaxe, script]
			}
		})
	}

	function runExternalScript(client, script) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est': ['runExternalScript', script]
			}
		})
	}

	function crashMap(client) {
		client.round.ignoreSelfCreates = (client.round.ignoreSelfCreates || 0) + 1
		client.proxy.sendData('ROUND_COMMAND', {
			'Create': [1, [
				[
					[]
				]
			], true]
		})
	}

	function castMapTimer(client, isHaxe, script) {
		script = script + 'try{self.enabled = false;}catch(e:Dynamic){};try{self.dispose();}catch(e:Dynamic){};Type.resolveClass("game.mainGame.SquirrelGame").instance.map.gameObjects().pop();var i=Logger.messages.length-1;while(i>=0&&(Logger.messages[i].indexOf("PacketRoundCastBegin") == -1||Logger.messages[i].indexOf("window.logger") == -1)){Logger.messages.pop();i--;};Logger.messages.pop();Logger.messages.pop();if(Type.resolveClass("flash.external.ExternalInterface").call("eval","\\"logger\\" in window;")){Type.resolveClass("flash.external.ExternalInterface").call("eval", "setTimeout(function(){var log=window.logger.log.split(\\"\\\\n\\");var i=log.length-1;while(i>=0&&(log[i].indexOf(\\"PacketRoundCastBegin\\") == -1||log[i].indexOf(\\"window.logger\\") == -1)){log.pop();i--;};log.pop();log.pop();window.logger.log=log.join(\\"\\\\n\\");},500)");};'
		let data = JSON.stringify([[1048575,1048575],[73,[["",script,true,1,1,0,false,true,[1048575,1048575],isHaxe]]]])
		client.proxy.sendData('ROUND_CAST_BEGIN', 73, data)
		client.proxy.sendData('ROUND_CAST_END', 0, 73, 1)
	}

	function sendHollow(client) {
		if (client.storage.injected)
			runScript(client, true, 'if(Hero.self != null){Hero.self.onHollow(0);}')
		client.proxy.sendData('ROUND_NUT', PacketClient.NUT_PICK)
		client.proxy.sendData('ROUND_HOLLOW', 0)
	}

	function getSettings(client) {
		if (!fs.existsSync(options.local.cacheDir + '/settings' + client.uid + '.json'))
			return {}
		return JSON.parse(fs.readFileSync(options.local.cacheDir + '/settings' + client.uid + '.json', 'utf8'))
	}

	function saveSettings(client) {
		fs.writeFileSync(options.local.cacheDir + '/settings' + client.uid + '.json', JSON.stringify(client.settings), {
			encoding: 'utf8',
			flag: 'w+'
		})
	}

	function sendSettings(client) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est': ['setSettings', client.settings]
			}
		})
	}

	function updateSetting(client, name, value, isFirstRun) {
		let player = client.player
		switch (name) {
			case 'fakeVIP':
				if (isFirstRun)
					return
				if (!value)
					client.sendData('PacketExpirations', {
						items: [client.storage.origVIPExpiration]
					})
				else
					client.sendData('PacketExpirations', {
						items: [{
							type: ExpirationsManager.VIP,
							exists: 1,
							duration: 2147483647
						}]
					})
				break
			case 'fakeModerator':
				if (isFirstRun)
					return
				let moderator = player.moderator || value
				client.sendData('PacketInfo', {
					data: [{
						uid: client.uid,
						moderator: moderator
					}]
				})
				break
			case 'fakeLevel':
				if (isFirstRun)
					return
				let exp = player.exp
				if (value)
					exp = levelToExp(200)
				client.sendData('PacketExperience', {
					exp: exp
				})
				client.sendData('PacketInfo', {
					data: [{
						uid: client.uid,
						exp: exp
					}]
				})
				break
			case 'autoCrash':
				if (value) {
					let autoCrash = function() {
						if (!client.room.in)
							return
						crashMap(client)
					}
					client.autoCrashInterval = setInterval(autoCrash, 250)
				} else {
					if (!('autoCrashInterval' in client))
						break
					clearInterval(client.autoCrashInterval)
					delete client.autoCrashInterval
				}
			case 'warnModerators':
			case 'notifyModerators':
			case 'logModerators':
				if (value) {
					if ('checkModeratorsInterval' in client)
						break
					let checkModerators = function() {
						let moderators = []
						for (let moderator of constants.moderators) {
							moderators.push([moderator])
						}
						client.proxy.sendData('REQUEST', moderators, 72)
					}
					client.checkModeratorsInterval = setInterval(checkModerators, 15000)
					checkModerators()
				} else {
					if (!('checkModeratorsInterval' in client))
						break
					if (client.settings.warnModerators)
						break
					if (client.settings.notifyModerators)
						break
					if (client.settings.logModerators)
						break
					clearInterval(client.checkModeratorsInterval)
					delete client.checkModeratorsInterval
				}
		}
	}

	function sendPlayerInfo(client) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est': ['setPlayerInfo', client.player]
			}
		})
	}

	function sendConstants(client) {
		client.sendData('PacketRoundCommand', {
			playerId: client.uid,
			dataJson: {
				'est': ['setConstants', constants]
			}
		})
	}

	function expToLevel(exp) {
		let levels = ConfigData.player.levels
		for (let level in levels)
			if (exp < levels[level].experience)
				return level - 1
		return levels.length - 1
	}

	function levelToExp(level) {
		let levels = ConfigData.player.levels
		return levels[level in levels ? level : ConfigData.player.MAX_LEVEL].experience
	}

	function getPlayerInfo(client, id) {
		if (id === client.uid)
			return client.player
		return client.players[id]
	}

	function getPlayerMention(client, id) {
		let player = getPlayerInfo(client, id)
		return constructPlayerMention(player, id)
	}

	function constructPlayerMention(player, id) {
		if (!player)
			return 'ID ' + id
		return (player.name || 'Без имени') + ' (ID ' + (id || player.uid) + ')'
	}

	function isValidCreate(create) {
		let entityId = create[0]
		if (typeof entityId !== 'number' || entityId % 1 !== 0)
			return false
		let data = create[1]
		let isOldStyle = Array.isArray(data[0]) && data[0].length === 2
		if (isOldStyle) {
			if (typeof data[0][0] !== 'number' || typeof data[0][1] !== 'number')
				return false
			if (typeof data[1] !== 'number')
				return false
			if (typeof data[2] !== 'boolean')
				return false
			return true
		}
		if (!Array.isArray(data[0]))
			return false
		if (!Array.isArray(data[0][0]))
			return false
		if (typeof data[0][0][0] !== 'number' || typeof data[0][0][1] !== 'number')
			return false
		if (typeof data[0][1] !== 'number')
			return false
		if (typeof data[0][2] !== 'boolean')
			return false
		if (typeof data[0][3] !== 'boolean')
			return false
		if (typeof data[0][4] !== 'boolean')
			return false
		if (data[0].length < 6)
			return true
		if (!Array.isArray(data[0][5]))
			return false
		if (typeof data[0][5][0] !== 'number' || typeof data[0][5][1] !== 'number')
			return false
		if (typeof data[0][6] !== 'number')
			return false
		if (typeof data[0][7] !== 'string')
			return false
		if (data[0].length < 9)
			return true
		if (typeof data[0][8] !== 'number')
			return false
		if (data[0].length < 10)
			return true
		if (typeof data[0][9] !== 'boolean')
			return false
		return true
	}

	function isValidDestroy(destroy) {
		let id = destroy[0]
		if (typeof id !== 'number' || id % 1 !== 0)
			return false
		if (typeof destroy[1] !== 'boolean')
			return false
		return true
	}

	function handlePlayerInit(client) {
		client.players = {}
		client.room = {
			in: false
		}
		client.round = {
			in: false
		}
		client.settings = getSettings(client)
		for (let setting of constants.settingsData) {
			if (!(setting[0] in client.settings))
				client.settings[setting[0]] = setting[2]
		}
		for (let setting of constants.settingsData) {
			updateSetting(client, setting[0], client.settings[setting[0]], true)
		}
		saveSettings(client)
		Logger.info('server', `Вы вошли как ${getPlayerMention(client, client.uid)}`)
	}

	function handleLoginServerPacket(client, packet, buffer) {
		if (packet.data.innerId === undefined)
			return false
		client.uid = packet.data.innerId
		if (options.local.saveLoginData)
			fs.writeFileSync(options.local.cacheDir + '/loginData' + client.uid + '.txt', client.storage.loginData, { encoding: 'utf8', flag: 'w+'})
		return false
	}

	function handleNonSelfInfoServerPacket(client, mask, player) {
		let oldPlayer = client.players[player.uid]
		if (constants.moderators.indexOf(player.uid) !== -1 && mask === 72) {
			let onlineChanged = false
			if (!oldPlayer) {
				onlineChanged = player.online
			} else {
				onlineChanged = oldPlayer.online !== player.online
			}
			if (onlineChanged) {
				if (player.online && client.settings.warnModerators) {
					showMessage(client, constructPlayerMention(player) + ' в игре')
				}
				if (client.settings.notifyModerators && client.room.in) {
					let message = '<span class=\'color1\'>Вышел из игры</span>'
					if (player.online) {
						message = '<span class=\'name_moderator\'>Вошел в игру</span>'
						if (!oldPlayer)
							message = '<span class=\'name_moderator\'>Уже в игре</span>'
					}
					client.sendData('PacketChatMessage', {
						chatType: 0,
						playerId: player.uid,
						message: message
					})
				}
				if (client.settings.logModerators) {
					let message = 'вышел из игры'
					if (player.online) {
						message = 'вошел в игру'
						if (!oldPlayer)
							message = 'уже в игре'
					}
					Logger.info('server', `${constructPlayerMention(player)} ${message}`)
				}
			}
		}
		client.players[player.uid] = Object.assign(oldPlayer || {}, player)
		let fullPlayer = client.players[player.uid]
		if (client.settings.noModerators) {
			if (fullPlayer.moderator) {
				if ('moderator' in player)
					player.moderator = 0
				if ('name' in player)
					player.name = player.name + ' [М]'
			}
		}
		return false
	}

	function handleSelfInfoServerPacket(client, mask, player) {
		let isFirstInfo = !client.player
		if (isFirstInfo && mask === -1) {
			client.player = Object.assign({}, player)
			handlePlayerInit(client)
		} else {
			client.player = Object.assign(client.player, player)
			if (client.storage.injected)
				sendPlayerInfo(client)
		}
		if (client.settings.fakeModerator && 'moderator' in player)
			player.moderator = 1
		if (client.settings.fakeLevel && 'exp' in player)
			player.exp = levelToExp(200)
		return false
	}

	function handleInfoServerPacket(client, packet, buffer) {
		let {
			mask,
			data
		} = packet.data
		for (let i in data) {
			if (client.uid !== data[i].uid) {
				if (handleNonSelfInfoServerPacket(client, mask, data[i]))
					data.splice(i, 1)
				continue
			}
			if (handleSelfInfoServerPacket(client, mask, data[i]))
				data.splice(i, 1)
		}
		return false
	}

	function handleChatHistoryServerPacket(client, packet, buffer) {
		let {
			chatType,
			messages
		} = packet.data
		if (client.settings.ignoreRoomChat && chatType === 0)
			return true
		for (let i in messages) {
			let {
				playerId,
				message
			} = messages[i]
			if (client.settings.sanitizeChat)
				messages[i].message = message.replace(/</g, '&lt;')
		}
		return false
	}

	function handleChatMessageServerPacket(client, packet, buffer) {
		let {
			chatType,
			playerId,
			message
		} = packet.data
		if (client.settings.ignoreRoomChat && chatType === 0)
			return true
		if (client.settings.sanitizeChat)
			packet.data.message = message.replace(/</g, '&lt;')
		return false
	}

	function handleExperienceServerPacket(client, packet, buffer) {
		if (client.settings.fakeLevel)
			packet.exp = levelToExp(200)
	}

	function handleExpirationsServerPacket(client, packet, buffer) {
		let {
			items
		} = packet.data
		let player = client.player
		let added = false
		for (let item of items) {
			if (item.type !== ExpirationsManager.VIP)
				continue
			added = true
			client.storage.origVIPExpiration = {
				type: item.type,
				exists: item.exists,
				duration: item.duration
			}
			if (!client.settings.fakeVIP) {
				if (item.exists) {
					if (!player.vip_info.vip_exist) {
						client.player.vip_info.vip_exist = 1
						client.sendData('PacketInfo', {
							data: [{
								uid: client.uid,
								vip_info: client.player.vip_info
							}]
						})
					}
				} else if (player.vip_info.vip_exist) {
					client.player.vip_info.vip_exist = 0
					client.sendData('PacketInfo', {
						data: [{
							uid: client.uid,
							vip_info: client.player.vip_info
						}]
					})
				}
				break
			}
			item.exists = 1
			item.duration = 2147483647
			break
		}
		if (client.settings.fakeVIP && !added) {
			items.push({
				type: ExpirationsManager.VIP,
				exists: 1,
				duration: 2147483647
			})
		}
		return false
	}

	function handleRoomRoundServerPacket(client, packet, buffer) {
		let {
			type
		} = packet.data
		var ignorePacket = false
		var spying = !client.player.moderator && client.storage.spy
		if (spying) {
			var spy = client.storage.spy
			switch(type) {
				case PacketServer.ROUND_STARTING:
					spy.state = 2
					spy.lastMapId = packet.data.mapId
					let delay = packet.data.delay * 1000
					setTimeout(function() {
						if (spy.state !== 2)
							return
						spy.state = 3
						client.proxy.sendData('LEAVE')
					}, delay - 3000)
					packet.data.type = PacketServer.ROUND_PLAYING
					packet.data.delay = packet.data.delay + packet.data.mapDuration
					break
				case PacketServer.ROUND_WAITING:
				case PacketServer.ROUND_RESULTS:
					spy.state = 1
					break
				case PacketServer.ROUND_PLAYING:
					spy.state = 1
					if ('mapData' in packet.data && spy.lastMapId === packet.data.mapId)
						ignorePacket = true
					break
				case PacketServer.ROUND_START:
					spy.state = 1
					client.proxy.sendData('LEAVE')
					ignorePacket = true
			}
		}
		switch (type) {
			case PacketServer.ROUND_WAITING:
			case PacketServer.ROUND_STARTING:
			case PacketServer.ROUND_RESULTS:
				client.round = {
					in: false,
					players: client.room.players.slice(),
					mapObjects: {},
					hollow: [],
					moderators: {}
				}
				break
			case PacketServer.ROUND_PLAYING:
			case PacketServer.ROUND_START:
				client.round = {
					in: true,
					players: client.room.players.slice(),
					mapObjects: {},
					hollow: [],
					moderators: {}
				}
				if (client.storage.injected) {
					runScript(client, true, 'Est.onChangeRound();')
				} else {
					client.defer.push(function() {
						client.round.beingInjected = true
						let inject = 'if(!Reflect.hasField(Game.self, "est")) {' + scripts.inject + 'Gs.est.sendData(Gs.est.packetId, "{\\"est\\":[\\"state\\",0,false]}");};'
						createMapTimer(client, true, inject)
						createMapSensor(client, true, inject)
						createMapSensorRect(client, true, inject)
					})
				}
				if (!spying && client.settings.autoHollow) {
					setTimeout(function() {
						if (!client.round.in)
							return
						if (!client.settings.autoHollow)
							return
						client.autoHollowInterval = setInterval(function() {
							if (!client.round.in)
								return clearInterval(client.autoHollowInterval)
							if (!client.settings.autoHollow)
								return clearInterval(client.autoHollowInterval)
							if (client.storage.shamans.indexOf(client.uid) !== -1) {
								for (let player of client.round.players) {
									if (client.storage.shamans.indexOf(player) !== -1)
										continue
									if (client.round.hollow.indexOf(player) === -1)
										return
								}
							}
							sendHollow(client)
							clearInterval(client.autoHollowInterval)
						}, 250)
					}, 3750)
				}
		}
		if (!spying && client.handlers.onRoomRound) {
			client.handlers.onRoomRound(packet, buffer)
			delete client.handlers.onRoomRound
		}
		return ignorePacket
	}

	function handleRoomServerPacket(client, packet, buffer) {
		let {
			locationId,
			subLocation,
			players,
			isPrivate
		} = packet.data
		if (!client.player.moderator) {
			let spy = client.storage.spy
			if (spy && spy.state === 1 && 'oldPlayers' in spy) {
				let oldPlayers = spy.oldPlayers
				for (let playerId of players) {
					if (oldPlayers.indexOf(playerId) === -1) {
						handleRoomJoinServerPacket(client, {data: {playerId: playerId}})
					}
				}
				for (let playerId of oldPlayers) {
					if (players.indexOf(playerId) === -1) {
						handleRoomLeaveServerPacket(client, {data: {playerId: playerId}})
					}
				}
				return false
			}
		}
		client.room = {
			in: true,
			players: [client.uid]
		}
		if (client.settings.logRoom) {
			let mentions = []
			for (let player of players) {
				mentions.push(getPlayerMention(client, player))
				client.room.players.push(player)
			}
			if (mentions.length === 0)
				Logger.info('server', 'В комнате пусто')
			else
				Logger.info('server', 'В комнате: ' + mentions.join(', '))
		}
		if (client.settings.notifyRoom) {
			client.handlers.onRoomRound = function() {
				if (players.length > 0) {
					for (let player of players) {
						client.sendData('PacketChatMessage', {
							chatType: 0,
							playerId: player,
							message: '<span class=\'color3\'>Уже в комнате</span>'
						})
					}
				} else {
					client.sendData('PacketChatMessage', {
						chatType: 0,
						playerId: client.uid,
						message: '<span class=\'color3\'>В комнате пусто</span>'
					})
				}
			}
		}
		return false
	}

	function handleRoomJoinServerPacket(client, packet, buffer) {
		let {
			playerId,
			isPlaying
		} = packet.data
		client.room.players.push(playerId)
		if (isPlaying)
			client.round.players.push(playerId)
		if (client.settings.logRoom) {
			Logger.info('server', `${getPlayerMention(client, playerId)} вошел в комнату`)
		}
		if (client.settings.notifyRoom) {
			client.sendData('PacketChatMessage', {
				chatType: 0,
				playerId: playerId,
				message: '<span class=\'name_moderator\'>Вошел в комнату</span>'
			})
		}
		return false
	}

	function handleRoomLeaveServerPacket(client, packet, buffer) {
		let {
			playerId
		} = packet.data
		if (playerId === client.uid) {
			if (!client.player.moderator) {
				let spy = client.storage.spy
				if (spy && spy.state !== 0) {
					if (spy.state === 3) {
						setTimeout(function() {
							client.proxy.sendData('PLAY_WITH', spy.playerId)
						}, 3000)
					} else {
						client.proxy.sendData('PLAY_WITH', spy.playerId)
					}
					spy.state = 1
					spy.oldPlayers = client.room.players.slice()
					return true
				}
			}
			client.room = {
				in: false
			}
			client.round = {
				in: false
			}
			return false
		}
		client.room.players.splice(client.room.players.indexOf(playerId), 1)
		if (!client.player.moderator) {
			let spy = client.storage.spy
			let showSpyDialog = function() {
				runScript(client, true, `Est.showSpyDialog("${getPlayerMention(client, playerId)} вышел из локации", ${playerId});`)
			}
			if (spy && spy.playerId === playerId) {
				if (client.room.players.length === 1) {
					delete client.storage.spy
					client.proxy.sendData('LEAVE')
					client.handlers.onAbGuiAction = showSpyDialog;
				} else {
					for (let playerId of client.room.players) {
						if (playerId === client.uid)
							continue
						runScript(client, true, `Est.startSpy(${playerId});`)
						spy.playerId = playerId
						break
					}
					showSpyDialog();
				}
			}
		}
		if (client.settings.logRoom)
			Logger.info('server', `${getPlayerMention(client, playerId)} вышел из комнаты`)
		if (client.settings.notifyRoom) {
			client.sendData('PacketChatMessage', {
				chatType: 0,
				playerId: playerId,
				message: '<span class=\'color1\'>Вышел из комнаты</span>'
			})
		}
		return false
	}

	function handleRoundCommandServerPacket(client, packet, buffer) {
		let {
			playerId,
			dataJson
		} = packet.data
		if (constants.moderators.indexOf(playerId) !== -1 && client.room.players.indexOf(playerId) === -1 && !client.round.moderators[playerId]) {
			client.round.moderators[playerId] = true
			if (client.settings.warnModerators) {
				showMessage(client, `${getPlayerMention(client, playerId)} наблюдает`)
			}
			if (client.settings.notifyModerators) {
				client.sendData('PacketChatMessage', {
					chatType: 0,
					playerId: playerId,
					message: '<span class=\'color7\'>Наблюдает</span>'
				})
			}
			if (client.settings.logModerators) {
				Logger.info('server', `${getPlayerMention(client, playerId)} наблюдает`)
			}
		}
		if (!dataJson)
			return true
		if ('reportedPlayerId' in dataJson) {
			if (playerId === client.uid)
				return false
			if (client.settings.logReports)
				Logger.info('server', `${getPlayerMention(client, playerId)} кинул жалобу на ${getPlayerMention(client, dataJson.reportedPlayerId)}`)
			if (client.settings.notifyReports) {
				client.sendData('PacketChatMessage', {
					chatType: 0,
					playerId: playerId,
					message: `<span class=\'color3\'>Кинул жалобу на</span> <span class=\'color6\'>${getPlayerMention(client, dataJson.reportedPlayerId)}</span>`
				})
			}
			if (dataJson.reportedPlayerId === client.uid && client.settings.ignoreSelfReports)
				return true
		}
		if ('Create' in dataJson) {
			if (playerId === client.uid && client.round.ignoreSelfCreates) {
				client.round.ignoreSelfCreates--
				return true
			}
			if (client.settings.ignoreInvalidObjects && !isValidCreate(dataJson.Create)) {
				if (client.settings.logBadObjects)
					Logger.info('server', `${getPlayerMention(client, playerId)} пытался создать объект Entity ${dataJson.Create[0].toString()}`)
				if (client.settings.notifyObjects) {
					client.sendData('PacketChatMessage', {
						chatType: 0,
						playerId: playerId,
						message: `<span class=\'color3\'>Пытался создать объект</span> <span class=\'color1\'>Entity ${dataJson.Create[0].toString()}</span>`
					})
				}
				return true
			} else {
				for (player of client.round.players)
					client.round.mapObjects[player] = (client.round.mapObjects[player] || 0) + 1
			}
		}
		if ('Destroy' in dataJson) {
			if (playerId === client.uid) {
				if (client.round.ignoreSelfDestroys) {
					client.round.ignoreSelfDestroys--
					return true
				}
			} else {
				if ((client.settings.ignoreInvalidObjects && !isValidDestroy(dataJson.Destroy)) || (client.settings.createBeforeDestroy && !client.round.mapObjects[playerId]) || (client.settings.preserveMapObjects && 'mapObjects' in client.round && dataJson.Destroy[0] < client.round.mapObjects)) {
					if (client.settings.logBadObjects) {
						Logger.info('server', `${getPlayerMention(client, playerId)} пытался удалить объект ID ${dataJson.Destroy[0].toString()}`)
					}
					if (client.settings.notifyObjects) {
						client.sendData('PacketChatMessage', {
							chatType: 0,
							playerId: playerId,
							message: `<span class=\'color3\'>Пытался удалить объект</span> <span class=\'color6\'>ID ${dataJson.Destroy[0].toString()}</span>`
						})
					}
					if (client.round.mapObjects[playerId])
						client.round.mapObjects[playerId]--
					return true
				}
			}
		}
		return false
	}

	function handleRoundCastBeginServerPacket(client, packet, buffer) {
		let {
			playerId
		} = packet.data
		for (player of client.round.players)
			client.round.mapObjects[player] = (client.round.mapObjects[player] || 0) + 1
		if (client.settings.ignoreShamanCast)
			return client.storage.shamans.indexOf(playerId) !== -1
		return false
	}

	function handleRoundCastEndServerPacket(client, packet, buffer) {
		let {
			playerId,
			success
		} = packet.data
		if (!success)
			return false
		for (player of client.round.players) {
			if (client.round.mapObjects[player])
				client.round.mapObjects[player]--
		}
		if (client.settings.ignoreShamanCast)
			return client.storage.shamans.indexOf(playerId) !== -1
		return false
	}

	function handlePlayWithServerPacket(client, packet, buffer) {
		let {
			type
		} = packet.data
		if (client.player.moderator || !client.storage.spy)
			return false
		switch(type) {
			case PacketServer.PLAY_OFFLINE:
			case PacketServer.NOT_EXIST:
			case PacketServer.FULL_ROOM:
			case PacketServer.NOT_IN_CLAN:
			case PacketServer.UNAVAIABLE_LOCATION:
			case PacketServer.LOW_ENERGY:
				client.sendData('PacketRoomLeave', {playerId: client.uid})
	            delete client.storage.spy
	            break
	        case PacketServer.PLAY_FAILED:
	        	let player = getPlayerInfo(client, client.storage.spy.playerId)
	        	return !player.moderator && client.room.in
	    }
		return false
	}

	function handleRoundShamanServerPacket(client, packet, buffer) {
		let {
			playerId,
			teams
		} = packet.data
		client.storage.shamans = playerId.slice()
		return false
	}

	function handleRoundHollowServerPacket(client, packet, buffer) {
		let {
			success,
			playerId
		} = packet.data
		if (success === 0)
			client.round.hollow.push(playerId)
		return false
	}

	function handleServerPacket(client, packet, buffer) {
		Logger.debug('net', 'GameServer.onServerPacket', packet)
		switch (packet.type) {
			case 'PacketLogin':
				if (handleLoginServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketInfo':
				if (handleInfoServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketChatHistory':
				if (handleChatHistoryServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketChatMessage':
				if (handleChatMessageServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketExperience':
				if (handleExperienceServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketExpirations':
				if (handleExpirationsServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoom':
				if (handleRoomServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoomRound':
				if (handleRoomRoundServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoomJoin':
				if (handleRoomJoinServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoomLeave':
				if (handleRoomLeaveServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoundCommand':
				if (handleRoundCommandServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoundShaman':
				if (handleRoundShamanServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoundHollow':
				if (handleRoundHollowServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketRoundCastBegin':
				if (handleRoundCastBeginServerPacket(client, packet, buffer))
					return false
				break
			 case 'PacketRoundCastEnd':
				if (handleRoundCastEndServerPacket(client, packet, buffer))
					return false
				break
			case 'PacketPlayWith':
				if (handlePlayWithServerPacket(client, packet, buffer))
					return false
		}
		client.sendPacket(packet)
		while (client.defer.length > 0)
			client.defer.shift()()
		return true
	}

	function handleHelloClientPacket(client, packet, buffer) {
		client.storage = {}
		client.handlers = {}
		client.defer = []
		return false
	}

	function handleLoginClientPacket(client, packet, buffer) {
		client.storage.loginData = buffer.toString('base64')
		return false
	}

	function handleAbGuiActionClientPacket(client, packet, buffer) {
		if (client.handlers.onAbGuiAction) {
			client.handlers.onAbGuiAction(packet, buffer)
			delete client.handlers.onAbGuiAction
		}
		if (client.storage.injected)
			return;
		client.defer.push(function() {
			setTimeout(function() {
				runScriptFast(client, true, 'if(!Reflect.hasField(Game.self, "est")) {' + scripts.inject + 'Gs.est.sendData(Gs.est.packetId, "{\\"est\\":[\\"state\\",0,true]}");};')
			}, 5000)
		})
		return false
	}

	function handleRoundSkillClientPacket(client, packet, buffer) {
		let [code, activate, unk0, unk1] = packet.data
		if (client.storage.cancelNextSkill && activate) {
			delete client.storage.cancelNextSkill
			client.proxy.sendData('ROUND_SKILL', code, true, unk0, unk1)
			client.proxy.sendData('ROUND_SKILL', code, false, unk0, unk1)
			return true
		}
		return false
	}

	function handleRoundCommandClientPacket(client, packet, buffer) {
		let [data] = packet.data
		// console.log(data)
		if (!client.storage.injected && client.room.beingInjected) {
			if ('ScriptedTimer' in data || 'Sensor' in data) {
				client.sendData('PacketRoundCommand', {
					playerId: client.uid,
					dataJson: data
				})
				return true
			}
		}
		if ('est' in data) {
			switch (data['est'][0]) {
				case 'state':
					if (client.storage.injected)
						break
					switch (data['est'][1]) {
						case 0:
							if (data['est'][2])
								client.storage.fastInject = true
							else
								delete client.round.beingInjected
							var script = 'Est.sendData(Est.packetId, "{\\"est\\":[\\"state\\",1]}");'
							runScript(client, true, script)
							break
						case 1:
							client.storage.injected = true
							sendSettings(client)
							sendPlayerInfo(client)
							sendConstants(client)
							// runExternalScript(client, scripts.external)
							runScript(client, true, scripts.onAnyUpdate)
							runScript(client, true, scripts.onSettingsUpdate)
							runScript(client, true, scripts.onChangeRound)
							runScript(client, true, scripts.setMenu)
							runScript(client, true, scripts.setHotkeys)
							runScript(client, true, scripts.setHighlightObjects)
							runScript(client, true, scripts.setSpy)
							runScript(client, true, 'Est.onSettingsUpdate();')
							runScript(client, true, 'Est.onChangeRound();')
							if (!client.storage.fastInject)
								showMessage(client, 'Успешное внедрение в игру, все функции активны')
					}
					break
				case 'updateSetting':
					client.settings[data['est'][1]] = data['est'][2]
					updateSetting(client, data['est'][1], data['est'][2], false)
					saveSettings(client)
					break
				case 'updateData':
					let store = client
					let storeParts = data['est'][1].split('.')
					let storeLast = storeParts.pop()
					for (let part of storeParts) {
						store = store[part]
					}
					store[storeLast] = data['est'][2]
			}
			return true
		}
		return false
	}

	function handleRoundCastBeginClientPacket(client, packet, buffer) {
		let [id, data] = packet.data
		if (!data) {
			return true
		}
		let [entityId, objectData] = data[1]
		let isShaman = client.storage.shamans.indexOf(client.uid) !== -1
		if (entityId !== -1 && (!client.settings.infSquirrelItems || isShaman) && ((client.settings.forceCastObjects && isShaman) || client.storage.hackCastEntityId !== client.storage.lastCastEntityId))
			return false
		client.storage.lastCastObjectData = objectData
		return true
	}

	function handleRoundCastEndClientPacket(client, packet, buffer) {
		let [castType, id, success] = packet.data
		if (!success) {
			if (client.storage.ignoreNextFailedCast) {
				delete client.storage.ignoreNextFailedCast
				return true
			}
		} else {
			if (client.settings.noCastClear)
				client.storage.ignoreNextFailedCast = true
			if (!('lastCastObjectData' in client.storage))
				return client.settings.infSquirrelItems && castType === PacketClient.CAST_SQUIRREL
			if (!('lastCastEntityId' in client.storage))
				return true
			client.proxy.sendData('ROUND_COMMAND', {
				'Create': [client.storage.lastCastEntityId, client.storage.lastCastObjectData, true]
			})
			delete client.storage.lastCastObjectData
			return true
		}
	}

	function handleHelpCommand(client, chatType, args) {
		showMessage(client, 'Доступные команды:\n' +
			'\n' +
			'.version — версия программы\n' +
			'.player help — команды игрока\n' +
			'.clan help — команды клана\n' +
			'.hack help — команды хаков\n' +
			'.debug help — команды отладки')
	}

	function handleVersionCommand(client, chatType, args) {
		showMessage(client, 'Используется программа:\n' +
			'\n' +
			'sq-toolbox v' + package.version)
	}

	function handlePlayerSearchCommand(client, chatType, args) {
		let playerId = parseInt(args[0], 10)
		if (isNaN(playerId))
			return showMessage(client, 'Неправильный синтаксис')
		client.sendData('PacketChatMessage', {
			chatType: chatType,
			playerId: playerId,
			message: '<span class=\'color3\'>Я читерил — меня искали</span>'
		})
	}

	function handlePlayerCommand(client, chatType, args) {
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
			case undefined:
				showMessage(client, 'Подкоманды:\n' +
					'\n' +
					'.player search [id] — поиск игрока по ID')
				break
			case 'search':
				handlePlayerSearchCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная подкоманда')
		}
	}

	function handleClanDonateCommand(client, chatType, args) {
		let coins = parseInt(args[0], 10)
		let nuts = parseInt(args[1], 10)
		if (isNaN(coins) || isNaN(nuts))
			return showMessage(client, 'Неправильный синтаксис')
		client.proxy.sendData('CLAN_DONATION', coins, nuts)
		showMessage(client, `В клан внесено ${coins} монет ${nuts} орехов`)
	}

	function handleClanRenameCommand(client, chatType, args) {
		let name = args.join(' ')
		client.proxy.sendData('CLAN_RENAME', name)
		showMessage(client, `Клан теперь называется ${name}`)
	}

	function handleClanCommand(client, chatType, args) {
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
			case undefined:
				showMessage(client, 'Подкоманды:\n' +
					'\n' +
					'.clan donate [монеты] [орехи] — внести в клан монеты/орехи\n' +
					'.clan rename [имя] — переименовать клан')
				break
			case 'donate':
				handleClanDonateCommand(client, chatType, args)
				break
			case 'rename':
				handleClanRenameCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная подкоманда')
		}
	}

	function handleHackOlympicCommand(client, chatType, args) {
		if (client.room.in)
			return showMessage(client, 'Вы уже на локации')
		client.proxy.sendData('PLAY', 15, 0)
	}

	function handleHackSkillCommand(client, chatType, args) {
		if (!client.room.in)
			return showMessage(client, 'Вы не на локации')
		client.storage.cancelNextSkill = true
		showMessage(client, 'Следующая способность будет багнута отменой')
	}

	function handleHackCrashCommand(client, chatType, args) {
		if (!client.room.in)
			return showMessage(client, 'Вы не на локации')
		crashMap(client)
	}

	function handleHackScriptCommand(client, chatType, args) {
		let file = options.local.scriptsDir + '/' + args.shift()
		if (!client.room.in)
			return showMessage(client, 'Вы не на локации')
		if (client.storage.shamans.indexOf(client.uid) === -1)
			return showMessage(client, 'Вы не шаман')
		if (!fs.existsSync(file))
			return showMessage(client, 'Скрипт не найден')
		let script = fs.readFileSync(file, 'utf8')
		castMapTimer(client, !file.endsWith('.lua'), script)
	}

	function handleHackCommand(client, chatType, args) {
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
			case undefined:
				showMessage(client, 'Подкоманды:\n' +
					'\n' +
					'.hack olympic — локация "Стадион"\n' +
					'.hack skill — баг отмены способности\n' +
					'.hack crash — невалидный объект\n' +
					'.hack script [имя] — выполнить скрипт всем')
				break
			case 'olympic':
				handleHackOlympicCommand(client, chatType, args)
				break
			case 'skill':
				handleHackSkillCommand(client, chatType, args)
				break
			case 'crash':
				handleHackCrashCommand(client, chatType, args)
				break
			case 'script':
				handleHackScriptCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная подкоманда')
		}
	}

	function handleDebugDumpPlayerCommand(client, chatType, args) {
		if (client.storage.injected)
			return runExternalScript(client, 'window.prompt("Скопируйте данные игрока.", "' + Buffer.from(JSON.stringify(client.player)).toString('base64') + '");')
		showMessage(client, 'Дамп данных игрока:\n' +
			'\n' +
			Buffer.from(JSON.stringify(client.player)).toString('base64'))
	}

	function handleDebugDumpLoginCommand(client, chatType, args) {
		if (client.storage.injected)
			return runExternalScript(client, 'window.prompt("Скопируйте данные входа.\\n\\nВНИМАНИЕ!!! НИКОМУ НЕ ПЕРЕДАВАЙТЕ ЭТИ ДАННЫЕ", "' + client.storage.loginData + '");')
		showMessage(client, 'ВНИМАНИЕ!!! НИКОМУ НЕ ПЕРЕДАВАЙТЕ ЭТИ ДАННЫЕ!!!\n' +
			'\n' +
			'Дамп данных входа:\n' +
			'\n' +
			client.storage.loginData)
	}

	function handleDebugDumpStorageCommand(client, chatType, args) {
		if (client.storage.injected)
			return runExternalScript(client, 'window.prompt("Скопируйте данные сессии.\\n\\nВНИМАНИЕ!!! НИКОМУ НЕ ПЕРЕДАВАЙТЕ ЭТИ ДАННЫЕ", "' + JSON.stringify(client.storage).replace(/\"/g, "'") + '");')
		showMessage(client, 'ВНИМАНИЕ!!! НИКОМУ НЕ ПЕРЕДАВАЙТЕ ЭТИ ДАННЫЕ!!!\n' +
			'\n' +
			'Дамп данных сессии:\n' +
			'\n' +
			JSON.stringify(client.storage).replace(/\"/g, "'"))
	}

	function handleDebugDumpCommand(client, chatType, args) {
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
			case undefined:
				showMessage(client, 'Подкоманды:\n' +
					'\n' +
					'.debug dump player — данные профиля\n' +
					'.debug dump login — данные входа' +
					'.debug dump storage — данные хранилища')
				break
			case 'player':
				handleDebugDumpPlayerCommand(client, chatType, args)
				break
			case 'login':
				handleDebugDumpLoginCommand(client, chatType, args)
				break
			case 'storage':
				handleDebugDumpStorageCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная подкоманда')
		}
	}

	function handleDebugScriptCommand(client, chatType, args) {
		let file = options.local.scriptsDir + '/' + args.shift()
		if (!client.storage.injected)
			return showMessage(client, 'Не удалось запустить скрипт')
		if (!fs.existsSync(file))
			return showMessage(client, 'Скрипт не найден')
		let script = fs.readFileSync(file, 'utf8')
		if (file.endsWith('.js'))
			runExternalScript(client, script)
		else
			runScript(client, !file.endsWith('.lua'), script)
	}

	function handleDebugCommand(client, chatType, args) {
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
			case undefined:
				showMessage(client, 'Доступные подкоманды:\n' +
					'\n' +
					'.debug dump help — данные отладки\n' +
					'.debug script [имя] — запустить скрипт')
				break
			case 'dump':
				handleDebugDumpCommand(client, chatType, args)
				break
			case 'script':
				handleDebugScriptCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная подкоманда')
		}
	}

	function handleChatMessageClientPacket(client, packet, buffer) {
		let [chatType, msg] = packet.data
		if (!msg.startsWith('.'))
			return false
		if (msg === '.')
			return false
		if (!client.settings.chatCommands)
			return false
		let args = msg.substring(1).split(' ')
		let cmd = args.shift()
		switch (cmd) {
			case 'help':
				handleHelpCommand(client, chatType, args)
				break
			case 'version':
				handleVersionCommand(client, chatType, args)
				break
			case 'player':
				handlePlayerCommand(client, chatType, args)
				break
			case 'clan':
				handleClanCommand(client, chatType, args)
				break
			case 'hack':
				handleHackCommand(client, chatType, args)
				break
			case 'debug':
				handleDebugCommand(client, chatType, args)
				break
			default:
				showMessage(client, 'Неизвестная команда')
		}
		return true
	}

	function handleSpyForClientPacket(client, packet, buffer) {
		let [playerId] = packet.data
		if (client.player.moderator)
			return false
		if (client.storage.spy && client.room.players.indexOf(playerId) !== 0)
			return true
		client.storage.spy = {
			state: 0,
			playerId: playerId
		}
		if (client.room.in)
			client.proxy.sendData('LEAVE')
		client.proxy.sendData('PLAY_WITH', playerId)
		return true
	}

	function handlePlayWithClientPacket(client, packet, buffer) {
		let [id] = packet.data
		if (client.player.moderator)
			return false
		if (client.storage.spy) {
			if (client.room.in)
				client.proxy.sendData('LEAVE')
			delete client.storage.spy
		}
		return false
	}

	function handleLeaveClientPacket(client, packet, buffer) {
		if (!client.player.moderator && client.storage.spy)
			delete client.storage.spy
		return false
	}

	function handleClientPacket(client, packet, buffer) {
		Logger.debug('net', 'GameServer.onClientPacket', packet)
		switch (packet.type) {
			case 'HELLO':
				handleHelloClientPacket(client, packet, buffer)
				break
			case 'LOGIN':
				if (handleLoginClientPacket(client, packet, buffer))
					return false
				break
			case 'AB_GUI_ACTION':
				if (handleAbGuiActionClientPacket(client, packet, buffer))
					return false
				break
			case 'ROUND_SKILL':
				if (handleRoundSkillClientPacket(client, packet, buffer))
					return false
				break
			case 'ROUND_COMMAND':
				if (handleRoundCommandClientPacket(client, packet, buffer))
					return false
				break
			case 'ROUND_CAST_BEGIN':
				if (handleRoundCastBeginClientPacket(client, packet, buffer))
					return false
				break
			case 'ROUND_CAST_END':
				if (handleRoundCastEndClientPacket(client, packet, buffer))
					return false
				break
			case 'CHAT_MESSAGE':
				if (handleChatMessageClientPacket(client, packet, buffer))
					return false
				break
			case 'SPY_FOR':
				if (handleSpyForClientPacket(client, packet, buffer))
					return false
				break
			case 'LEAVE':
				if (handleLeaveClientPacket(client, packet, buffer))
					return false
		}
		client.proxy.sendPacket(packet)
	}

	function createProxy(client, ports, host) {
		let proxy = new GameClient({
			port: ports[Math.floor(Math.random() * ports.length)],
			host: host
		})
		proxy.on('client.connect', () => client.open())
		proxy.on('client.close', () => client.close())
		proxy.on('client.error', () => client.close())
		proxy.on('client.timeout', () => client.close())
		proxy.on('packet.incoming', (...args) => handleServerPacket(client, ...args))
		return proxy
	}

	function handleConnect(client, ports, host) {
		clients.push(client)
		client.proxy = createProxy(client, ports, host)
		client.proxy.open()
		return true
	}

	function handleClose(client) {
		let index = clients.indexOf(client)
		if (index !== -1) {
			if (client.uid)
				Logger.info('server', `Вы вышли как ${getPlayerMention(client, client.uid)}`)
			clients.splice(index, 1)
		}
		if (!client.proxy)
			return true
		client.proxy.close()
		return true
	}

	const clients = []
	const gameServer = new GameServer({
		port: JSON.parse(options.local.ports),
		host: '127.0.0.1',
		manualOpen: true
	})
	gameServer.on('client.connect', (client) => handleConnect(client, JSON.parse(options.remote.ports), options.remote.host))
	gameServer.on('client.close', handleClose)
	gameServer.on('client.error', handleClose)
	gameServer.on('client.timeout', handleClose)
	gameServer.on('packet.incoming', handleClientPacket)
	return gameServer
}
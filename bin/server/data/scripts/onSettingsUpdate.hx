function onSettingsUpdate() {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	var playerInfo = Est.playerInfo;
	var oldSettings = Est.oldSettings;
	var isFirstRun = oldSettings == null;
	function isChanged(name, except) {
		if(isFirstRun) {
			if(except == settings[name]) {
				return false;
			}
			return true;
		}
		return settings[name] != oldSettings[name];
	}
	if(isChanged("fakeModerator", null)) {
		Gs.moderator = playerInfo.moderator || settings.fakeModerator;
	}
	if(isChanged("fakeEditorAccess", null)) {
		if(settings.fakeEditorAccess) {
			Est.oldEditorAccess = Game.editor_access;
			Game.editor_access = 1;
		} else {
			if(Reflect.hasField(Est, "oldEditorAccess")) {
				Game.editor_access = Est.oldEditorAccess;
			}
		}
	}
	if(isChanged("noChatRestrictions", null)) {
		var gameSprite = Game.gameSprite.getChildAt(0);
		var Footers = gameSprite.getChildAt(1);
		var FooterTop = Footers.getChildAt(0);
		var ChatCommon = FooterTop.getChildAt(0);
		var oldInputBoxCommon = ChatCommon.getChildAt(1);
		var Chat = Game.chat;
		var oldInputBoxGame = Chat.getChildAt(2);
		if(!Reflect.hasField(Est, "oldInputBoxCommon")) {
			var TextFormat = Type.resolveClass("flash.text.TextFormat");
			var TextField = Type.resolveClass("flash.text.TextField");
			var TextFieldType = Type.resolveClass("flash.text.TextFieldType");
			var TextFieldUtil = Type.resolveClass("utils.TextFieldUtil");
			var directionCommon = ChatCommon.getChildAt(0);
			var inputFormatCommon = Type.createInstance(TextFormat, [GameField.DEFAULT_FONT, 12, 15285822, true]);
			inputFormatCommon.indent = directionCommon.textWidth - 15;
			var inputBoxCommon = Type.createInstance(TextField, []);
			inputBoxCommon.type = TextFieldType.INPUT;
			inputBoxCommon.text = "";
			inputBoxCommon.wordWrap = false;
			inputBoxCommon.multiline = false;
			inputBoxCommon.x = 28;
			inputBoxCommon.y = 377;
			inputBoxCommon.width = 215;
			inputBoxCommon.height = 20;
			inputBoxCommon.selectable = true;
			inputBoxCommon.defaultTextFormat = inputFormatCommon;
			inputBoxCommon.maxChars = 128;
			TextFieldUtil.embedFonts(inputBoxCommon);
			var directionGame = Chat.getChildAt(1);
			var inputFormatGame = Type.createInstance(TextFormat, [GameField.DEFAULT_FONT, 13, 15285822]);
			inputFormatGame.indent = directionGame.textWidth - 15;
			var inputBoxGame = Type.createInstance(TextField, []);
			inputBoxGame.text = "";
			inputBoxGame.type = TextFieldType.INPUT;
		 	inputBoxGame.wordWrap = false;
			inputBoxGame.multiline = false;
			inputBoxGame.x = 14;
		 	inputBoxGame.y = 3;
		 	inputBoxGame.width = 240;
		 	inputBoxGame.height = 65;
		 	inputBoxGame.selectable = true;
		 	inputBoxGame.defaultTextFormat = inputFormatGame;
		 	inputBoxGame.maxChars = 128;
			TextFieldUtil.embedFonts(inputBoxGame);
			var Keyboard = Type.resolveClass("flash.ui.Keyboard");
			var KeyboardEvent = Type.resolveClass("flash.events.KeyboardEvent");
			var Screens = Type.resolveClass("screens.Screens");
			var StringUtil = Type.resolveClass("utils.StringUtil");
			inputBoxCommon.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
				if(e.keyCode != Keyboard.ENTER) {
					return;
				}
				var screen = Type.getClassName(Type.getClass(Screens.active));
				if(screen == "screens.ScreenGame" || screen == "screens.ScreenLearning") {
					return;
				}
				var message = inputBoxCommon.text;
				inputBoxCommon.text = "";
				message = StringUtil.trim(message);
				if(message == "") {
					return;
				}
				var PacketClient = Type.resolveClass("protocol.PacketClient");
				Est.sendData(PacketClient.CHAT_MESSAGE, ChatCommon.currentChat.type, message);
			});
			inputBoxGame.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
				if(e.keyCode != Keyboard.ENTER) {
					return;
				}
				var screen = Type.getClassName(Type.getClass(Screens.active));
				if(screen != "screens.ScreenGame") {
					return;
				}
				var message = inputBoxGame.text;
				inputBoxGame.text = "";
				message = StringUtil.trim(message);
				if(message == "") {
					return;
				}
				var PacketClient = Type.resolveClass("protocol.PacketClient");
				Est.sendData(PacketClient.CHAT_MESSAGE, 0, message);
			});
			Est.oldInputBoxCommon = inputBoxCommon;
			Est.oldInputBoxGame = inputBoxGame;
			Est.setInterval(function(dt) {
				if(!settings.noChatRestrictions) {
					return;
				}
				if(Game.stage.focus == Est.oldInputBoxCommon) {
					if(!ChatCommon.visible) {
						Game.stage.focus = Game.stage;
					} else {
						inputBoxCommon.text = "";
						Est.oldInputBoxCommon.text = "";
						Game.stage.focus = inputBoxCommon;
					}
					return;
				}
				if(Game.stage.focus == Est.oldInputBoxGame) {
					if(!Chat.visible) {
						Game.stage.focus = Game.stage;
					} else {
						inputBoxGame.text = "";
						Est.oldInputBoxGame.text = "";
						Game.stage.focus = inputBoxGame;
					}
				}
				var Hs = Hero.self;
				if(Hs == null) {
					return;
				}
				if(Game.stage.focus == inputBoxGame) {
					if(Chat.visible) {
						if(!Hs.isStoped) {
							Hs.isStoped = true;
						}
					} else {
						while(Hs.isStoped) {
							Hs.isStoped = false;
						}
					}
					return;
				}
				while(Hs.isStoped) {
					Hs.isStoped = false;
				}
			}, 100);
		}
		if(settings.noChatRestrictions || !isFirstRun) {
			var newInputBoxCommon = Est.oldInputBoxCommon;
			Est.oldInputBoxCommon = oldInputBoxCommon;
			ChatCommon.removeChildAt(1);
			ChatCommon.addChildAt(newInputBoxCommon, 1);
			var newInputBoxGame = Est.oldInputBoxGame;
			Est.oldInputBoxGame = oldInputBoxGame;
			Chat.removeChildAt(2);
			Chat.addChildAt(newInputBoxGame, 2);
		}
	}
	var Sg = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(Sg != null) {
		if(isChanged("showSensors", null)) {
			var gameObjects = Sg.map.gameObjects();
			var i = 0;
			while(i < gameObjects.length) {
				var className = Type.getClassName(Type.getClass(gameObjects[i]));
				if(className == "game.mainGame.entity.editor.Sensor" || className == "game.mainGame.entity.editor.SensorRect") {
					gameObjects[i].showDebug = settings.showSensors;
				}
				i++;
			}
		}
		if(isChanged("infRadius", null)) {
			if(settings.infRadius) {
				if(Sg.cast.castRadius != 0) {
					Est.oldCastRadius = Sg.cast.castRadius;
				}
				if(Sg.cast.runCastRadius != 262144) {
					Est.oldRunRadius = Sg.cast.runCastRadius;
				}
				if(Sg.cast.telekinezRadius != 262144) {
					Est.oldTelekinezRadius = Sg.cast.telekinezRadius;
				}
				Sg.cast.castRadius = 0;
			} else {
				if(Reflect.hasField(Est, "oldCastRadius")) {
					Sg.cast.castRadius = Est.oldCastRadius;
				}
				if(Reflect.hasField(Est, "oldRunRadius")) {
					Sg.cast.runCastRadius = Est.oldRunRadius;
				}
				if(Reflect.hasField(Est, "oldTelekinezRadius")) {
					Sg.cast.telekinezRadius = Est.oldTelekinezRadius;
				}
			}
		}
		if(isChanged("instantCast", null)) {
			if(settings.instantCast) {
				if(Sg.cast.castTime != 0) {
					Est.oldCastTime = Sg.cast.castTime;
				}
				Sg.cast.castTime = 0;
			} else {
				if(Reflect.hasField(Est, "oldCastTime")) {
					Sg.cast.castTime = Est.oldCastTime;
				}
			}
		}
		if(isChanged("highlightObjects", null)) {
			if(!settings.highlightObjects) {
				if(Reflect.hasField(Est, "lastHighlightObjectId") && Est.lastHighlightObjectId != -1) {
					var gameObjects = Sg.map.gameObjects();
					var oldObject = gameObjects[Est.lastHighlightObjectId];
					var newFilters = oldObject.filters;
					newFilters.splice(newFilters.indexOf(Est.highlightObjectFilter), 1);
					oldObject.filters = newFilters;
				}
			}
		}
		var Hs = Hero.self;
		if(Hs != null) {
			if(isChanged("alwaysImmortal", false)) {
				Hs.immortal = settings.alwaysImmortal;
			}
			if(isChanged("ghostMode", null)) {
				Hs.ghost = settings.ghostMode;
			}
			if(isChanged("infJumps", null)) {
				if(settings.infJumps) {
					while(Hs.maxInAirJumps < 1000) {
						Hs.maxInAirJumps++;
					}
				} else {
					while(Hs.maxInAirJumps > 0) {
						Hs.maxInAirJumps--;
					}
				}
			}
			if(isChanged("allShamanItems", null)) {
				if(settings.allShamanItems) {
					var shamanTools = Hs.game.map.shamanTools;
					var createdVar = false;
					var items = [42, 8, 7, 6, 5, 4, 53, 2, 0, 47];
					var i = 0;
					while(i < items.length) {
						if(shamanTools.indexOf(items[i]) == -1) {
							if(!createdVar) {
								Est.addedShamanToolsItems = [];
								createdVar = true;
							}
							Est.addedShamanToolsItems.push(items[i]);
						}
						i++;
					}
					if(createdVar) {
						i = 0;
						while(i < items.length) {
							var index = shamanTools.indexOf(items[i]);
							if(index != -1) {
								shamanTools.splice(index, 1);
							}
							shamanTools.unshift(items[i]);
							i++;
						}
						var FooterGame = Type.resolveClass("footers.FooterGame");
						FooterGame.hero = null;
						FooterGame.hero = Hs;
					}
				} else {
					if(Reflect.hasField(Est, "addedShamanToolsItems")) {
						var shamanTools = Hs.game.map.shamanTools;
						var addedItems = Est.addedShamanToolsItems;
						var changed = false;
						var i = 0;
						while(i < addedItems.length) {
							var index = shamanTools.indexOf(addedItems[i]);
							if(index != -1) {
								shamanTools.splice(index, 1);
								changed = true;
								i--;
							}
							i++;
						}
						if(changed) {
							var FooterGame = Type.resolveClass("footers.FooterGame");
							FooterGame.hero = null;
							FooterGame.hero = Hs;
						}
					}
				}
			}
			if(isChanged("allPins", null)) {
				if(settings.allPins) {
					var shamanTools = Hs.game.map.shamanTools;
					var createdVar = false;
					var pins = [-16, -17, 18, 19, 33, 34, 35, 36];
					var i = 0;
					while(i < pins.length) {
						var pinExist = false;
						if(pins[i] >= 0) {
							pinExist = shamanTools.indexOf(pins[i]) != -1;
						} else {
							pinExist = shamanTools.indexOf(pins[i] * -1) == -1;
						}
						if(!pinExist) {
							if(!createdVar) {
								Est.addedShamanToolsPins = [];
								createdVar = true;
							}
							Est.addedShamanToolsPins.push(pins[i]);
							if(pins[i] >= 0) {
								shamanTools.push(pins[i]);
							} else {
								shamanTools.splice(shamanTools.indexOf(pins[i] * -1), 1);
							}
						}
						i++;
					}
				} else {
					if(Reflect.hasField(Est, "addedShamanToolsPins")) {
						var shamanTools = Hs.game.map.shamanTools;
						var addedPins = Est.addedShamanToolsPins;
						var changed = false;
						var i = 0;
						while(i < addedPins.length) {
							var index = shamanTools.indexOf(Math.abs(addedPins[i]));
							if(addedPins[i] >= 0) {
								if(index != -1) {
									shamanTools.splice(index, 1);
									changed = true;
									i--;
								}
							} else {
								if(index == -1) {
									shamanTools.push(addedPins[i] * -1, 1);
									changed = true;
									i--;
								}
							}
							i++;
						}
					}
				}
			}
			if(isChanged("instantCast", null)) {
				if(settings.instantCast) {
					if(Hs.useRunningCast != true) {
						Est.oldRunCast = Hs.useRunningCast;
					}
					Hs.useRunningCast = true;
				} else {
					if(Reflect.hasField(Est, "oldRunCast")) {
						Hs.useRunningCast = Est.oldRunCast;
					}
				}
			}
		}
	}
	Est.oldSettings = JSON.parse(JSON.stringify(settings));
}
Est.onSettingsUpdate = onSettingsUpdate;
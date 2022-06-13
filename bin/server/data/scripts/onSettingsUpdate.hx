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
	if(isChanged("ignoreGag", null)) {
		if(!settings.ignoreGag) {
			var time = Est.getTimer() / 1000;
			if(Reflect.hasField(Est, "oldGagTime") && Est.oldGagTime - time > 1.5) {
				Game.gagTime = Est.oldGagTime;
				if(Game.chat != null) {
					Game.chat.setGag();
				}
				var ChatCommon = Type.resolveClass("chat.ChatCommon");
				ChatCommon.setGag();
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
		if(isChanged("showSensors", null)) {
			var gameObjects = Hs.game.map.gameObjects();
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
				if(Hs.game.cast.castRadius != 0) {
					Est.oldCastRadius = Hs.game.cast.castRadius;
				}
				if(Hs.game.cast.runCastRadius != 262144) {
					Est.oldRunRadius = Hs.game.cast.runCastRadius;
				}
				if(Hs.game.cast.telekinezRadius != 262144) {
					Est.oldTelekinezRadius = Hs.game.cast.telekinezRadius;
				}
				Hs.game.cast.castRadius = 0;
			} else {
				if(Reflect.hasField(Est, "oldCastRadius")) {
					Hs.game.cast.castRadius = Est.oldCastRadius;
				}
				if(Reflect.hasField(Est, "oldRunRadius")) {
					Hs.game.cast.runCastRadius = Est.oldRunRadius;
				}
				if(Reflect.hasField(Est, "oldTelekinezRadius")) {
					Hs.game.cast.telekinezRadius = Est.oldTelekinezRadius;
				}
			}
		}
		if(isChanged("instantCast", null)) {
			if(settings.instantCast) {
				if(Hs.useRunningCast != true) {
					Est.oldRunCast = Hs.useRunningCast;
				}
				if(Hs.game.cast.castTime != 0) {
					Est.oldCastTime = Hs.game.cast.castTime;
				}
				Hs.useRunningCast = true;
				Hs.game.cast.castTime = 0;
			} else {
				if(Reflect.hasField(Est, "oldRunCast")) {
					Hs.useRunningCast = Est.oldRunCast;
				}
				if(Reflect.hasField(Est, "oldCastTime")) {
					Hs.game.cast.castTime = Est.oldCastTime;
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
		if(isChanged("highlightObjects", null)) {
			if(settings.highlightObjects) {
				if(!Reflect.hasField(Est, "highlightObjectFilter")) {
					var GlowFilter = Type.resolveClass("flash.filters.GlowFilter");
					Est.highlightObjectFilter = Type.createInstance(GlowFilter, [16711680, 1, 12, 12, 5, 1, true]);
				}
			} else {
				if(Reflect.hasField(Est, "lastHighlightObjectId") && Est.lastHighlightObjectId != -1) {
					var gameObjects = Hs.game.map.gameObjects();
					var oldObject = gameObjects[Est.lastHighlightObjectId];
					var newFilters = oldObject.filters;
					newFilters.splice(newFilters.indexOf(Est.highlightObjectFilter), 1);
					oldObject.filters = newFilters;
				}
			}
		}
	}
	Est.oldSettings = JSON.parse(JSON.stringify(settings));
}
Est.onSettingsUpdate = onSettingsUpdate;
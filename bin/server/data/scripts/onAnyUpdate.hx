function onAnyUpdate(dt) {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	if(settings == null) {
		return;
	}
	var Sg = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(Sg == null) {
		if(settings.noCastClear && Reflect.hasField(Est, "castClearSetup")) {
			Est.castClearSetup = false;
		}
		return;
	}
	if(settings.ignoreGag) {
		var time = Est.getTimer() / 1000;
		if((Game.gagTime - time) > 1.5) {
			if(!Reflect.hasField(Est, "oldGagTime") || Est.oldGagTime < Game.gagTime) {
				Est.oldGagTime = Game.gagTime;
			}
			Game.gagTime = time + 1.5;
			if(Game.chat != null) {
				Game.chat.setGag();
			}
			var ChatCommon = Type.resolveClass("chat.ChatCommon");
			ChatCommon.setGag();
		}
	}
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
		Sg.cast.runCastRadius = 262144;
		Sg.cast.telekinezRadius = 262144;
	}
	if(settings.instantCast) {
		if(Sg.cast.castTime != 0) {
			Est.oldCastTime = Sg.cast.castTime;
		}
		Sg.cast.castTime = 0;
	}
	var castObject = Sg.cast.castObject;
	if(castObject != null) {
		var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
		var entityId = EntityFactory.getId(Sg.cast.castObject);
		if(!Reflect.hasField(Est, "lastCastEntityId") || Est.lastCastEntityId != entityId) {
			Est.lastCastEntityId = entityId;
			Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "storage.lastCastEntityId", entityId]}));
		}
	}
	var Hs = Hero.self;
	if(Hs == null) {
		return;
	}
	if(settings.alwaysImmortal) {
		Hs.immortal = true;
	}
	if(settings.ghostMode) {
		Hs.ghost = true;
	}
	if(settings.infJumps) {
		while(Hs.maxInAirJumps < 1000) {
			Hs.maxInAirJumps++;
		}
	}
	var PerkShamanFactory = Type.resolveClass("game.mainGame.perks.shaman.PerkShamanFactory");
	var ShamanToolBar = Type.resolveClass("game.mainGame.perks.shaman.ui.ShamanToolBar");
	var perkController = Hs.perkController;
	if(settings.allShamanPerks) {
		if(perkController.perksShaman.length < 21) {
			var i = 0;
			while(i < PerkShamanFactory.perkCollection.length)
			{
				var found = -1;
				var o = 0;
				while(o < perkController.perksShaman.length)
				{
					var perk = perkController.perksShaman[o];
					if(perk.code == i) {
						found = o;
						break;
					}
					o++;
				}
				var catchyPassivePerk = [0, 3, 7, 8, 10, 11, 17, 18, 22, 26, 28, 29, 32, 35, 36, 47, 50].indexOf(i) != -1;
				var notWorkingPerk = [1, 4, 12, 13, 14, 15, 16, 25, 31, 33, 37, 43, 44, 51].indexOf(i) != -1;
				if(found != -1 || (!catchyPassivePerk && !notWorkingPerk)) {
					if(found == -1) {
						found = perkController.perksShaman.length;
					} else {
						perkController.perksShaman[found].dispose();
					}
					var perkClass = PerkShamanFactory.perkCollection[i];
					var perk = Type.createInstance(perkClass, [Hs, [3, 3]]);
					if(Hs.shaman && !PerkShamanFactory.perkData[perkClass].active) {
						perk.active = true;
					}
					perkController.perksShaman[found] = perk;
				}
				i++;
			}
			ShamanToolBar.hero = Hs;
		}
	}
	if(settings.noCdPerks) {
		var i = 0;
		while(i < perkController.perksClothes.length)
		{
			var perk = perkController.perksClothes[i];
			try {
				perk.currentCooldown = 0;
			} catch(e:Dynamic) {};
			try {
				perk.activationCount = 0;
			} catch(e:Dynamic) {};
			i++;
		}
		i = 0;
		while(i < perkController.perksHare.length)
		{
			var perk = perkController.perksHare[i];
			try {
				perk.currentCooldown = 0;
			} catch(e:Dynamic) {};
			try {
				perk.activationCount = 0;
			} catch(e:Dynamic) {};
			i++;
		}
		i = 0;
		while(i < perkController.perksCharacter.length)
		{
			var perk = perkController.perksCharacter[i];
			try {
				perk.currentCooldown = 0;
			} catch(e:Dynamic) {};
			try {
				perk.activationCount = 0;
			} catch(e:Dynamic) {};
			i++;
		}
		i = 0;
		while(i < perkController.perksDragon.length)
		{
			var perk = perkController.perksDragon[i];
			try {
				perk.currentCooldown = 0;
			} catch(e:Dynamic) {};
			try {
				perk.activationCount = 0;
			} catch(e:Dynamic) {};
			i++;
		}
		i = 0;
		while(i < perkController.perksShaman.length)
		{
			var perk = perkController.perksShaman[i];
			try {
				perk.currentCooldown = 0;
			} catch(e:Dynamic) {};
			try {
				perk.activationCount = 0;
			} catch(e:Dynamic) {};
			i++;
		}
	}
	if(settings.instantCast) {
		if(Hs.useRunningCast != true) {
			Est.oldRunCast = Hs.useRunningCast;
		}
		Hs.useRunningCast = true;
	}
	if(settings.allShamanItems) {
		var shamanTools = Sg.map.shamanTools;
		var createdVar = false;
		var items = [0, 2, 4, 5, 6, 7, 8, 42, 47, 53];
		var i = 0;
		while(i < items.length) {
			if(shamanTools.indexOf(items[i]) == -1) {
				if(!createdVar) {
					Est.addedShamanToolsItems = [];
					createdVar = true;
				}
				Est.addedShamanToolsItems.push(items[i]);
				shamanTools.push(items[i]);
			}
			i++;
		}
		if(createdVar) {
			var FooterGame = Type.resolveClass("footers.FooterGame");
			FooterGame.hero = null;
			FooterGame.hero = Hs;
		}
	}
	if(settings.allPins) {
		var shamanTools = Sg.map.shamanTools;
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
	}
	if(!Reflect.hasField(Est, "castClearSetup") || !Est.castClearSetup) {
		function onCastEvent(e) {
			var Cast = Type.resolveClass("game.mainGame.Cast");
			var settings = Est.settings;
			if(e == Cast.CAST_DROP || e == Cast.CAST_CANCEL) {
				Est.setTimeout(function(dt) {
					if(Hero.self.game.cast.castObject == null) {
						if(Reflect.hasField(Game.self.est, "hackCastEntityId")) {
							Game.self.est.sendData(Game.self.est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", -1]}));
						}
					}
				}, 1);
				return;
			}
			if(e == Cast.CAST_COMPLETE) {
				if(settings.noCastClear) {
					var Screens = Type.resolveClass("screens.Screens");
					if(Type.getClassName(Type.getClass(Screens.active)) == "screens.ScreenGame") {
						throw "";
					}
				}
			}
		}
		Hs.game.cast.listen(onCastEvent);
		Est.castClearSetup = true;
	}
	var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
	if(settings.disableKickTimer) {
		ControllerHeroLocal.resetKickTimer();
	}
}
Est.addLoggerHandler(function(message) {
	var isIn = message.indexOf("Received server packet [object PacketRound") != -1;
	var isOut = message.indexOf("Sending packet with type") != -1 && message.indexOf(", ROUND_") != -1;
	if(!isIn && !isOut) {
		return;
	}
	onAnyUpdate(null);
	return true;
});
Est.setInterval(onAnyUpdate, 1000);
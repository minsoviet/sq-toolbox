function onAnyUpdate(dt) {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	if(settings == null) {
		return;
	}
	var Hs = Hero.self;
	if(Hs == null) {
		if(settings.noCastClear && Reflect.hasField(Est, "castClearSetup")) {
			Est.castClearSetup = false;
		}
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
		Hs.game.cast.runCastRadius = 262144;
		Hs.game.cast.telekinezRadius = 262144;
	}
	if(settings.instantCast) {
		if(Hs.useRunningCast != true) {
			Est.oldRunCast = Hs.useRunningCast;
		}
		if(Hs.game.cast.castTime != 0) {
			Est.oldCastTime = Hs.game.cast.castTime;
		}
		Hs.useRunningCast = true;
		Hs.game.cast.castTime = 0;
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
				var catchyPassivePerk = i == 0 || i == 3 || i == 7 || i == 8 || i == 10 || i == 11 || i == 17 || i == 18 || i == 22 || i == 26 || i == 28 || i == 29 || i == 32 || i == 35 || i == 36 || i == 47 || i == 50;
				var notWorkingPerk = i == 1 || i == 4 || i == 12 || i == 13 || i == 14 || i == 15 || i == 16 || i == 25 || i == 31 || i == 33 || i == 37 || i == 43 || i == 44 || i == 51;
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

	var castObject = Hs.game.cast.castObject;
	if(castObject != null) {
		var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
		var entityId = EntityFactory.getId(castObject);
		if(!Reflect.hasField(Est, "lastCastEntityId") || Est.lastCastEntityId != entityId) {
			Est.lastCastEntityId = entityId;
			Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "storage.lastCastEntityId", entityId]}));
		}
	}

	if(!Reflect.hasField(Est, "castClearSetup") || !Est.castClearSetup) {
		function onCastEvent(e) {
			var Cast = Type.resolveClass("game.mainGame.Cast");
			var settings = Game.self.est.settings;
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
	if(settings.allShamanItems) {
		var shamanTools = Hs.game.map.shamanTools;
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
	}
	var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
	if(settings.disableKickTimer) {
		ControllerHeroLocal.resetKickTimer();
	}
};

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

var Keyboard = Type.resolveClass("flash.ui.Keyboard");
var KeyboardEvent = Type.resolveClass("flash.events.KeyboardEvent");
Game.stage.addEventListener(KeyboardEvent.KEY_UP, function(e) {
	var settings = Game.self.est.settings;
	if(settings == null) {
		return;
	}
	if(!settings.hotkeys) {
		return;
	}
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	if(!Reflect.hasField(Game.self.est, "lastKeyPress") || Game.self.est.lastKeyPress != e.keyCode) {
		return;
	}
	Game.self.est.lastKeyPress = null;
});
Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
	var settings = Game.self.est.settings;
	if(settings == null) {
		return;
	}
	if(!settings.hotkeys) {
		return;
	}
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	if(Reflect.hasField(Game.self.est, "lastKeyPress") && Game.self.est.lastKeyPress == e.keyCode) {
		return;
	}
	Game.self.est.lastKeyPress = e.keyCode;
	var Hs = Hero.self;
	if(Hs == null) {
		return;
	}
	if(e.ctrlKey) {
		if(e.keyCode == Keyboard.E) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			if(Hs.hasNut) {
				Hs.setMode(Hero.NUDE_MOD);
				Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
			} else {
				Hs.setMode(Hero.NUT_MOD);
				Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			}
			return;
		}
		if(e.keyCode == Keyboard.R) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			Hs.onHollow(0);
			Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			Game.self.est.sendData(PacketClient.ROUND_HOLLOW, 0);
			return;
		}
		if(e.keyCode == Keyboard.T) {
			if(Hs.isDead) {
				var PacketClient = Type.resolveClass("protocol.PacketClient");
				Game.self.est.sendData(PacketClient.ROUND_RESPAWN);
			} else {
				Hs.dieReason = Hero.DIE_REPORT;
				Hs.dead = true;
			}
			return;
		}
		if(e.keyCode == Keyboard.Q) {
			var gameObjects = Hs.game.map.gameObjects();
			var Point = Type.resolveClass("flash.geom.Point");
			var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
			var point = Hs.game.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
            Hs.sendMove = false;
            Hs.teleportTo(Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]));
            return;
		}
	}
	if(e.keyCode == Keyboard.NUMPAD_ADD) {
		if(!Reflect.hasField(Game.self.est, "hackCastEntityId")) {
            Game.self.est.hackCastEntityId = 0;
        }
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Game.self.est.hackCastEntityId + 1;
        if(e.ctrlKey) {
        	entityId = entityId + 9;
        }
        if(entityId > 306) {
        	entityId = entityId - 307;
        }
        try {
        	Hs.game.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Game.self.est.hackCastEntityId = entityId;
        Game.self.est.sendData(Game.self.est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_SUBTRACT) {
		if(!Reflect.hasField(Game.self.est, "hackCastEntityId")) {
            Game.self.est.hackCastEntityId = 0;
        }
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Game.self.est.hackCastEntityId - 1;
        if(e.ctrlKey) {
        	entityId = entityId - 9;
        }
        if(entityId < 0) {
        	entityId = entityId + 307;
        }
        try {
        	Hs.game.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Game.self.est.hackCastEntityId = entityId;
        Game.self.est.sendData(Game.self.est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_0) {
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Game.self.est.hackCastEntityId;
        try {
        	Hs.game.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Game.self.est.sendData(Game.self.est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_DECIMAL) {
		var PacketClient = Type.resolveClass("protocol.PacketClient");
		var gameObjects = Hs.game.map.gameObjects();
		var Point = Type.resolveClass("flash.geom.Point");
		var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
		var point = Hs.game.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
		var pos = Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]);
		var objId = -1;
		var minDist = -1;
		var i = 0;
		while(i < gameObjects.length) {
			try {
				var dist = gameObjects[i].position.Copy();
				dist.Subtract(pos.Copy());
				var distLen = dist.Length();
				if(distLen < 10) {
					if(minDist == -1 || distLen < minDist) {
						objId = i;
						minDist = distLen;
					}
				}
			} catch(e:Dynamic) {};
			i++;
		}
		if(objId != -1) {
			Game.self.est.sendData(Game.self.est.packetId, "{\"Destroy\":[" + objId + ",true]}");
		}
		return;
	}
});
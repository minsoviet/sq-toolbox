Est.addLoggerHandler(function(message) {
	var isIn = message.indexOf("Received server packet [object PacketRound") != -1;
	var isOut = message.indexOf("Sending packet with type") != -1 && message.indexOf(", ROUND_") != -1;
	if(!isIn && !isOut) {
		return;
	}

	var Gs = Game.self;
	var Est = Gs.est;

	var settings = Est.settings;
	if(settings == null) {
		return;
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

	var squirrelGame = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(settings.infRadius) {
		if(squirrelGame.cast.castRadius != 0) {
			Est.oldCastRadius = squirrelGame.cast.castRadius;
		}
		if(squirrelGame.cast.runCastRadius != 262144) {
			Est.oldRunRadius = squirrelGame.cast.runCastRadius;
		}
		if(squirrelGame.cast.telekinezRadius != 262144) {
			Est.oldTelekinezRadius = squirrelGame.cast.telekinezRadius;
		}
		squirrelGame.cast.castRadius = 0;
		squirrelGame.cast.runCastRadius = 262144;
		squirrelGame.cast.telekinezRadius = 262144;
	}
	if(settings.instantCast) {
		if(Hs.useRunningCast != true) {
			Est.oldRunCast = Hs.useRunningCast;
		}
		if(squirrelGame.cast.castTime != 0) {
			Est.oldCastTime = squirrelGame.cast.castTime;
		}
		Hs.useRunningCast = true;
		squirrelGame.cast.castTime = 0;
	}

	var PerkShamanFactory = Type.resolveClass("game.mainGame.perks.shaman.PerkShamanFactory");
	var ShamanToolBar = Type.resolveClass("game.mainGame.perks.shaman.ui.ShamanToolBar");
	var perkController = Hs.perkController;
	if(settings.allPerksShaman) {
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

	var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
	if(settings.disableKickTimer) {
		ControllerHeroLocal.resetKickTimer();
	}

	return true;
});

var Keyboard = Type.resolveClass("flash.ui.Keyboard");
var KeyboardEvent = Type.resolveClass("flash.events.KeyboardEvent");
Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
	var settings = Game.self.est.settings;
	if(settings == null) {
		return;
	}
	if(!settings.hotkeys) {
		return;
	}
	if(!e.ctrlKey) {
		return;
	}
	var Hs = Hero.self;
	if(Hs != null) {
		if(e.keyCode == Keyboard.NUMBER_2) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			if(Hs.hasNut) {
				Hs.setMode(Hero.NUDE_MOD);
				Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
			} else {
				Hs.setMode(Hero.NUT_MOD);
				Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			}
		}
		if(e.keyCode == Keyboard.NUMBER_3) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			Hs.onHollow(0);
			Game.self.est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			Game.self.est.sendData(PacketClient.ROUND_HOLLOW, 0);
		}
		if(e.keyCode == Keyboard.NUMBER_4) {
			Hs.dieReason = Hero.DIE_REPORT;
			Hs.dead = true;
		}
		if(e.keyCode == Keyboard.NUMBER_5) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			Game.self.est.sendData(PacketClient.ROUND_RESPAWN);
		}
	}
});
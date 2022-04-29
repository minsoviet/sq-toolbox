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
	if(settings.alwaysShaman) {
		Hs.shaman = true;
	}
	if(settings.alwaysDragon) {
		Hs.isDragon = true;
	}
	if(settings.alwaysHare) {
		Hs.isHare = true;
	}
	if(settings.ghostMode) {
		Hs.ghost = true;
	}
	if(settings.infiniteJumps) {
		while(Hs.maxInAirJumps < 1000) {
			Hs.maxInAirJumps++;
		}
	}

	if(settings.disableKickTimer) {
		var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
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
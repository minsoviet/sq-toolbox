Est.addLoggerHandler(function(message) {
	var x = message.indexOf("Received server packet [object PacketRound") != -1;
	var y = message.indexOf("Sending packet with type") != -1 && message.indexOf("ROUND_") != -1;
	if(!x && !y) {
		return;
	}
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	var playerInfo = Est.playerInfo;
	if(settings == null || playerInfo == null) {
		return;
	}
	var Hs = Hero.self;
	if(settings.alwaysimmortal) {
		Hs.immortal = true;
	}
	if(settings.alwaysshaman) {
		Hs.shaman = true;
	}
	if(settings.alwaysdragon) {
		Hs.dragon = true;
	}
	if(settings.alwayshare) {
		Hs.hare = true;
	}
	var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
	if(settings.disablekicktimer) {
		ControllerHeroLocal.resetKickTimer();
	}
	return true;
});
Est.sendData(Est.packetId, "{\"est\":[\"injected\",1]}")
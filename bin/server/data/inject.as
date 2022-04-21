Logger.callBacks.push(function(message) {
	var x = message.indexOf("Received server packet [object PacketRound") != -1;
	var y = message.indexOf("Sending packet with type") != -1 && message.indexOf("ROUND_") != -1;
	if(!x && !y) {
		return;
	}
	var settings = Game.self.est.settings;
	var playerInfo = Game.self.est.playerInfo;
	if(settings == null || playerInfo == null) {
		return;
	}
	if(settings.alwaysimmortal) {
		Hero.self.immortal = true;
	}
	if(settings.alwaysshaman) {
		Hero.self.shaman = true;
	}
	if(settings.alwaysdragon) {
		Hero.self.dragon = true;
	}
	if(settings.alwayshare) {
		Hero.self.hare = true;
	}
	var ControllerHeroLocal = Type.resolveClass("controllers.ControllerHeroLocal");
	if(settings.disablekicktimer) {
		ControllerHeroLocal.resetKickTimer();
	}
});
Game.self.est.sendData(Game.self.est.packetId, "{\"est\":[\"injected\",1]}")
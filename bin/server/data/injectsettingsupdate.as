var oldSettings = Game.self.est.oldSettings;
var settings = Game.self.est.settings;
var playerInfo = Game.self.est.playerInfo;

Game.self.est.oldSettings = settings;

if(oldSettings == null || settings.fakemoderator != oldSettings.fakemoderator) {
	Game.self.moderator = playerInfo.moderator || settings.fakemoderator;
}
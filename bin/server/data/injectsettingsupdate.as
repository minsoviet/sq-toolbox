var oldSettings = G.est.oldSettings;
var settings = G.est.settings;
var playerInfo = G.est.playerInfo;

G.est.oldSettings = settings;

if(oldSettings == null || settings.fakemoderator != oldSettings.fakemoderator) {
	G.moderator = playerInfo.moderator || settings.fakemoderator;
}
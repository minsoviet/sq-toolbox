var settings = Est.settings;
var playerInfo = Est.playerInfo;

var oldSettings = Est.oldSettings;
var isFirstRun = oldSettings == null;
function isChanged(name, ignoreFirstRun, except) {
	if(isFirstRun && (!ignoreFirstRun || except == settings[name])) {
		return false;
	}
	return settings[name] != oldSettings[name];
}

if(isChanged("fakeModerator")) {
	Gs.moderator = playerInfo.moderator || settings.fakeModerator;
}

var Hs = Hero.self;
if(Hs != null) {
	if(isChanged("alwaysImmortal", true, false)) {
		Hs.immortal = settings.alwaysImmortal;
	}
	if(isChanged("alwaysShaman", true, false)) {
		Hs.shaman = settings.alwaysShaman;
	}
	if(isChanged("alwaysDragon", true, false)) {
		Hs.isDragon = settings.alwaysDragon;
	}
	if(isChanged("alwaysHare", true, false)) {
		Hs.isHare = settings.alwaysHare;
	}
	if(isChanged("ghostMode")) {
		Hs.ghost = settings.ghostMode;
	}
	if(isChanged("infiniteJumps")) {
		if(settings.infiniteJumps) {
			while(Hs.maxInAirJumps < 1000) {
				Hs.maxInAirJumps++;
			}
		} else {
			while(Hs.maxInAirJumps > 0) {
				Hs.maxInAirJumps--;
			}
		}
	}
}

Est.oldSettings = settings;
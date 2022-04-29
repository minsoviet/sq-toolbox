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

var Hs = Hero.self;
if(Hs != null) {
	if(isChanged("alwaysImmortal", false)) {
		Hs.immortal = settings.alwaysImmortal;
	}
	if(isChanged("alwaysShaman", false)) {
		Hs.shaman = settings.alwaysShaman;
	}
	if(isChanged("alwaysDragon", false)) {
		Hs.isDragon = settings.alwaysDragon;
	}
	if(isChanged("alwaysHare", false)) {
		Hs.isHare = settings.alwaysHare;
	}
	if(isChanged("ghostMode", null)) {
		Hs.ghost = settings.ghostMode;
	}
	if(isChanged("infiniteJumps", null)) {
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

var squirrelGame = Type.resolveClass("game.mainGame.SquirrelGame").instance;
if(squirrelGame != null) {
	if(isChanged("showAllObjects", null)) {
		var gameObjects = squirrelGame.map.gameObjects();
		var i = 0;
		while(i < gameObjects.length) {
			try {
				gameObjects[i].showDebug = settings.showAllObjects;
			} catch(e:Dynamic) {};
			i++;
		}
	}
}

Est.oldSettings = JSON.parse(JSON.stringify(settings));
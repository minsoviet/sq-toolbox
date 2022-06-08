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
	if(isChanged("ghostMode", null)) {
		Hs.ghost = settings.ghostMode;
	}
	if(isChanged("infJumps", null)) {
		if(settings.infJumps) {
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
	if(isChanged("infRadius", null)) {
		if(settings.infRadius) {
			Est.oldCastRadius = squirrelGame.cast.castRadius;
			squirrelGame.cast.castRadius = 0;
		} else {
			if(Reflect.hasField(Est, "oldCastRadius")) {
				squirrelGame.cast.castRadius = Est.oldCastRadius;
			}
			if(Reflect.hasField(Est, "oldRunRadius")) {
				squirrelGame.cast.runCastRadius = Est.oldRunRadius;
			}
			if(Reflect.hasField(Est, "oldTelekinezRadius")) {
				squirrelGame.cast.telekinezRadius = Est.oldTelekinezRadius;
			}
		}
	}
	if(isChanged("instantCast", null)) {
		if(settings.instantCast) {
			Est.oldCastTime = squirrelGame.cast.castTime;
			squirrelGame.cast.castTime = 0;
		} else {
			if(Reflect.hasField(Est, "oldRunCast")) {
				Hs.useRunningCast = Est.oldRunCast;
			}
			if(Reflect.hasField(Est, "oldCastTime")) {
				squirrelGame.cast.castTime = Est.oldCastTime;
			}
		}
	}
}

Est.oldSettings = JSON.parse(JSON.stringify(settings));
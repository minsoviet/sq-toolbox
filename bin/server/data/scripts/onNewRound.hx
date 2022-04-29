var settings = Est.settings;

var squirrelGame = Type.resolveClass("game.mainGame.SquirrelGame").instance;
if(squirrelGame != null) {
	var gameObjects = squirrelGame.map.gameObjects();
	Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "round.mapObjects", gameObjects.length]}));
	if(settings.showAllObjects) {
		var i = 0;
		while(i < gameObjects.length) {
			try {
				gameObjects[i].showDebug = settings.showAllObjects;
			} catch(e:Dynamic) {};
			i++;
		}
	}
}
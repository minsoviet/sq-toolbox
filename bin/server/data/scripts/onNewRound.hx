function onNewRound() {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	var Hs = Hero.self;
	if(Hs != null) {
		var gameObjects = Hs.game.map.gameObjects();
		Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "round.mapObjects", gameObjects.length]}));
		if(settings.showSensors) {
			var i = 0;
			while(i < gameObjects.length) {
				var className = Type.getClassName(Type.getClass(gameObjects[i]));
				if(className == "game.mainGame.entity.editor.Sensor" || className == "game.mainGame.entity.editor.SensorRect") {
					gameObjects[i].showDebug = true;
				}
				i++;
			}
		}
		if(Reflect.hasField(Est, "lastHighlightObjectId")) {
			Est.lastHighlightObjectId = -1;
		}
		Est.gameObjectsDeleted = [];
	}
}
Est.onNewRound = onNewRound;
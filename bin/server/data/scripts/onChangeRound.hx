function onChangeRound() {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	var Sg = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(Sg != null) {
		var gameObjects = Sg.map.gameObjects();
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
	}
	if(Reflect.hasField(Est, "lastHighlightObjectId")) {
		Est.lastHighlightObjectId = -1;
	}
	Est.gameObjectsDeleted = [];
}
Est.onChangeRound = onChangeRound;
var squirrelGame = Type.resolveClass("game.mainGame.SquirrelGame").instance;
var gameObjects = squirrelGame.map.gameObjects();
Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "round.mapObjects", gameObjects.length]}));
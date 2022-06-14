var Keyboard = Type.resolveClass("flash.ui.Keyboard");
var KeyboardEvent = Type.resolveClass("flash.events.KeyboardEvent");
Game.stage.addEventListener(KeyboardEvent.KEY_UP, function(e) {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	if(settings == null) {
		return;
	}
	if(!settings.hotkeys) {
		return;
	}
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	if(!Reflect.hasField(Est, "lastKeyPress") || Est.lastKeyPress != e.keyCode) {
		return;
	}
	Est.lastKeyPress = null;
});
Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	if(settings == null) {
		return;
	}
	if(!settings.hotkeys) {
		return;
	}
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	if(Reflect.hasField(Est, "lastKeyPress") && Est.lastKeyPress == e.keyCode) {
		return;
	}
	Est.lastKeyPress = e.keyCode;
	var Sg = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(Sg == null) {
		return;
	}
	if(e.ctrlKey) {
		if(e.keyCode == Keyboard.G) {
			var squirrels = Sg.squirrels;
			var squirrelsIds = squirrels.getIds();
			var Point = Type.resolveClass("flash.geom.Point");
			var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
			var point = Sg.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
			var pos = Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]);
			var squirrelId = -1;
			var minDist = -1;
			var i = 0;
			while(i < squirrelsIds.length) {
				try {
					var id = squirrelsIds[i];
					var dist = squirrels.get(id).position.Copy();
					dist.Subtract(pos);
					var distLen = dist.Length();
					if(distLen < 10) {
						if(minDist == -1 || distLen < minDist) {
							squirrelId = id;
							minDist = distLen;
						}
					}
				} catch(e:Dynamic) {};
				i++;
			}
			if(squirrelId != -1) {
				Est.sendData(Est.packetId, JSON.stringify({
					reportedPlayerId: squirrelId,
					targetPlayerId: squirrelId
			    }));
			}
			return;
		}
	}
	if(e.keyCode == Keyboard.NUMPAD_ADD) {
		if(!Reflect.hasField(Est, "hackCastEntityId")) {
            Est.hackCastEntityId = 0;
        }
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Est.hackCastEntityId + 1;
        if(e.ctrlKey) {
        	entityId = entityId + 9;
        }
        if(entityId > 306) {
        	entityId = entityId - 307;
        }
        try {
        	Sg.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Est.hackCastEntityId = entityId;
        Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_SUBTRACT) {
		if(!Reflect.hasField(Est, "hackCastEntityId")) {
            Est.hackCastEntityId = 0;
        }
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Est.hackCastEntityId - 1;
        if(e.ctrlKey) {
        	entityId = entityId - 9;
        }
        if(entityId < 0) {
        	entityId = entityId + 307;
        }
        try {
        	Sg.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Est.hackCastEntityId = entityId;
        Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_0) {
        var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
        var entityId = Est.hackCastEntityId;
        try {
        	Sg.cast.castObject = Type.createInstance(EntityFactory.getEntity(entityId), []);
        } catch(e:Dynamic) {};
        Est.sendData(Est.packetId, JSON.stringify({est: ["updateData", "storage.hackCastEntityId", entityId]}));
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_DECIMAL) {
		var gameObjects = Sg.map.gameObjects();
		var Point = Type.resolveClass("flash.geom.Point");
		var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
		var point = Sg.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
		var pos = Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]);
		var objectId = -1;
		var minDist = -1;
		var i = 0;
		while(i < gameObjects.length) {
			try {
				var dist = gameObjects[i].position.Copy();
				dist.Subtract(pos);
				var distLen = dist.Length();
				if(minDist == -1 || distLen < minDist) {
					objectId = i;
					minDist = distLen;
				}
			} catch(e:Dynamic) {};
			i++;
		}
		if(objectId != -1) {
			var object = gameObjects[objectId];
			if(e.ctrlKey) {
				var EntityFactory = Type.resolveClass("game.mainGame.entity.EntityFactory");
				Est.gameObjectsDeleted.push([true, [EntityFactory.getId(object), object.serialize(), true]]);
				Est.sendData(Est.packetId, "{\"Destroy\":[" + objectId + ",true]}");
			} else {
				var PacketClient = Type.resolveClass("protocol.PacketClient");
				var linearVelocityX = 0;
				var linearVelocityY = 0;
				try {
					linearVelocityX = object.linearVelocity.x;
					linearVelocityY = object.linearVelocity.y;
				} catch(e:Dynamic) {};
				Est.gameObjectsDeleted.push([false, [object.id, object.position.x, object.position.y, object.angle, linearVelocityX, linearVelocityY, object.angularVelocity]]);
				object.position = Type.createInstance(b2Vec2, [-8192 - Math.random() * 8192, -8192 - Math.random() * 8192]);
				Est.sendData(PacketClient.ROUND_SYNC, PacketClient.SYNC_PLAYER, [object.id, object.position.x, object.position.y, object.angle, linearVelocityX, linearVelocityY, object.angularVelocity]);
			}
		}
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_DIVIDE) {
        if(Reflect.hasField(Est, "gameObjectsDeleted") && Est.gameObjectsDeleted.length > 0) {
        	var deleted = Est.gameObjectsDeleted.pop();
        	if(deleted[0]) {
        		Est.sendData(Est.packetId, JSON.stringify({Create: deleted[1]}));
        	} else {
        		var PacketClient = Type.resolveClass("protocol.PacketClient");
        		var gameObjects = Sg.map.gameObjects();
        		var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
        		gameObjects[deleted[1][0]].position = Type.createInstance(b2Vec2, [deleted[1][1], deleted[1][2]]);
        		Est.sendData(PacketClient.ROUND_SYNC, PacketClient.SYNC_PLAYER, deleted[1]);
        	}
        }
        return;
	}
	if(e.keyCode == Keyboard.NUMPAD_MULTIPLY) {
        var gameObjects = Sg.map.gameObjects();
		var Point = Type.resolveClass("flash.geom.Point");
		var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
		var point = Sg.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
		var pos = Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]);
		var objectId = -1;
		var minDist = -1;
		var i = 0;
		while(i < gameObjects.length) {
			try {
				var dist = gameObjects[i].position.Copy();
				dist.Subtract(pos);
				var distLen = dist.Length();
				if(minDist == -1 || distLen < minDist) {
					objectId = i;
					minDist = distLen;
				}
			} catch(e:Dynamic) {};
			i++;
		}
		if(objectId != -1) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			var object = gameObjects[objectId];
			object.position = pos;
			var linearVelocityX = 0;
			var linearVelocityY = 0;
			try {
				linearVelocityX = object.linearVelocity.x;
				linearVelocityY = object.linearVelocity.y;
			} catch(e:Dynamic) {};
			Est.sendData(PacketClient.ROUND_SYNC, PacketClient.SYNC_PLAYER, [object.id, object.position.x, object.position.y, object.angle, linearVelocityX, linearVelocityY, object.angularVelocity]);
		}
		return;
	}
	if(e.keyCode == Keyboard.NUMPAD_1) {
        var castObject = Sg.cast.castObject;
        if(castObject != null) {
        	castObject.fixed = !castObject.fixed;
        	var state = "<span class='color1'>НЕТ</span>";
        	if(castObject.fixed) {
        		state = "<span class='name_moderator'>ДА</span>";
        	}
        	Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>Фиксация:</span> " + state);
        }
        return;
	}
	if(e.keyCode == Keyboard.NUMPAD_2) {
        var castObject = Sg.cast.castObject;
        if(castObject != null) {
        	try {
        		var size = castObject.size;
        		if(e.ctrlKey) {
        			size.y = size.y - 6.4;
        		} else {
        			size.y = size.y + 6.4;
        		}
        		castObject.size = size;
        		Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>Размер:</span> <span class='color6'>[" + castObject.size.x + "; " + castObject.size.y + "]</span>");
        	} catch(e:Dynamic) {
        		Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>У этого объекта нет размера</span>");
        	};
        }
        return;
	}
	if(e.keyCode == Keyboard.NUMPAD_3) {
        var castObject = Sg.cast.castObject;
        if(castObject != null) {
        	try {
        		var size = castObject.size;
        		if(e.ctrlKey) {
        			size.x = size.x - 6.4;
        		} else {
        			size.x = size.x + 6.4;
        		}
        		castObject.size = size;
        		Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>Размер:</span> <span class='color6'>[" + castObject.size.x + "; " + castObject.size.y + "]</span>");
        	} catch(e:Dynamic) {
        		Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>У этого объекта нет размера</span>");
        	};
        }
        return;
	}
	if(e.keyCode == Keyboard.NUMPAD_4) {
        var castObject = Sg.cast.castObject;
        if(castObject != null) {
        	castObject.ghostToObject = !castObject.ghostToObject;
        	var state = "<span class='color1'>НЕТ</span>";
        	if(castObject.ghostToObject) {
        		state = "<span class='name_moderator'>ДА</span>";
        	}
        	Est.addChatMessage("CHAT_ROOM", Gs.id, "<span class='color3'>Призр. к объектам:</span> " + state);
        }
        return;
	}
	var Hs = Hero.self;
	if(Hs == null) {
		return;
	}
	if(e.ctrlKey) {
		if(e.keyCode == Keyboard.E) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			if(Hs.hasNut) {
				Hs.setMode(Hero.NUDE_MOD);
				Est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
			} else {
				Hs.setMode(Hero.NUT_MOD);
				Est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			}
			return;
		}
		if(e.keyCode == Keyboard.R) {
			var PacketClient = Type.resolveClass("protocol.PacketClient");
			Hs.onHollow(0);
			Est.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
			Est.sendData(PacketClient.ROUND_HOLLOW, 0);
			return;
		}
		if(e.keyCode == Keyboard.T) {
			if(Hs.isDead) {
				var PacketClient = Type.resolveClass("protocol.PacketClient");
				Est.sendData(PacketClient.ROUND_RESPAWN);
			} else {
				Hs.dieReason = Hero.DIE_REPORT;
				Hs.dead = true;
			}
			return;
		}
		if(e.keyCode == Keyboard.Q) {
			var gameObjects = Sg.map.gameObjects();
			var Point = Type.resolveClass("flash.geom.Point");
			var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
			var point = Sg.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
            Hs.sendMove = false;
            Hs.teleportTo(Type.createInstance(b2Vec2, [point.x / Game.PIXELS_TO_METRE, point.y / Game.PIXELS_TO_METRE]));
            return;
		}
	}
});
function updateHighlightObjects(dt) {
	var Gs = Game.self;
	var Est = Gs.est;
	var settings = Est.settings;
	if(settings == null) {
		return;
	}
	var Hs = Hero.self;
	if(Hs == null) {
		return;
	}
	if(!settings.highlightObjects) {
		return;
	}
	var gameObjects = Hs.game.map.gameObjects();
	var Point = Type.resolveClass("flash.geom.Point");
	var b2Vec2 = Type.resolveClass("Box2D.Common.Math.b2Vec2");
	var point = Hs.game.squirrels.globalToLocal(Type.createInstance(Point, [Game.stage.mouseX, Game.stage.mouseY]));
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
		if(Reflect.hasField(Est, "lastHighlightObjectId") && Est.lastHighlightObjectId != -1) {
			try {
				var oldObject = gameObjects[Est.lastHighlightObjectId];
				var newFilters = oldObject.filters;
				newFilters.splice(newFilters.indexOf(Est.highlightObjectFilter), 1);
				oldObject.filters = newFilters;
			} catch(e:Dynamic) {};
		}
		var object = gameObjects[objectId];
		var filters = object.filters;
		filters.push(Est.highlightObjectFilter);
		object.filters = filters;
		Est.lastHighlightObjectId = objectId;
	}
}
Est.setInterval(updateHighlightObjects, 100);
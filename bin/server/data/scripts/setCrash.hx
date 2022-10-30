Est.crashMap = function() {
	var Gs = Game.self;
	var Est = Gs.est;
	var Sg = Type.resolveClass("game.mainGame.SquirrelGame").instance;
	if(Sg == null) {
		return;
	}
	var num = Sg.map.gameObjects().length;
	var x1 = -2048 - Math.random() * 2048;
	var y1 = -2048 - Math.random() * 2048;
	var x2 = -1024 - Math.random() * 1024;
	var y2 = -1024 - Math.random() * 1024;
	var speedX1 = -214748367 - Math.random() * 214748367;
	var speedY1 = -214748367 - Math.random() * 214748367;
	var speedX2 = 214748367 + Math.random() * 214748367;
	var speedY2 = 214748367 + Math.random() * 214748367;
	var ropeX = Math.floor((x1 + x2) / 2);
	var ropeY = Math.floor((y1 + y2) / 2);
	var freq = 16384 + Math.random() * 16384;
	var damp = 16384 + Math.random() * 16384;
	Est.sendData(Est.packetId, "{\"Create\":[7,[[["+x1+","+y1+"],0,false,false,false,["+speedX1+","+speedY1+"],0,\"0\",1,false]],true]}");
	Est.sendData(Est.packetId, "{\"Create\":[8,[[["+x2+","+y2+"],0,false,false,false,["+speedX2+","+speedY2+"],0,\"0\",1,false]],true]}");
	Est.sendData(Est.packetId, "{\"Create\":[72,[["+ropeX+","+ropeY+"],["+x1+","+y1+"],["+x2+","+y2+"],["+freq+","+damp+"],["+num+","+(num+1)+",["+x1+","+y1+"],["+x2+","+y2+"]]],true]}");
}
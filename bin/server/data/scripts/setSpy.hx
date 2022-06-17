Est.startSpy = function(playerId) {
	var ScreenGame = Type.resolveClass("screens.ScreenGame");
	ScreenGame.start(playerId, false, true, 0);
}
Est.showSpyDialog = function(text, playerId) {
	var DialogInfo = Type.resolveClass("dialogs.DialogInfo");
	var Screens = Type.resolveClass("screens.Screens");
	var PacketClient = Type.resolveClass("protocol.PacketClient");
	function onSpy() {
		var Gs = Game.self;
		var Est = Gs.est;
		var screen = Type.getClassName(Type.getClass(Screens.active));
		if(screen == "screens.ScreenGame") {
			Est.sendData(PacketClient.LEAVE);
		}
		Est.setTimeout(functin(dt) {
			Est.startSpy(playerId);
		}, 3000);
	}
	var spyDialog = Type.createInstance(DialogInfo, ["sq-toolbox", text, true, onSpy, 250]);
	var okButton = spyDialog.getChildAt(2);
	okButton.x = 20;
	okButton.field.text = "Следовать";
	okButton.centerField();
	okButton.redraw();
	var cancelButton = spyDialog.getChildAt(3);
	cancelButton.x = 150;
	spyDialog.show();
}
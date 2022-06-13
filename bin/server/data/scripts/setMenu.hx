var DialogInfo = Type.resolveClass("dialogs.DialogInfo");
var CheckBox = Type.resolveClass("fl.controls.CheckBox");
var MouseEvent = Type.resolveClass("flash.events.MouseEvent");

var menuDialog = Type.createInstance(DialogInfo, ["sq-toolbox", ""]);
menuDialog.width = 460;
menuDialog.height = 420;
menuDialog.removeChildAt(2);
Est.menu = menuDialog;

var settings = Est.settings;
var settingsData = Est.constants.settingsData;

var offsetX = 0;
var offsetY = 12;
var colWidth = 150;

var i = 0;
while(i < settingsData.length) {
	var key = settingsData[i][0];
	var name = settingsData[i][1];
	var value = settings[key];
	if(Type.typeof(value) == "TBool") {
		var checkBox = Type.createInstance(CheckBox, []);
		checkBox.x = offsetX;
		checkBox.y = offsetY;
		checkBox.height = 6;
		checkBox.width = colWidth;
		checkBox.label = name;
		checkBox.selected = value;
		checkBox.addEventListener(MouseEvent.CLICK, function(e) {
			var Gs = Game.self;
			var Est = Gs.est;
			Est.settings[key] = checkBox.selected;
			Est.sendData(Est.packetId, JSON.stringify({est: ["updateSetting", key, checkBox.selected]}));
			Est.onSettingsUpdate();
		});
		menuDialog.addChild(checkBox);
		offsetY = offsetY + 20;
		if (offsetY > menuDialog.height - 55) {
			offsetY = 12;
			offsetX = offsetX + colWidth;
		}
	}
	i++;
}

var Keyboard = Type.resolveClass("flash.ui.Keyboard");
var KeyboardEvent = Type.resolveClass("flash.events.KeyboardEvent");
Game.stage.addEventListener(KeyboardEvent.KEY_UP, function(e) {
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	var Gs = Game.self;
	var Est = Gs.est;
	if(!Reflect.hasField(Est, "lastKeyPressMenu") || Est.lastKeyPressMenu != e.keyCode) {
		return;
	}
	Est.lastKeyPressMenu = null;
});
Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e) {
	if(Game.chat != null && Game.chat.visible) {
		return;
	}
	var Gs = Game.self;
	var Est = Gs.est;
	if(Reflect.hasField(Est, "lastKeyPressMenu") && Est.lastKeyPressMenu == e.keyCode) {
		return;
	}
	Est.lastKeyPressMenu = e.keyCode;
	if(!e.ctrlKey || e.keyCode != Keyboard.M) {
		return;
	}
	var menuDialog = Est.menu;
	if(menuDialog.visible) {
		menuDialog.hide();
	} else {
		menuDialog.show();
	}
});
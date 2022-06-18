var Gs = Game.self;
Gs.est = {
    vars: {},
    loggerHandlers: [],
    externalHandlers: {},
    settings: null,
    oldSettings: null,
    playerInfo: null,
    constants: null,
    packetId: Type.resolveClass("protocol.PacketClient").ROUND_COMMAND,
    highlightObjectFilter: Type.createInstance(Type.resolveClass("flash.filters.GlowFilter"), [16711680, 1, 12, 12, 5, 1, true]),
    executeHaXeScript: Type.resolveClass("hscript.HScript").ExecuteHaXeScript,
    call: Type.resolveClass("flash.external.ExternalInterface").call,
    addCallback: Type.resolveClass("flash.external.ExternalInterface").addCallback,
    getTimer: Type.resolveClass("flash.Lib").getTimer,
    sendData: Type.resolveClass("protocol.Connection").sendData,
    addLoggerHandler: function(func) { return Game.self.est.loggerHandlers.push(func); },
    addExternalHandler: function(prefix, func) { if(!Reflect.hasField(Game.self.est.externalHandlers, prefix)) { Game.self.est.externalHandlers[prefix] = []; } return Game.self.est.externalHandlers[prefix].push(func); },
    setTimeout: function(func, delay) { var Timer = Type.resolveClass("flash.utils.Timer"); var TimerEvent = Type.resolveClass("flash.events.TimerEvent"); var timer = Type.createInstance(Timer, [delay, 1]); timer.addEventListener(TimerEvent.TIMER, func); timer.reset(); timer.start(); },
    setInterval: function(func, delay) { var Timer = Type.resolveClass("flash.utils.Timer"); var TimerEvent = Type.resolveClass("flash.events.TimerEvent"); var timer = Type.createInstance(Timer, [delay, 0]); timer.addEventListener(TimerEvent.TIMER, func); timer.reset(); timer.start(); },
    showMessage: function(caption, text) { var DialogInfo = Type.resolveClass("dialogs.DialogInfo"); Type.createInstance(DialogInfo, [caption, text]).show(); },
    addChatMessage: function(chatType, playerId, message) { var Connection = Type.resolveClass("protocol.Connection"); var PacketClient = Type.resolveClass("protocol.PacketClient"); var PacketChatMessage = Type.resolveClass("protocol.packages.server.PacketChatMessage"); Connection.receiveFake(PacketChatMessage.PACKET_ID, [PacketClient[chatType], playerId, message]); }
};
var Est = Gs.est;
Est.addCallback("__est_sendData", function(prefix, data) {
    if(!Reflect.hasField(Game.self.est.externalHandlers, prefix)) {
        return;
    }
    var Gs = Game.self;
    var Est = Gs.est;
    var i = 0;
    var r = null;
    while(i < Est.externalHandlers[prefix].length) {
        r = Est.externalHandlers[prefix][i](prefix, data);
        i++;
    }
    return r;
});
Est.vars.Est = Est;
Logger.callBacks.push(function(message) {
    var Gs = Game.self;
    var Est = Gs.est;
    if(message.indexOf("\"dataJson\":{\"est\"") == -1) {
        var i = 0;
        while(i < Game.self.est.loggerHandlers.length) {
            if(Est.loggerHandlers[i](message)) {
                return;
            }
            i++;
        }
        return;
    }
    var data = JSON.parse(message.substr(message.indexOf("]") + 2));
    if(!Reflect.hasField(data, "dataJson") || data.playerId != Game.self.id) {
        return;
    }
    var dataEst = data.dataJson["est"];
    if(dataEst[0] == "runScript") {
        if(dataEst[1]) {
            try {
                Est.executeHaXeScript(dataEst[2], Est.vars);
            } catch(e:Dynamic) {
                Est.showMessage("sq-toolbox", e);
            };
        }
        return;
    }
    if(dataEst[0] == "runExternalScript") {
        try {
            Est.call("eval", dataEst[1]);
        } catch(e:Dynamic) {
            if (e == "SecurityError: Error #2060") {
                Est.showMessage("sq-toolbox", "Не удалось запустить скрипт.");
            } else {
                Est.showMessage("sq-toolbox", e);
            }
        };
        return;
    }
    if(dataEst[0] == "showMessage") {
        Est.showMessage("sq-toolbox", dataEst[1]);
        return;
    }
    if(dataEst[0] == "setSettings") {
        Est.settings = dataEst[1];
        return;
    }
    if(dataEst[0] == "setPlayerInfo") {
        Est.playerInfo = dataEst[1];
        return;
    }
    if(dataEst[0] == "setConstants") {
        Est.constants = dataEst[1];
    }
});
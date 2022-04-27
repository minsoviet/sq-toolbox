var Gs = Game.self;
if(!Reflect.hasField(Gs, "est")) {
    Gs.est = {
        vars: {
            Gs: Gs,
            showMessage: showMessage,
            vector: vector,
            P2M: P2M,
            PI: PI,
            R2D: R2D,
            D2R: D2R,
            b2Vec2: b2Vec2
        },
        loggerHandlers: [],
        externalHandlers: {},
        settings: null,
        playerInfo: null,
        innerData: {},
        packetId: Type.resolveClass("protocol.PacketClient").ROUND_COMMAND,
        executeHaXeScript: Type.resolveClass("hscript.HScript").ExecuteHaXeScript,
        call: Type.resolveClass("flash.external.ExternalInterface").call,
        addCallback: Type.resolveClass("flash.external.ExternalInterface").addCallback,
        sendData: Type.resolveClass("protocol.Connection").sendData,
        addLoggerHandler: function(func) { return Game.self.est.loggerHandlers.push(func); },
        addExternalHandler: function(prefix, func) { if(!Reflect.hasField(Game.self.est.externalHandlers, prefix)) { Game.self.est.externalHandlers[prefix] = []; } return Game.self.est.externalHandlers[prefix].push(func); }
    };
    Gs.est.addCallback("__est_sendData", function(prefix, data) {
        if(!Reflect.hasField(Game.self.est.externalHandlers, prefix)) {
            return;
        }
        var i = 0;
        var r;
        while(i < Game.self.est.externalHandlers[prefix].length) {
            r = Game.self.est.externalHandlers[prefix][i](prefix, data);
            i++;
        }
        return r;
    });
    Gs.est.vars.Est = Gs.est;
    Logger.callBacks.push(function(message) {
        if(message.indexOf("\"dataJson\":{\"est\"") == -1) {
            var i = 0;
            while(i < Game.self.est.loggerHandlers.length) {
                if(Game.self.est.loggerHandlers[i](message)) {
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
                    Game.self.est.executeHaXeScript(dataEst[2], Game.self.est.vars);
                } catch(e:Dynamic) {
                    Game.self.est.vars.showMessage("sq-toolbox", e);
                };
            }
            return;
        }
        if(dataEst[0] == "runExternalScript") {
            try {
                Game.self.est.call("eval", dataEst[1]);
            } catch(e:Dynamic) {
                if (e == "SecurityError: Error #2060") {
                    Game.self.est.vars.showMessage("sq-toolbox", "Не удалось запустить скрипт.");
                } else {
                    Game.self.est.vars.showMessage("sq-toolbox", e);
                }
            };
            return;
        }
        if(dataEst[0] == "showMessage") {
            Game.self.est.vars.showMessage("sq-toolbox", dataEst[1]);
            return;
        }
        if(dataEst[0] == "setSettings") {
            Game.self.est.settings = dataEst[1];
            return;
        }
        if(dataEst[0] == "setPlayerInfo") {
            Game.self.est.playerInfo = dataEst[1];
            return;
        }
        if(dataEst[0] == "setInnerData") {
            Game.self.est.innerData[dataEst[1]] = dataEst[2];
        }
    });
    Gs.est.sendData(Gs.est.packetId, "{\"est\":[\"injected\",0]}");
}
self.dispose()
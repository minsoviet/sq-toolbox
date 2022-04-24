var Gs = Game.self;
if(!Reflect.hasField(Gs, "est")) {
    Gs.est = {
        vars: {
            Gs: Gs,
            addObject: addObject,
            addObjectVec: addObjectVec,
            getPosition: getPosition,
            setPosition: setPosition,
            setPositionVec: setPositionVec,
            getObject: getObject,
            getObjectId: getObjectId,
            getObjectTypeName: getObjectTypeName,
            getAngle: getAngle,
            setAngle: setAngle,
            showMessage: showMessage,
            allowPerk: allowPerk,
            build: build,
            vector: vector,
            createSquirrel: createSquirrel,
            createShaman: createShaman,
            getSquirrel: getSquirrel,
            killSquirrel: killSquirrel,
            addHintArrow: addHintArrow,
            removeHintArrow: removeHintArrow,
            dispatch: dispatch,
            P2M: P2M,
            PI: PI,
            R2D: R2D,
            D2R: D2R,
            b2Vec2: b2Vec2,
            self: self,
            Analytics: Analytics
        },
        oldSettings: null,
        settings: null,
        playerInfo: null,
        packetId: Type.resolveClass("protocol.PacketClient").ROUND_COMMAND,
        executeHaXeScript: Type.resolveClass("hscript.HScript").ExecuteHaXeScript,
        call: Type.resolveClass("flash.external.ExternalInterface").call,
        addCallback: Type.resolveClass("flash.external.ExternalInterface").addCallback,
        sendData: Type.resolveClass("protocol.Connection").sendData
    };
    Gs.est.vars.Est = Gs.est;
    Logger.callBacks.push(function(message) {
        if(message.indexOf("\"dataJson\":{\"est\"") == -1) {
            return;
        }
        var data = JSON.parse(message.substr(message.indexOf("]") + 2));
        if(!Reflect.hasField(data, "dataJson") || data.playerId != Game.self.id)
            return;
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
                Game.self.est.call(dataEst[1]);
            } catch(e:Dynamic) {
                Game.self.est.vars.showMessage("sq-toolbox", e);
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
        }
    });
    Gs.est.sendData(Gs.est.packetId, "{\"est\":[\"injected\",0]}");
}
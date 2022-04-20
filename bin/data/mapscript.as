if(!Reflect.hasField(Game.self, 'est_vars')) {
    Game.self['est_vars'] = {
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
    };

    EnterFrameManager.addPerSecondTimer(function() {
        var messages = Logger.messages;
        var curr = 0;
        var self;
        var script;
        var data;
        while(curr < messages.length) {
            script = messages[curr].indexOf('"dataJson":{"est_runscript"');
            if(script != -1) {
                data = JSON.parse(messages[curr].substr(messages[curr].indexOf(']') + 2));
                if(Reflect.hasField(data, 'dataJson') && data.playerId == Game.selfId) {
                    if(data.dataJson['est_runscript'][0]) {
                        Type.resolveClass("hscript.HScript").ExecuteHaXeScript(data.dataJson['est_runscript'][1], Game.self['est_vars']);
                    }
                    messages[curr] = "";
                }
            }
            curr = curr + 1;
        }
    });
}
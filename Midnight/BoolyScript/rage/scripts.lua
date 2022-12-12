local scripts = {}
scripts.globals = {}

--KOSATKA
scripts.globals['kosatkaMain'] = 262145

scripts.globals['setKosatkaMissileCooldown'] = function(value)
    script_global:new(scripts.globals['kosatkaMain']):at(30175):set_float(value)
end
scripts.globals['setKosatkaMissileRange'] = function (value)
    script_global:new(scripts.globals['kosatkaMain']):at(30176):set_float(value)
end

--PLAYERS
scripts.globals['getPlayerOtr'] = function(pid)
    return script_global:new(2689235):at(pid, 453):at(208):get_long()
end

scripts.globals['skipCutscene'] = function()
    script_global:new(2789756):at(3):set_int64(1)
    script_global:new(1575058):set_int64(1)
end

scripts.globals['removeTransactionError'] = function()
    script_global:new(4535606):set_long(0)
end

scripts.events = {}

scripts.events['kick'] = function(pid)
    script.send(pid, 111242367, pid, -210634234)
end

scripts.events['crash'] = function(pid)
    script.send(pid, -555356783, 2000000, 2000000, 2000000, 2000000)
end

return scripts

local scripts = {}
scripts.globals = {}

--KOSATKA
scripts.globals['kosatkaMain'] = 262145
scripts.globals['kosatkaMissileCooldown'] = scripts.globals['kosatkaMain'] + 30175
scripts.globals['kosatkaMissileRange'] = scripts.globals['kosatkaMain'] + 30176

--PLAYERS
scripts.globals['getPlayerOtr'] = function(pid)
    return script_global:new(2689235):at(pid, 453):at(208):get_long()
end

scripts.globals['skipCutscene'] = function()
    script_global:new(2789756):at(3):set_int64(1)
    script_global:new(1575058):set_int64(1)
end

scripts.events = {}

scripts.events['kick'] = function(pid)
    script.send(pid, 111242367, pid, -210634234)
end

scripts.events['crash'] = function(pid)
    script.send(pid, -555356783, 2000000, 2000000, 2000000, 2000000)
end

return scripts

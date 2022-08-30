local startTime = os.clock()
local BSVersion = "[Midnight] [0.1]"

console.log(10, "[INIT]" .. "             ******         **            **          **     **    **        \n")
console.log(10, "[INIT]" .. "            **   **     **     **     **     **      **       **  **         \n")
console.log(10, "[INIT]" .. "           **    **    **      **    **      **     **         ****          \n")
console.log(10, "[INIT]" .. "          ******      **       **   **       **    **           **           \n")
console.log(10, "[INIT]" .. "         **    **     **      **    **      **    **           **            \n")
console.log(10, "[INIT]" .. "        **    **      **    **      **    **     ********     **             \n")
console.log(10, "[INIT]" .. "       ******           **            **        ********     **              \n")

console.log(10, string.format("[INIT] BoolyScript %s is loading...\n", BSVersion))

local function doesFileExist(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
	   if code == 13 then
		  return true
	   end
	end
	return ok, err
end

local function doesFolderExist(path)
	return doesFileExist(path.."/")
end

console.log(10, "[INIT] Loading lib...\n")

local features = require '\\BoolyScript\\Lib\\features'
local callbacks = require '\\BoolyScript\\Lib\\callbacks'
local json = require '\\BoolyScript\\Lib\\JSON'
local scripts = require '\\BoolyScript\\Lib\\scripts'

local timers = {}
local options = {}
options.bool = {}
options.click = {}
options.sliderInt = {}
options.sliderFloat = {}
options.combo = {}
options.configIgnore = {}
local stuff = {}
local subs = {}
local parsedFiles = {}

local paths = {}
paths.dumps = {}
paths.folders = {}
paths.logs = {}
paths.configs = {}

paths.folders.main = fs.get_dir_script() .. '\\BoolyScript'
paths.folders.lib = paths.folders.main .. '\\Lib'
paths.folders.userData = paths.folders.main .. '\\User'
paths.folders.wepLoadouts = paths.folders.userData .. '\\Weapon Loadouts'
paths.folders.spammerPresets = paths.folders.userData.. '\\Spammer Presets'
paths.folders.savedVehicles = paths.folders.userData .. '\\Saved Vehicles'
paths.folders.logs = paths.folders.main .. '\\Logs'
paths.folders.translations = paths.folders.main .. '\\Translations'

paths.logs.chat = paths.folders.logs .. '\\' .. 'Chat.log'
paths.logs.weapons = paths.folders.logs .. '\\' .. 'Weapons.log'
paths.logs.warnScreens = paths.folders.logs .. '\\' .. 'Warning Screens.log'
paths.logs.netEvents = paths.folders.logs .. '\\' .. 'Network Events.log'
paths.logs.scriptEvents = paths.folders.logs .. '\\' .. 'Script Events.log'

paths.dumps.objects = paths.folders.lib .. '\\' .. 'ObjectList.ini'
paths.dumps.peds = paths.folders.lib .. '\\' .. 'peds.json'
paths.dumps.vehicles = paths.folders.lib .. '\\' .. 'vehicles.json'
paths.dumps.weapons = paths.folders.lib .. '\\' .. 'weapons.json'

paths.configs.mainConfig = paths.folders.userData .. '\\' .. 'config.json'
paths.configs.defaults = paths.folders.userData .. '\\' .. 'default.json'
paths.configs.genTranslation = paths.folders.translations .. '\\' .. 'Generated Translation.json'
paths.configs.savedPeds = paths.folders.userData .. '\\' .. 'savedPeds.json'
paths.configs.savedObjects = paths.folders.userData .. '\\' .. 'savedObjects.json'

console.log(10, "[INIT] Parsing json data...\n")

-- do
--     local file = io.open(paths.dumps.peds, 'r')
--     parsedFiles.peds = json:decode(file:read('*all'))
--     file:close()
-- end

parsedFiles.weaponsSimp = {}
do
    local file = io.open(paths.dumps.weapons, 'r')
    for _, wepInfo in ipairs(json:decode(file:read('*all'))) do
        if wepInfo['TranslatedLabel'] and wepInfo['TranslatedLabel']['Name'] then
            parsedFiles.weaponsSimp[tostring(wepInfo['TranslatedLabel']['Name'])] = wepInfo['Hash']
        end    
    end
end

local keys = {
    W = 87,
    A = 65,
    S = 83,
    D = 68,
    SHIFT = 16,
    CTRL = 17,
    SPACE = 32,
    E = 69,
    X = 88,
    L = 76,
    ArrowLeft = 37,
    ArrowRight = 39
}

console.log(10, "[INIT] Rendering menu...\n")

local toRemove = os.clock()

subs.main = {}
subs.main.page = menu.add_page("BoolyScript " .. tostring(toRemove), 17)
subs.main.localBlock = menu.add_mono_block(subs.main.page, "Local", 0)

menu.add_static_text(subs.main.localBlock, "Movement")

options.bool['clumsiness'] = menu.add_checkbox(subs.main.localBlock, "Clumsiness")
options.sliderFloat['runSpeedMult'] = menu.add_slider_float(subs.main.localBlock, "Runnig speed", 1.0, 1.49)
options.sliderFloat['swimSpeedMult'] = menu.add_slider_float(subs.main.localBlock, "Swimming speed", 1.0, 1.49)

-- options.click['nadristat'] = menu.add_button(subs.main.localBlock, "Make a poop (Nadristat)", function()
--     thread.create(function()
--         local ped = PLAYER.PLAYER_PED_ID()
--         local shit = string.joaat("prop_big_shit_02")
--         local coords = features.getEntityCoords(ped)
--         coords.z = coords.z - 1
--         callbacks.requestAnimDict("missfbi3ig_0", function()
--             TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
--             TASK.TASK_PLAY_ANIM(ped, "missfbi3ig_0", "shit_loop_trev", 8.0, 8.0, 3000, 0, 0.0, true, true, true)
--             -- wait(1000)
--             -- callbacks.requestModel(shit, function()
--             --     entity.spawn_obj(shit, coords)
--             -- end)
--         end)
--     end)
-- end)

stuff.pedFlags = {
    ["Swimming mode"] = 65,
	["Shrink mode"] = 223,
	["Always have parachute"] = 362,
}


stuff.activePedFlags = {}

for flagName, flagID in pairs(stuff.pedFlags) do
    options.bool[flagName] = menu.add_checkbox(subs.main.localBlock, flagName, function(data, state)
        stuff.activePedFlags[flagName] = state
    end)
end

menu.add_static_text(subs.main.localBlock, "Audio flags")

stuff.audioFlags = {
    ["DisableFlightMusic"] = false,
    ["MobileRadioInGame"] = false,
    ["WantedMusicDisabled"] = false,
}

for flagName, _ in pairs(stuff.audioFlags) do
    options.bool[flagName] = menu.add_checkbox(subs.main.localBlock, flagName, function(data, state)
        stuff.audioFlags[flagName] = state
    end)
end

menu.add_static_text(subs.main.localBlock, "Weapon")

options.bool['deadEyeEnabled'] = menu.add_checkbox(subs.main.localBlock, "Dead eye effect")
options.bool['becomeGangsta'] = menu.add_checkbox(subs.main.localBlock, "Become gangsta", function(data, state)
    if state then 
        utils.notify("Note", "Use default pistol. Displays only for you", 2, 2)
    else
		WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(PLAYER.PLAYER_PED_ID(), utils.joaat("Default"))
    end  
end)

options.bool['debugGun'] = menu.add_checkbox(subs.main.localBlock, "Debug gun [E]")

menu.add_static_text(subs.main.localBlock, "Visual")

options.sliderInt['fakeWantedLvl'] = menu.add_slider_int(subs.main.localBlock, "Fake wanted lvl", 0, 6, function(data, num)
	MISC.SET_FAKE_WANTED_LEVEL(num)
end)

options.bool['hideHUD'] = menu.add_checkbox(subs.main.localBlock, "Hide HUD", function(data, state)
	HUD.DISPLAY_RADAR(not state)
end)

options.bool['disableDistantVehicles'] = menu.add_checkbox(subs.main.localBlock, "Disable fake vehicles", function(data, state)
    VEHICLE.SET_DISTANT_CARS_ENABLED(not state)
end)

options.bool['allowPauseInOnline'] = menu.add_checkbox(subs.main.localBlock, "Allow pausing in online")
options.bool['allowPauseWhenDead'] = menu.add_checkbox(subs.main.localBlock, "Allow pause when dead")
options.bool['silentBST'] = menu.add_checkbox(subs.main.localBlock, "Silent BST")

menu.add_static_text(subs.main.localBlock, "World")

stuff.pedsPtr = nil

-- options.bool['cleanupPeds'] = menu.add_checkbox(subs.main.localBlock, "Peds cleanup")
-- options.bool['cleanupVehs'] = menu.add_checkbox(subs.main.localBlock, "Vehicles cleanup")
-- options.sliderInt['cleanupRadius'] = menu.add_slider_int(subs.main.localBlock, "Cleanup radius", 50, 300)

options.bool['blackOutSimple'] = menu.add_checkbox(subs.main.localBlock, "Blackout mode", function(data, state)
    GRAPHICS._SET_ARTIFICIAL_LIGHTS_STATE_AFFECTS_VEHICLES(false)
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(state)
end)

options.bool['blackOutVehicles'] = menu.add_checkbox(subs.main.localBlock, "Blackout mode (Affects vehicles)", function(data, state)
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(state)
    GRAPHICS._SET_ARTIFICIAL_LIGHTS_STATE_AFFECTS_VEHICLES(state)
end)

options.click['artStrike'] = menu.add_button(subs.main.localBlock, "Artillery strike at waypoint", function()
    thread.create(function()
        local coords = features.getWaypointCoords()
        for i = 1, 20 do
            local a = math.random(-10, 10)
            local b = math.random(-10, 10)
            FIRE.ADD_EXPLOSION(coords.x+a, coords.y-b, coords.z, 34, 300.0, true, false, 1.0, false)
            wait(500)
        end
    end)
end)

-- subs.spawner.page = menu.add_page("Spawner", 17)

-- stuff.pedList = {}

-- do
--     for _, pedIno in ipairs(parsedFiles.peds) do
        
--     end
-- end

-- options['pedsSpawnerCombo'] = menu.add_combo(subs.spawner.page, "Peds")

subs.main.settingsBlock = menu.add_mono_block(subs.main.page, "Settings", 0)

local function saveConfig()
    thread.create(function()        
        local configTable = {
            bool = {},
            combo = {},
            sliderInt = {},
            sliderFloat = {},
        }
        for name, optionID in pairs(options.bool) do
            configTable.bool[name] = optionID:get()
        end
        for name, optionID in pairs(options.combo) do
            configTable.combo[name] = optionID:get()
        end
        for name, optionID in pairs(options.sliderInt) do
            configTable.sliderInt[name] = optionID:get()
        end
        for name, optionID in pairs(options.sliderFloat) do
            configTable.sliderFloat[name] = optionID:get()
        end
        do
            local file = io.open(paths.configs.mainConfig, "w+")
            file:write(json:encode_pretty(configTable))
            file:close()
        end
        utils.notify("BoolyScript", "Config has been saved", 16, 1)
    end)
end

local function loadConfig()
    thread.create(function()        
        if doesFileExist(paths.configs.mainConfig) then
            local file = io.open(paths.configs.mainConfig, 'r')    
            local configTable = json:decode(file:read("*all"))
            file:close()
            for name, value in pairs(configTable.bool) do
                if options.bool[name] then
                    options.bool[name]:set(value)
                end
            end
            for name, value in pairs(configTable.combo) do
                if options.combo[name] then
                    options.combo[name]:set(value-1)
                end
            end
            for name, value in pairs(configTable.sliderInt) do
                if options.sliderInt[name] then
                    options.sliderInt[name]:set(value)
                end
            end
            for name, value in pairs(configTable.sliderFloat) do
                if options.sliderFloat[name] then
                    options.sliderFloat[name]:set(value)
                end
            end
            utils.notify("BoolyScript", "Config has been loaded", 16, 1)
        end
    end)
end

local function getDefaults()
    if doesFileExist(paths.configs.defaults) then        
        local file = io.open(paths.configs.defaults, 'r')
        local defaults = json:decode(file:read("*all"))
        file:close()
        return defaults
    end
end

local function addRemoveDefault(name, value, state)
    local defaults = {}
    if doesFileExist(paths.configs.defaults) then        
        defaults = getDefaults()
    end
    if state then
        defaults[name] = value
    else
        if defaults[name] then
            defaults[name] = nil
        end
    end
    local file = io.open(paths.configs.defaults, "w+")
    file:write(json:encode_pretty(defaults))
    file:close()
end

options.click['saveConfig'] = menu.add_button(subs.main.settingsBlock, "Save config", function()
    saveConfig()
end)

options.click['loadConfig'] = menu.add_button(subs.main.settingsBlock, "Load config", function()
    loadConfig()
end)

options.configIgnore['autoLoadConfig'] = menu.add_checkbox(subs.main.settingsBlock, "Auto load config", function(data, state)
    addRemoveDefault("config", true, state)
end)

subs.main.vehicleBlock = menu.add_mono_block(subs.main.page, "Vehicle", 1)

-- options.click['tpInANearestVeh'] = menu.add_button(subs.main.vehicleBlock, "TP in a nearest vehicle", function()
--     thread.create(function()
--         local vehicle = 0
--         local minDistance = 1337228
--         local localCoords = features.getEntityCoords(PLAYER.PLAYER_PED_ID())
--         for _, handle in ipairs(pools.get_all_vehicles()) do
--             local vehicleCoords = features.getEntityCoords(handle)
--             local localCoords = features.getEntityCoords(PLAYER.PLAYER_PED_ID())
--             local dist = features.getDistance(vehicleCoords, localCoords, false)
--             if dist < minDistance then
--                 minDistance = dist
--                 vehicle = handle     
--             end
--         end
--         local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
--         if not PED.IS_PED_A_PLAYER(driver) then
--             TASK.CLEAR_PED_TASKS_IMMEDIATELY(driver)
--             PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, -1)
--         else
            
--         end

--         return
--         -- local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
--         -- if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then
--         --     return
--         -- else
--         --     if not PED.IS_PED_A_PLAYER(driver) then
--         --         entity.delete(driver)
--         --         PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, -1)
--         --     elseif VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
--         --         for i=-1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(vehicle)) do
--         --             if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, false) then
--         --                 PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, i)
--         --                 return
--         --             end
--         --         end
--         --     end
--         -- end 
--     end)
-- end)

options.configIgnore['switchSeat'] = menu.add_slider_int(subs.main.vehicleBlock, "Switch seat", -1, 3, function(data, num)
    local vehicle = features.getLocalVehicle(false)
    if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, -1, false) then return end
	PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, num)
end)

menu.add_static_text(subs.main.vehicleBlock, "Movement")

options.bool['engineAlwaysOn'] = menu.add_checkbox(subs.main.vehicleBlock, "Engine always on")
options.bool['crewNitro'] = menu.add_checkbox(subs.main.vehicleBlock, "The Crew 2 nitro")
options.sliderFloat['crewNitroPower'] = menu.add_slider_float(subs.main.vehicleBlock, "Nitro power", 1.0, 30.0)
options.bool['cruiseControl'] = menu.add_checkbox(subs.main.vehicleBlock, "Cruise control [L]")
options.bool['disableTurbulence'] = menu.add_checkbox(subs.main.vehicleBlock, "Disable turbulence")
options.bool['disableGravity'] = menu.add_checkbox(subs.main.vehicleBlock, "Disable gravity")
-- options.bool['disableCollision'] = menu.add_checkbox(subs.main.vehicleBlock, "Disable collision for aircraft")
options.bool['superDrive'] = menu.add_checkbox(subs.main.vehicleBlock, "Super drive [W]")
options.sliderFloat['superDrivePower'] = menu.add_slider_float(subs.main.vehicleBlock, "Power", 1.0, 30.0)

menu.add_static_text(subs.main.vehicleBlock, "Appearence")

options.bool['useCounters'] = menu.add_checkbox(subs.main.vehicleBlock, "Use countermeasures")
options.bool['useVehicleSignals'] = menu.add_checkbox(subs.main.vehicleBlock, "Vehicle signals", function(data, state)
    if state then utils.notify("Note", "Arrow Left/Right for left and right signals\nUse E to enable flash high beam.\n", 25, 0) end
end)

options.bool['disableDeformation'] = menu.add_checkbox(subs.main.vehicleBlock, "Disable deformation")

stuff.doors = {
    "Front left",
    "Front right", 
    "Back left",
    "Back right",
    "Hood",
    "Trunk",
    "Back",
    "Back 2"
}

stuff.selectedDoor = 1

options.combo['doorsCombo'] = menu.add_combo(subs.main.vehicleBlock, "Doors", stuff.doors, function(data, pos)
    stuff.selectedDoor = pos
end)
options.click['openDoor'] = menu.add_button(subs.main.vehicleBlock, "Open door", function()
    VEHICLE.SET_VEHICLE_DOOR_OPEN(features.getLocalVehicle(true), stuff.selectedDoor-1, false, true)
end)
options.click['closeDoor'] = menu.add_button(subs.main.vehicleBlock, "Close door", function()
    VEHICLE.SET_VEHICLE_DOOR_SHUT(features.getLocalVehicle(true), stuff.selectedDoor-1, false, true)
end)

menu.add_static_text(subs.main.vehicleBlock, "Remote actions")

stuff.engineState = false
options.click['toggleEngine'] = menu.add_button(subs.main.vehicleBlock, "Toggle engine", function()
    local vehicle = features.getLocalVehicle(true)
    if not features.doesEntityExist(vehicle) then return end
    entity.request_control(vehicle, function(handle)
        VEHICLE.SET_VEHICLE_ENGINE_ON(handle, not stuff.engineState, true, true)
        VEHICLE.SET_VEHICLE_LIGHTS(handle, 0)
        VEHICLE._SET_VEHICLE_LIGHTS_MODE(handle, 0)
    end)
end)

options.click['vehicleAlarm'] = menu.add_button(subs.main.vehicleBlock, "Enable alarm (30 sec)", function()
    local vehicle = features.getLocalVehicle(true)
	if features.doesEntityExist(vehicle) then
		entity.request_control(vehicle, function(handle)	
			VEHICLE.SET_VEHICLE_ALARM(handle, true)
			VEHICLE.START_VEHICLE_ALARM(handle)
		end)
	end
end)

options.bool['invertControls'] = menu.add_checkbox(subs.main.vehicleBlock, "Invert controls", function(data, state)
    local vehicle = features.getLocalVehicle(true)
	if features.doesEntityExist(vehicle) then
        entity.request_control(vehicle, function(handle)
            VEHICLE._SET_VEHICLE_CONTROLS_INVERTED(handle, state)
        end)
    end
end)

stuff.vehicleSpinHead = 0.0

options.bool['vehicleSpin'] = menu.add_checkbox(subs.main.vehicleBlock, "Spin", function(data, state)
    if state then stuff.vehicleSpinHead = ENTITY.GET_ENTITY_HEADING(features.getLocalVehicle(true)) end
end)

stuff.driveToMePed = 0


-- options.bool['driveToMe'] = menu.add_checkbox(subs.main.vehicleBlock, "Drive to me", function(data, state)
--     local vehicle = features.getLocalVehicle(true)
-- 	if not features.doesEntityExist(vehicle) then options.bool['driveToMe']:set_bool(false) return end
-- 	local coords = features.getEntityCoords(vehicle)
-- 	local dest = features.getEntityCoords(PLAYER.PLAYER_PED_ID())
-- 	local ped = stuff.driveToMePed
-- 	if state then
    -- 		callbacks.requestModel(string.joaat("HC_Driver"), function()
        -- 			entity.spawn_ped(string.joaat("HC_Driver"), coords, function(handle)
            --                 stuff.driveToMePed = handle
            --                 ENTITY.SET_ENTITY_INVINCIBLE(handle, true)
--                 ENTITY.SET_ENTITY_VISIBLE(handle, false, false)
--                 PED.SET_PED_INTO_VEHICLE(handle, vehicle, -1)
--                 TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(handle, vehicle, dest.x, dest.y, dest.z, 30.0, 4, 5.0)
--                 utils.notify("Vehicle", "On the route!", 25, 0)
--             end)
-- 		end)
-- 	elseif not state then
-- 		VEHICLE.SET_VEHICLE_FIXED(vehicle)
-- 		VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0.0)
-- 		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
-- 		entity.delete(ped)
-- 		system.notify("Vehicle", "Your vehicle has been delivered!", 25, 0)
-- 	end
-- end)

--NETWORK

subs.main.networkBlock = menu.add_mono_block(subs.main.page, "Network", 1)

menu.add_static_text(subs.main.networkBlock, "Session logs")

stuff.logMethods = {
    "None", "File", "Console", "File & Console"
}

options.combo['onScriptEventLog'] = menu.add_combo(subs.main.networkBlock, "Script events", stuff.logMethods)
options.combo['onNetEventLog'] = menu.add_combo(subs.main.networkBlock, "Network events", stuff.logMethods)
options.combo['onKillLog'] = menu.add_combo(subs.main.networkBlock, "Kills", stuff.logMethods)
options.combo['onWarnScreenLog'] = menu.add_combo(subs.main.networkBlock, "Warning screens", stuff.logMethods)

menu.add_static_text(subs.main.networkBlock, "Kosatka missiles")

options.bool['disableKosatkaCD'] = menu.add_checkbox(subs.main.networkBlock, "Disable cooldown")
options.bool['disableKosatkaRange'] = menu.add_checkbox(subs.main.networkBlock, "Remove range limit")

menu.add_static_text(subs.main.networkBlock, "Protections")

options.bool['showOTRPlayers'] = menu.add_checkbox(subs.main.networkBlock, "Show OTR players")
options.combo['adminDetection'] = menu.add_combo(subs.main.networkBlock, "R* Admin join", {"None", "Notify", "Bail", "Quit"})
-- options.combo['onCage'] = menu.add_combo(subs.main.networkBlock, "Cage", {"None", "Block"})

function OnInit()
    if doesFileExist(paths.configs.defaults) then
        if getDefaults().config then
            loadConfig()
            options.configIgnore['autoLoadConfig']:set(true)
        end
    end
    console.log(10, string.format("[INIT] All modules were initialized in %f sec\n", os.clock() - startTime))
    utils.notify(string.format("BoolyScript %s", BSVersion), "Script has been loaded successfuly.\nAuthor: @OxiGen#1337.\nIf you found a bug or have a suggestion\nDM me in Discord.", 17, 1)
end

stuff.deadEyeActive = false
stuff.isNitroEnabled = false
stuff.isNitroActive = false
stuff.isCruiseControlEnabled = false
stuff.cruiseControlSpeed = 0.0
timers.nitro = os.time()
timers.useCounters = os.clock()
stuff.isCountersEnabled = false
stuff.rightSignal = false
stuff.leftSignal = false
stuff.isAlreadyDead = {}
stuff.isAlreadyTalking = {}
stuff.activePlayerBlips = {}

function OnKeyPressed(key, isDown)
    if key == keys.E then
        if options.bool['debugGun']:get_bool() and isDown then
            thread.create(function()
                utils.notify("Note", "Copied in log", 26, 0)
                local pEntity = memory.alloc(8)
                if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(PLAYER.PLAYER_ID(), pEntity) then
                    local entity = memory.read_int64(pEntity)
                    local etype
                    local ehealth = ENTITY.GET_ENTITY_HEALTH(entity)
                    local emaxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(entity)
                    local coords = features.getEntityCoords(entity)
                    local hash = ENTITY.GET_ENTITY_MODEL(entity)
                    if ENTITY.GET_ENTITY_TYPE(entity) == 1 then etype = "Ped"
                    elseif ENTITY.GET_ENTITY_TYPE(entity) == 2 then etype = "Vehicle"
                    elseif ENTITY.GET_ENTITY_TYPE(entity) == 3 then etype = "Object"
                    else etype = "Unknown"
                    end
                    if entity ~= 0 then
                        print(string.format("[Debug gun]\n\tEntity hash: %s\n\tID: %s\n\tType: %s\n\tHealth: %s\t Max heath: %s\n\tCoords: \n\tX: %s\tY: %s\tZ: %s\n", hash, entity, etype, ehealth, emaxhealth, coords.x, coords.y, coords.z))
                    end
                end
                memory.free(pEntity)
            end)
        end
        if options.bool['useCounters']:get_bool() then
            stuff.isCountersEnabled = isDown
        end
        if options.bool['useVehicleSignals']:get_bool() then
            system.fiber(function()
                local mult = 1.0
                if isDown then mult = 6.0 end
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(features.getLocalVehicle(false), mult)
            end)
        end
        system.fiber(function()
            AUDIO.SET_HORN_ENABLED(features.getLocalVehicle(false), not options.bool['useVehicleSignals']:get_bool())
        end)
    end
    if key == keys.X and isDown then
        stuff.isNitroEnabled = true
    end
    if key == keys.L and isDown then
        if options.bool['cruiseControl']:get_bool() then
            stuff.isCruiseControlEnabled = not stuff.isCruiseControlEnabled
            utils.notify("Cruise control", "Cruise control " .. features.stateify(stuff.isCruiseControlEnabled), 25, 0)
            stuff.cruiseControlSpeed = ENTITY.GET_ENTITY_SPEED(features.getLocalVehicle(false), true)
        end
    end
    if key == keys.W then
        if options.bool['superDrive']:get_bool() then
            stuff.isSuperDriveEnabled = isDown
        end
    end
    if key == keys.ArrowLeft then
        if options.bool['useVehicleSignals']:get_bool() and isDown then
            system.fiber(function()
                stuff.leftSignal = not stuff.leftSignal
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(features.getLocalVehicle(false), 1, stuff.leftSignal)
            end)
        end
    end
    if key == keys.ArrowRight then
        if options.bool['useVehicleSignals']:get_bool() and isDown then
            system.fiber(function()
                stuff.rightSignal = not stuff.rightSignal
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(features.getLocalVehicle(false), 0, stuff.rightSignal)
            end)
        end
    end
end

function OnNetworkEvent(pid, eventInfo, eventBuf)
    local ignore = {
        ["REMOTE_SCRIPT_INFO_EVENT"] = true,
        ["NETWORK_CHECK_EXE_SIZE_EVENT"] = true,
        ["CACHE_PLAYER_HEAD_BLEND_DATA_EVENT"] = true,
        ["SCRIPT_ARRAY_DATA_VERIFY_EVENT"] = true,
        ["REMOTE_SCRIPT_LEAVE_EVENT"] = true,
        ["GIVE_CONTROL_EVENT"] = true,
        ["NETWORK_TRAIN_REPORT_EVENT"] = true,
        ["SCRIPTED_GAME_EVENT"] = true,
        ["NETWORK_ENTITY_AREA_STATUS_EVENT"] = true,
        ["CLEAR_AREA_EVENT"] = true,
        ["NETWORK_UPDATE_SYNCED_SCENE_EVENT"] = true,
        ["PLAYER_CARD_STAT_EVENT"] = true,
    }
    if ignore[net.get_name(eventInfo)] then return end
    if options.combo['onNetEventLog']:get() > 0 then
        local logInfo = string.format("Sender: %s | Event name: %s | Event hash: %s", player.get_name(pid), net.get_name(eventInfo), net.get_hash(eventInfo))
        if options.combo['onNetEventLog']:get() == 1 or options.combo['onNetEventLog']:get() == 3 then
            features.logInFile("Network event", logInfo, paths.logs.netEvents)
        end
        if options.combo['onNetEventLog']:get() == 2 or options.combo['onNetEventLog']:get() == 3 then
            console.log("[Network event] ".. logInfo .. '\n')
        end
    end
end

function OnScriptEvent(pid, eventHash, eventArgs)
    if options.combo['onScriptEventLog']:get() > 0 then
        local logInfo = string.format("Sender: %s | Event hash: %s | Event args: %s", player.get_name(pid), eventHash, table.concat(eventArgs, ", "))
        if options.combo['onScriptEventLog']:get() == 1 or options.combo['onScriptEventLog']:get() == 3 then
            features.logInFile("Script event", logInfo, paths.logs.scriptEvents)
        end
        if options.combo['onScriptEventLog']:get() == 2 or options.combo['onScriptEventLog']:get() == 3 then
            console.log("[Script event] ".. logInfo .. '\n')
        end
    end
end

function OnPlayerDeath(pid)
    if options.combo['onKillLog']:get() > 0 then
        local logInfo = ""
        local killedPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local sourceOfDeath = PED.GET_PED_SOURCE_OF_DEATH(killedPed)
        local killerPid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(sourceOfDeath)
        if killerPid ~= -1 then
            local killerPid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(sourceOfDeath)
            logInfo = string.format("%s killed %s with %s", player.get_name(killerPid), player.get_name(pid), features.getCauseOfDeathStr(killedPed, parsedFiles.weaponsSimp))
        else
            logInfo = string.format("%s died", player.get_name(pid))
        end
        if options.combo['onKillLog']:get() == 1 or options.combo['onKillLog']:get() == 3 then
            features.logInFile("Kill", logInfo, paths.logs.weapons)
        end
        if options.combo['onKillLog']:get() == 2 or options.combo['onKillLog']:get() == 3 then
            console.log("[Kill] " ..  logInfo .. '\n')
        end
    end
end

function OnWarningScreen(thread, header, line1, line2, key)
    print(1)
    local logInfo = string.format("Thread: %s\nHeader: %s\nText line (1): %s\nText line (2): %s\nKey: %s", thread, header, line1, line2, key)
    if options.combo['onWarnScreenLog']:get() > 0 then
        if options.combo['onWarnScreenLog']:get() == 1 or options.combo['onWarnScreenLog']:get() == 3 then
            features.logInFile("Warning screen", logInfo, paths.logs.warnScreens)
        end
        if options.combo['onWarnScreenLog']:get() == 2 or options.combo['onWarnScreenLog']:get() == 3 then
            console.log("[Warning screen] " ..  logInfo .. '\n')
        end
    end
end

function OnPlayerOtr(pid)
    print(pid)
    if options.bool['showOTRPlayers']:get() then
        local ped = features.getPlayerPed(pid)
        local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
        HUD.SET_BLIP_SPRITE(blip, 1)
        HUD.SET_BLIP_COLOUR(blip, 55)
        HUD.SHOW_HEIGHT_ON_BLIP(blip, false)
        HUD.SET_BLIP_ROTATION(blip, math.ceil(ENTITY.GET_ENTITY_HEADING(ped)))
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(ped, false)
        stuff.activePlayerBlips[pid] = blip
        utils.notify("Off the radar", "Player " .. player.get_name(pid) .. "is otr", 22, 0)
    end
end

function OnPlayerJoin(pid)
    -- http.get("http://ip-api.com/json/" .. ip, function(code, headers, content)
    --     local parsedContent = json:decode(content)
    -- end)
    thread.create(function()
        if options.combo['adminDetection']:get() > 0 then
            if player.is_rockstar_dev(pid) then
                local reaction = "Notify"
                if options.combo['adminDetection']:get() == 2 then
                    NETWORK._SHUTDOWN_AND_LOAD_MOST_RECENT_SAVE()
                    reaction = "Bail"
                end
                if options.combo['adminDetection']:get() == 3 then
                    MISC._RESTART_GAME()
                    reaction = "Quit"
                end
                utils.notify("R* Admin", string.format("Name: %s | RID: %s | Joined your session\nReaction: %s", player.get_name(pid), player.get_rid(pid), reaction), 3, 2)
            end 
        end
    end)
end

function OnFeatureTick()
    if options.bool['clumsiness']:get_bool() then
        thread.create(function()
            PED.SET_PED_RAGDOLL_ON_COLLISION(PLAYER.PLAYER_PED_ID(), true)
            wait(0)
        end)
    end
    if options.bool['deadEyeEnabled']:get_bool() then
        thread.create(function()
            local timeScale = 0.4
            if player.is_aiming(PLAYER.PLAYER_ID()) then
                if not stuff.deadEyeActive then
                    GRAPHICS.ANIMPOSTFX_PLAY("BulletTime", 0, true)
                    MISC.SET_TIME_SCALE(timeScale)
                    stuff.deadEyeActive = true
                end
            elseif stuff.deadEyeActive then
                GRAPHICS.ANIMPOSTFX_STOP("BulletTime")
                MISC.SET_TIME_SCALE(1.0)
                stuff.deadEyeActive = false
            end
            wait(0)
        end)
    end
    if options.bool['becomeGangsta']:get_bool() then
        thread.create(function()
		    WEAPON.SET_WEAPON_ANIMATION_OVERRIDE(PLAYER.PLAYER_PED_ID(), utils.joaat("Gang1H"))
        end)
    end
    if options.sliderFloat['runSpeedMult']:get_float() > 0.0 then
        thread.create(function()
	        PLAYER.SET_RUN_SPRINT_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), options.sliderFloat['runSpeedMult']:get_float())
            wait(0)
        end)
    end
    if options.sliderFloat['swimSpeedMult']:get_float() > 0.0 then
        thread.create(function()
            PLAYER.SET_SWIM_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), options.sliderFloat['swimSpeedMult']:get_float())
            wait(0)
        end)
    end
    do
        thread.create(function()
            for name, state in pairs(stuff.activePedFlags) do
                PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), stuff.pedFlags[name], state)
            end
            wait(0)
        end)
    end
    do
        thread.create(function()
            for name, state in pairs(stuff.audioFlags) do
                AUDIO.SET_AUDIO_FLAG(name, state)
            end
            wait(0)
        end)
    end
    if options.bool['allowPauseInOnline']:get_bool() then
        thread.create(function()
            if HUD.IS_PAUSE_MENU_ACTIVE() then
                MISC.SET_TIME_SCALE(0.0)
            else
                MISC.SET_TIME_SCALE(1.0)
            end
        end)
    end
    if options.bool['allowPauseWhenDead']:get_bool() then
        thread.create(function()
            HUD._ALLOW_PAUSE_MENU_WHEN_DEAD_THIS_FRAME()
        end)
    end
    if options.bool['silentBST']:get_bool() then
        thread.create(function()            
            GRAPHICS.ANIMPOSTFX_STOP("MP_Bull_tost")
        end)
    end
    -- if options.bool['cleanupPeds']:get() then
    --     thread.create(function()
    --         for _, handle in ipairs(pools.get_all_peds()) do
    --             if features.doesEntityExist(handle) then
    --                 if features.getDistance(features.getEntityCoords(PLAYER.PLAYER_PED_ID(), false), features.getEntityCoords(handle), false) <= options.sliderInt['cleanupRadius']:get() then
    --                     entity.delete(handle)
    --                 end
    --             end
    --         end
    --     end)
    -- end
    -- if options.bool['cleanupVehs']:get_bool() then
    --     thread.create(function()            
    --         for _, handle in ipairs(pools.get_all_vehicles()) do
    --             if features.getDistance(features.getEntityCoords(PLAYER.PLAYER_PED_ID()), features.getEntityCoords(handle), false) <= options.sliderInt['cleanupRadius']:get_int() then
    --                 entity.request_control(handle, function()
    --                     entity.delete(handle)
    --                 end)
    --             end
    --         end
    --     end)
    -- end
    if options.bool['engineAlwaysOn']:get_bool() then
        thread.create(function()
            local vehicle = features.getLocalVehicle(false)
            if features.doesEntityExist(vehicle) then
                VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 0)
                VEHICLE._SET_VEHICLE_LIGHTS_MODE(vehicle, 2)
            end
        end)
    end
    if options.bool['crewNitro']:get_bool() then
        thread.create(function()
            if not stuff.isNitroEnabled then return end
            local vehicle = features.getLocalVehicle(false)
            if features.doesEntityExist(vehicle) and not stuff.isNitroActive then
                callbacks.requestPtfxAsset("veh_xs_vehicle_mods", function()				
                    VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, true, 2500.0, options.sliderFloat['crewNitroPower']:get_float(), 999999999999999999.0, false)
                    timers.nitro = os.time()
                    stuff.isNitroActive = true
                end)
            end
            if os.time() - timers.nitro >= 2.5 and stuff.isNitroActive then
                VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, false, 2500.0, options.sliderFloat['crewNitroPower']:get_float(), 999999999999999999.0, false)
                stuff.isNitroActive = false
                stuff.isNitroEnabled = false
            end
        end)
    end
    if options.bool['cruiseControl']:get_bool() then
        thread.create(function()
            if not stuff.isCruiseControlEnabled then return end
            local vehicle = features.getLocalVehicle(false)
            if not features.doesEntityExist(vehicle) or not PED.IS_PED_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle, false) then return end
            if not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle) or ENTITY.IS_ENTITY_IN_AIR(vehicle) then return end
            local speed = stuff.cruiseControlSpeed
            local multiplier = 1
            if ENTITY.GET_ENTITY_SPEED_VECTOR(vehicle, true).y < 0 then multiplier = -1 end
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, speed*multiplier)
        end)
    end
    if options.bool['disableTurbulence']:get_bool() then
        thread.create(function()
            local vehicle = features.getLocalVehicle(false)
            if features.doesEntityExist(vehicle) and VEHICLE.IS_THIS_MODEL_A_PLANE(ENTITY.GET_ENTITY_MODEL(vehicle)) then
                VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(vehicle, 0.0)
            end
        end)
    end
    do
        thread.create(function()
            if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
                VEHICLE.SET_VEHICLE_GRAVITY(features.getLocalVehicle(false), not options.bool['disableGravity']:get_bool())
            end
        end)
    end
    -- do
    --     thread.create(function()
    --         local vehicle = features.getLocalVehicle(false)
    --         local model = ENTITY.GET_ENTITY_MODEL(vehicle)
    --         print(model)
    --         print(VEHICLE.IS_THIS_MODEL_A_PLANE(model))
    --         print(VEHICLE.IS_THIS_MODEL_A_HELI(model))
    --         if VEHICLE.IS_THIS_MODEL_A_PLANE(model) or VEHICLE.IS_THIS_MODEL_A_HELI(model) then 
    --             ENTITY.SET_ENTITY_COLLISION(vehicle, not options['disableCollision']:get_bool(), true)
    --         end
    --     end)
    -- end
    if options.bool['superDrive']:get_bool() then
        thread.create(function()
            if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
                local vehicle = features.getLocalVehicle(false)
                local multiplier = options.sliderFloat['superDrivePower']:get_float()
                ENTITY.SET_ENTITY_MAX_SPEED(vehicle, 9999.0)
                if stuff.isSuperDriveEnabled then
                    entity.request_control(vehicle, function(handle)
                        ENTITY.APPLY_FORCE_TO_ENTITY(handle, 1, 0.0, multiplier / 10.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end)
                end
            end
        end)
    end
    if options.bool['useCounters']:get_bool() then
        thread.create(function()
            if not stuff.isCountersEnabled then return end
            if os.clock() - timers.useCounters >= 0.3 then
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
                if features.doesEntityExist(vehicle) and PED.IS_PED_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), vehicle) then
                    WEAPON.GIVE_WEAPON_TO_PED(PLAYER.PLAYER_PED_ID(), string.joaat("WEAPON_FLAREGUN"), 20, true, false)
                    local offset = {}
                    offset.rightStart = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, -2.0, -2.0, 0.0)
                    offset.rightEnd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, -30.0, -40.0, -10.0)
                    offset.leftStart = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 2.0, -2.0, 0.0)
                    offset.leftEnd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(vehicle, 30.0, -40.0, -10.0)
                    
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset.rightStart.x, offset.rightStart.y, offset.rightStart.z, offset.rightEnd.x, offset.rightEnd.y, offset.rightEnd.z, 0, true, 1198879012, PLAYER.PLAYER_PED_ID(), true, false, 1)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset.leftStart.x, offset.leftStart.y, offset.leftStart.z, offset.leftEnd.x, offset.leftEnd.y, offset.leftEnd.z, 0, true, 1198879012, PLAYER.PLAYER_PED_ID(), true, false, 1)
                    timers.useCounters = os.clock()
                end
            end
        end)
    end
    if options.bool['disableDeformation']:get_bool() then
        thread.create(function()
            local vehicle = features.getLocalVehicle(false)
            if features.doesEntityExist(vehicle) then
                VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
            end
        end)
    end
    if options.bool['vehicleSpin']:get_bool() then
        thread.create(function()            
            local vehicle = features.getLocalVehicle(true)
            if features.doesEntityExist(vehicle) then
                entity.request_control(vehicle, function(handle)
                    ENTITY.SET_ENTITY_HEADING(handle, stuff.vehicleSpinHead)
                end)
                if stuff.vehicleSpinHead == 360 then stuff.vehicleSpinHead = 0 else stuff.vehicleSpinHead = stuff.vehicleSpinHead + 0.5 end
            end
        end)
    end
    -- if options.bool['driveToMe']:get_bool() then
    --     local vehicle = features.getLocalVehicle(true)
	-- 	local coords = features.getEntityCoords(vehicle)
	-- 	local dest = features.getEntityCoords(PLAYER.PLAYER_PED_ID())
	-- 	if features.getDistance(coords, dest, false) < 5 then
	-- 		options.bool['driveToMe']:set_bool(false)
	-- 	end
    -- end
    if options.bool['disableKosatkaCD']:get() then
        thread.create(function()
            script_global:new(scripts.globals['kosatkaMissileCooldown']):set_float(0.0)
        end)
    end
    if options.bool['disableKosatkaRange']:get() then
        thread.create(function()
            script_global:new(scripts.globals['kosatkaMissileRange']):set_float(150000.0)
        end)
    end
    thread.create(function()
        for pid = 0, 31 do
            if player.is_connected(pid) then

                if not player.is_alive(pid) and stuff.isAlreadyDead[pid] == nil then
                    OnPlayerDeath(pid)
                    stuff.isAlreadyDead[pid] = true
                elseif player.is_alive(pid) and stuff.isAlreadyDead[pid] then
                    stuff.isAlreadyDead[pid] = nil
                end

                if scripts.globals.getPlayerOtr(pid) == 1 and stuff.activePlayerBlips[pid] == nil then
                    OnPlayerOtr(pid)
                elseif scripts.globals.getPlayerOtr(pid) == 0 and stuff.activePlayerBlips[pid] then
                    HUD.SET_BLIP_DISPLAY(stuff.activePlayerBlips[pid], 0)
                    stuff.activePlayerBlips[pid] = nil
                end

            else
                if stuff.activePlayerBlips[pid] then
                    HUD.SET_BLIP_DISPLAY(stuff.activePlayerBlips[pid], 0)
                    stuff.activePlayerBlips[pid] = nil
                end
                stuff.isAlreadyTalking[pid] = nil
                stuff.isAlreadyDead[pid] = nil
            end
        end
    end)
end

function OnDone()
    menu.delete_page(subs.main.page)
end
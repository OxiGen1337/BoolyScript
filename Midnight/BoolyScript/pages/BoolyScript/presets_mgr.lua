require("BoolyScript/system/events_listener")
require("BoolyScript/util/menu")
local paths = require("BoolyScript/globals/paths")
require("BoolyScript/util/notify_system")
local json = require("BoolyScript/modules/JSON")
local parse = require("BoolyScript/util/parse")
local filesys = require("BoolyScript/util/file_system")
require("BoolyScript/globals/stuff")

local page = GET_PAGES()['BS_Main']
local self = menu.add_mono_block(page, "Presets manager", "BS_PresetsMgr", BLOCK_ALIGN_LEFT)

menu.add_static_text(self, "Weapons manager", "BS_PresetsMgr_WepManager")

menu.add_combo(self, "Saved loadouts", "BS_PresetsMgr_WepManager_SavedLoadouts", {"None"})

wepLoadoutsTable = {}

local function reloadWepLoadouts()
    local wepLoadouts = {"None"}
    for line in io.popen("dir \"" .. paths.folders.loadouts .. "\" /a /b", "r"):lines() do
        table.insert(wepLoadouts, line)
    end
    wepLoadoutsTable = wepLoadouts
    GET_OPTIONS().combo['BS_PresetsMgr_WepManager_SavedLoadouts']:set_table(wepLoadouts)
    GET_OPTIONS().combo['BS_PresetsMgr_WepManager_SavedLoadouts']:set(0)
    return wepLoadouts
end

local blWepCategories = {["GROUP_DIGISCANNER"] = false, ["GROUP_NIGHTVISION"] = false, ["GROUP_TRANQILIZER"] = false}

local isEmpty = function (value)
    return ((value == nil) or (value == "") or (value == "NULL"))
end

local function saveWepLoadout(name)
    local path = paths.folders.loadouts .. '\\' .. name .. ".json"
    local file = io.open(path, 'w+')
    local configTable = {}
    for _, wepInfo in ipairs(ParsedFiles.weapons) do
        if WEAPON.HAS_PED_GOT_WEAPON(PLAYER.PLAYER_PED_ID(), wepInfo['Hash'], false)
        and not isEmpty(wepInfo['Category']) 
        and blWepCategories[wepInfo['Category']] ~= false
        and not isEmpty(wepInfo['TranslatedLabel']) 
        and not isEmpty(wepInfo['TranslatedLabel']['Name'])
        and wepInfo['TranslatedLabel']['Name'] ~= 'WT_INVALID'
        and not isEmpty(wepInfo['Tints'])
        then
            print(WEAPON.HAS_PED_GOT_WEAPON(PLAYER.PLAYER_PED_ID(), wepInfo['Hash'], false))
            configTable[wepInfo['Name']] = {}
            configTable[wepInfo['Name']]['Name'] = wepInfo['TranslatedLabel']['Name']
            configTable[wepInfo['Name']]['Hash'] = wepInfo['Hash']
            configTable[wepInfo['Name']]['TintIndex'] = WEAPON.GET_PED_WEAPON_TINT_INDEX(PLAYER.PLAYER_PED_ID(), wepInfo['Hash'])
            configTable[wepInfo['Name']]['Components'] = {}
            for _, componentInfo in ipairs(wepInfo['Components']) do
                if WEAPON.HAS_PED_GOT_WEAPON_COMPONENT(PLAYER.PLAYER_PED_ID(), wepInfo['Hash'], componentInfo['Hash'])
                and not isEmpty(componentInfo['TranslatedLabel']) 
                and not isEmpty(componentInfo['TranslatedLabel']['Name']) 
                then
                    configTable[wepInfo['Name']]['Components'][componentInfo['TranslatedLabel']['Name']] = {}
                    configTable[wepInfo['Name']]['Components'][componentInfo['TranslatedLabel']['Name']]['Name'] = componentInfo['TranslatedLabel']['Name']
                    configTable[wepInfo['Name']]['Components'][componentInfo['TranslatedLabel']['Name']]['Hash'] = componentInfo['Hash']
                end
            end
        end
    end
    file:write(json:encode_pretty(configTable))
    file:close()
    notify.success("Saved loadouts", "Successfully saved weapon loadout.", GET_NOTIFY_ICONS().weapons)
    reloadWepLoadouts()
end

local function loadWepLoadout(path)
    if not filesys.doesFileExist(path) then 
        notify.fatal("Saved loadouts", "Failed to load loadout | File doesnt exist.", GET_NOTIFY_ICONS().weapons)
        return
    end
    local parsedTable = parse.json(path)
    WEAPON.REMOVE_ALL_PED_WEAPONS(PLAYER.PLAYER_PED_ID(), false)
    for _, wepInfo in pairs(parsedTable) do
        local hash = wepInfo['Hash']
        local tintIndex = wepInfo['TintIndex']
        local componentsT = wepInfo['Components']
        WEAPON.GIVE_WEAPON_TO_PED(PLAYER.PLAYER_PED_ID(), hash, 9999, false, false)
        WEAPON.SET_PED_WEAPON_TINT_INDEX(PLAYER.PLAYER_PED_ID(), hash, tintIndex)
        for _, componentInfo in pairs(componentsT) do
            WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(PLAYER.PLAYER_PED_ID(), hash, componentInfo['Hash'])
            --wait(0)
        end
        --wait(0)
    end
    notify.success("Saved loadouts", "Successfully loaded weapon loadout.", GET_NOTIFY_ICONS().weapons)
end

menu.add_button(self, "Load loadout", "BS_PresetsMgr_WepManager_LoadLoadout", function()
    local name = wepLoadoutsTable[GET_OPTIONS().combo['BS_PresetsMgr_WepManager_SavedLoadouts']:get()+1]
    local path = paths.folders.loadouts .. '\\' .. name
    thread.create(function ()
        loadWepLoadout(path)
    end)
end)

menu.add_checkbox(self, "Load loadout every session", "BS_PresetsMgr_WepManager_LoadEverySession")

listener.register("BS_PresetsMgr_WepManager_LoadEverySession", GET_EVENTS_LIST().OnTransitionEnd, function ()
    if not GET_OPTIONS().checkbox["BS_PresetsMgr_WepManager_LoadEverySession"]:get() then return end
    thread.create(function ()
        local name = wepLoadoutsTable[GET_OPTIONS().combo['BS_PresetsMgr_WepManager_SavedLoadouts']:get()+1]
        local path = paths.folders.loadouts .. '\\' .. name
        loadWepLoadout(path)
    end)
end)

menu.add_button(self, "Delete loadout", "BS_PresetsMgr_WepManager_DeleteLoadout", function()
    local name = wepLoadoutsTable[GET_OPTIONS().combo['BS_PresetsMgr_WepManager_SavedLoadouts']:get()+1]
    local path = paths.folders.loadouts .. '\\' .. name
    filesys.delete(path)
    reloadWepLoadouts()
end)

menu.add_input_text(self, "Loadout name", "BS_PresetsMgr_WepManager_LoadoutName")

menu.add_button(self, "Save loadout", "BS_PresetsMgr_WepManager_SaveLoadout", function()
    local name = GET_OPTIONS().inputText['BS_PresetsMgr_WepManager_LoadoutName']:get()
    if isEmpty(name) then name = "Untitled" end
    thread.create(function ()
        saveWepLoadout(name)
    end)
end)

menu.add_button(self, "Refresh loadouts", "BS_PresetsMgr_WepManager_RefreshLoadouts", reloadWepLoadouts)

menu.add_static_text(self, "Outfits manager", "BS_PresetsMgr_OutfitManager")

outfitsTable = {}

menu.add_combo(self, "Saved outfits", "BS_PresetsMgr_OutfitManager_SavedOutfits", {"None"})

local function reloadOutfits()
    local outfits = {"None"}
    for line in io.popen("dir \"" .. paths.folders.outfits .. "\" /a /b", "r"):lines() do
        table.insert(outfits, line)
    end
    outfitsTable = outfits
    GET_OPTIONS().combo['BS_PresetsMgr_OutfitManager_SavedOutfits']:set_table(outfits)
    GET_OPTIONS().combo['BS_PresetsMgr_OutfitManager_SavedOutfits']:set(0)
    return outfits
end

local function saveOutfit(name)
    local config = {
        components = {},
        props = {}
    }
    local ped = PLAYER.PLAYER_PED_ID()
    for i = 0, 11 do
        local out = {
            ["drawable"] = PED.GET_PED_DRAWABLE_VARIATION(ped, i),
            ["texture"] = PED.GET_PED_TEXTURE_VARIATION(ped, i),
            ["palette"] = PED.GET_PED_PALETTE_VARIATION(ped, i)
        }
        config.components[tostring(i)] = out
	end
	for i = 0, 7 do
        local out = {
            ['drawable'] = PED.GET_PED_PROP_INDEX(ped, i),
            ['texture'] = PED.GET_PED_PROP_TEXTURE_INDEX(ped, i)
        }
        config.props[tostring(i)] = out
	end
    local path = paths.folders.outfits .. "\\" .. name .. ".json"
    local file = io.open(path, "w+")
    if not file then 
        notify.fatal("Saved outfits", "Failed to save outfit | Couldnt create a file.", GET_NOTIFY_ICONS().self)
        return
    end
    file:write(json:encode_pretty(config))
    file:close()
    reloadOutfits()
    notify.success("Saved outfits", string.format("Successfully saved outfit:\nName: %s", name), GET_NOTIFY_ICONS().self)
end

local function loadOutfit(path)
    if not filesys.doesFileExist(path) then 
        notify.fatal("Saved outfits", "Failed to load outfit | File doesnt exist.", GET_NOTIFY_ICONS().self)
        return
    end
    local content = parse.json(path)
    for ID_s, value_t in pairs(content.components) do
        local componentID = tonumber(ID_s)
        local drawableID = value_t['drawable']
        local textureID = value_t['texture']
        local paletteID = value_t['palette']
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), componentID, drawableID, textureID, paletteID)
        --wait(0)
    end
    for ID_s, value_t in ipairs(content.props) do
        local componentID = tonumber(ID_s)
        local drawableID = value_t['drawable']
        local textureID = value_t['texture']
        PED.SET_PED_PROP_INDEX(PLAYER.PLAYER_PED_ID(), componentID, drawableID, textureID)
        --wait(0)
    end
    notify.success("Saved outfits", "Successfully loaded outfit.", GET_NOTIFY_ICONS().self)
end

menu.add_button(self, "Load outfit", "BS_PresetsMgr_OutfitManager_LoadOutfit", function()
    local name = outfitsTable[GET_OPTIONS().combo['BS_PresetsMgr_OutfitManager_SavedOutfits']:get()+1]
    local path = paths.folders.outfits .. '\\' .. name
    thread.create(function ()
        loadOutfit(path)
    end)
end)

menu.add_checkbox(self, "Load outfit every session", "BS_PresetsMgr_OutfitManager_LoadEverySession")

listener.register("BS_PresetsMgr_OutfitManager_LoadEverySession", GET_EVENTS_LIST().OnTransitionEnd, function ()
    if not GET_OPTIONS().checkbox["BS_PresetsMgr_OutfitManager_LoadEverySession"]:get() then return end
    thread.create(function ()
        local name = outfitsTable[GET_OPTIONS().combo['BS_PresetsMgr_OutfitManager_SavedOutfits']:get()+1]
        local path = paths.folders.outfits .. '\\' .. name
        loadOutfit(path)
    end)
end)

menu.add_button(self, "Delete outfit", "BS_PresetsMgr_OutfitManager_DeleteOutfit", function()
    local name = outfitsTable[GET_OPTIONS().combo['BS_PresetsMgr_OutfitManager_SavedOutfits']:get()+1]
    local path = paths.folders.outfits .. '\\' .. name
    filesys.delete(path)
    reloadOutfits()
end)

menu.add_input_text(self, "Outfit name", "BS_PresetsMgr_OutfitManager_OutfitName")

menu.add_button(self, "Save outfit", "BS_PresetsMgr_OutfitManager_SaveOutfit", function()
    log.dbg("Button")
    local name = GET_OPTIONS().inputText['BS_PresetsMgr_OutfitManager_OutfitName']:get()
    saveOutfit(name)
end)

menu.add_button(self, "Refresh outfits", "BS_PresetsMgr_OutfitManager_RefreshOutfits", reloadOutfits)

listener.register("BS_PresetsMgr_WeaponAndOutfitsRefresh", GET_EVENTS_LIST().OnInit, function ()
    reloadOutfits()
    reloadWepLoadouts()
end)

-- END
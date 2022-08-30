local features = {}

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

function features.getEntityCoords(entity)
    return ENTITY.GET_ENTITY_COORDS(entity, true)
end

function features.getDistance(coords1, coords2, useZ)
    return MISC.GET_DISTANCE_BETWEEN_COORDS(coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z, useZ)
end

function features.getWaypointCoords()
	if not HUD.IS_WAYPOINT_ACTIVE() then return end
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(8)
    return HUD.GET_BLIP_COORDS(blip)
end

function features.getClosestVehicle()
	local minDistance = 1337228
	local closestVehicle
	local localCoords = features.getEntityCoords(PLAYER.PLAYER_PED_ID())
	for _, vehicle in ipairs(pools.get_all_vehicles()) do
		local vehicleCoords = features.getEntityCoords(vehicle)
		local distance = features.getDistance(localCoords, vehicleCoords, false)
		if distance < minDistance and features.isModelValid(ENTITY.GET_ENTITY_MODEL(vehicle)) then
			closestVehicle = vehicle
			minDistance = distance
		end
	end
	return closestVehicle
end

function features.doesEntityExist(entity)
    return ENTITY.DOES_ENTITY_EXIST(entity)
end

function features.getLocalVehicle(includeLast)
	return PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), includeLast)
end

function features.isModelValid(hash)
	return STREAMING.IS_MODEL_VALID(hash)
end

function features.stateify(value)
    if value == true then return "enabled"
    elseif value == false then return "disabled"
    else return "unknown" end
end

function features.isControlPressed(ctrlID)
	return PAD.IS_CONTROL_PRESSED(1, ctrlID)
end

function features.logInFile(tag, text, path)
	local file = io.open(path, 'a+')
	local outStr = string.format("[%s] [%s] %s\n", os.date("%c"), tostring(tag), tostring(text))
	file:write(outStr)
	file:close()
end

function features.getCauseOfDeathStr(ped, wepTable)
	local cause = PED.GET_PED_CAUSE_OF_DEATH(ped)
	for name, hash in pairs(wepTable) do
		if hash == cause then
			if HUD._GET_LABEL_TEXT(name) ~= "NULL" then
				return HUD._GET_LABEL_TEXT(name)
			end
		end
	end
	if ENTITY.IS_ENTITY_A_VEHICLE(cause) then 
		if HUD._GET_LABEL_TEXT(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(cause)) ~= "NULL" then
			return HUD._GET_LABEL_TEXT(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(cause))
		end
	end
	return "World collision"
end

function features.getPlayerPed(pid)
	return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
end

return features
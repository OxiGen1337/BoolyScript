local features = {}

function features.getWaypointCoords()
	if not HUD.IS_WAYPOINT_ACTIVE() then return end
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(8)
    return HUD.GET_BLIP_COORDS(blip)
end

function features.getDistance(coords1, coords2, useZ)
    return MISC.GET_DISTANCE_BETWEEN_COORDS(coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z, useZ)
end

return features
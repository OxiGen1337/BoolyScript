local callbacks = require '\\BoolyScript\\Lib\\callbacks'

local spawner = {}
-- spawner.spawnedPeds = {}
-- spawner.spawnedObjects = {}

function spawner.spawnPed(hash, coords, callback)
    callbacks.requestModel(hash, function()
        local ped = entity.spawn_ped(hash, coords)
        callback(ped)
        return
    end)
end

return spawner
local QBCore = exports['qb-core']:GetCoreObject()

local spawned = {}
local targetAdded = {}

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        Wait(10)
        if GetGameTimer() > timeout then
            return false
        end
    end
    return true
end

local function isInSafezone()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for i = 1, #Config.Safezones do
        local z = Config.Safezones[i]
        if #(pcoords - z.center) <= z.radius then
            return true, i
        end
    end
    return false, nil
end

local function spawnCrateForZone(i)
    local z = Config.Safezones[i]
    local model = Config.Prop.model

    if not loadModel(model) then
        print(('[SiiK-safezone-stash] Failed to load prop model for zone %s'):format(z.name))
        return
    end

    local c = z.stashProp.coords
    local obj = CreateObject(model, c.x, c.y, c.z - 1.0, false, false, false)
    SetEntityHeading(obj, z.stashProp.heading or 0.0)
    PlaceObjectOnGroundProperly(obj)

    if Config.Prop.freeze then FreezeEntityPosition(obj, true) end
    if Config.Prop.invincible then
        SetEntityInvincible(obj, true)
        SetEntityProofs(obj, true, true, true, true, true, true, true, true)
    end

    spawned[i] = obj
    SetModelAsNoLongerNeeded(model)
end

local function addTargetForZone(i)
    local z = Config.Safezones[i]

    exports['qb-target']:AddTargetEntity(spawned[i], {
        options = {
            {
                icon = Config.Target.icon,
                label = (Config.Target.label .. (' (%s)'):format(z.name)),
                action = function()
                    local inside = isInSafezone()
                    if not inside then
                        QBCore.Functions.Notify('You must be inside a safezone to use this stash.', 'error')
                        return
                    end
                    TriggerServerEvent('SiiK-safezone-stash:server:OpenPersonalStash', i)
                end
            }
        },
        distance = Config.Target.distance
    })

    targetAdded[i] = true
end

CreateThread(function()
    Wait(1000)

    for i = 1, #Config.Safezones do
        if not spawned[i] then
            spawnCrateForZone(i)
        end
        if spawned[i] and not targetAdded[i] then
            addTargetForZone(i)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    -- best-effort cleanup: remove spawned props
    for _, ent in pairs(spawned) do
        if DoesEntityExist(ent) then
            DeleteEntity(ent)
        end
    end
end)


-- Open stash using events compatible with qb/ps/lj and Quasar (qs)
RegisterNetEvent('SiiK-safezone-stash:client:OpenStash', function(stashId, other)
    other = other or {}
    -- Quasar docs + many qb-like inventories use these events
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId, {
        maxweight = other.maxweight,
        slots = other.slots,
    })
    TriggerEvent('inventory:client:SetCurrentStash', stashId)
end)

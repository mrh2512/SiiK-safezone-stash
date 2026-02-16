local QBCore = exports['qb-core']:GetCoreObject()

local function isInSafezone(src)
    local ped = GetPlayerPed(src)
    if ped <= 0 then return false end

    local pcoords = GetEntityCoords(ped)

    for i = 1, #Config.Safezones do
        local z = Config.Safezones[i]
        if #(pcoords - z.center) <= z.radius then
            return true, i
        end
    end

    return false, nil
end

RegisterNetEvent('SiiK-safezone-stash:server:OpenPersonalStash', function(zoneIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Server-side safezone validation
    local inside, realZoneIndex = isInSafezone(src)
    if not inside then
        TriggerClientEvent('QBCore:Notify', src, 'You must be inside a safezone to use this stash.', 'error')
        return
    end

    -- Use validated zone index
    zoneIndex = realZoneIndex

    local citizenid = Player.PlayerData.citizenid

    -- PRIVATE stash per player (NOT shared)
    local stashId = ('siik_safezone_%s'):format(citizenid)

    local zoneName = (Config.Safezones[zoneIndex] and Config.Safezones[zoneIndex].name) or 'Safezone'
    local label = ('%s - %s'):format(Config.Stash.label, zoneName)

    -- Use SiiK-bridge to determine active inventory and open stash appropriately
    local invInfo = exports['SiiK-bridge'] and exports['SiiK-bridge']:GetActiveInventoryInfo() or nil
    local invKey = invInfo and invInfo.key or nil
    local invRes = invInfo and invInfo.resource or nil

    local opts = {
        label = label,
        maxweight = Config.Stash.maxweight,
        slots = Config.Stash.slots,
    }

    -- Prefer a direct OpenInventory export if the active inventory provides one (e.g. qb-inventory)
    if invRes and exports[invRes] and exports[invRes].OpenInventory then
        exports[invRes]:OpenInventory(src, stashId, opts)
        return
    end

    -- Fallback: use widely-supported qb-style inventory events (also used by Quasar stash integration)
    if invKey == 'qb_like' or invKey == 'qs' or invKey == nil then
        TriggerClientEvent('SiiK-safezone-stash:client:OpenStash', src, stashId, opts)
        return
    end

    -- Best-effort unsupported inventories
    TriggerClientEvent('QBCore:Notify', src, ('Active inventory "%s" is not supported for stash opening in this resource.'):format(tostring(invKey)), 'error')

end)

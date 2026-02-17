local QBCore = exports['qb-core']:GetCoreObject()



local function getInventorySystem()
    -- priority: qs-inventory (Quasar) first, then qb-inventory
    if GetResourceState('qs-inventory') == 'started' then
        return 'qs'
    end
    if GetResourceState('qb-inventory') == 'started' then
        return 'qb'
    end
    return 'none'
end

local function openPersonalStash(src, stashId, label, slots, maxweight)
    local inv = getInventorySystem()

    if inv == 'qb' then
        -- qb-inventory v2+ (and current docs) supports OpenInventory(source, identifier, data)
        exports['qb-inventory']:OpenInventory(src, stashId, {
            label = label,
            maxweight = maxweight,
            slots = slots,
        })
        return
    end

    if inv == 'qs' then
        -- Quasar inventory requires the stash to be registered, then opened via the inventory events
        -- (this keeps compatibility with both qs-inventory "compact/advanced" variants).
        exports['qs-inventory']:RegisterStash(src, stashId, slots, maxweight)
        TriggerClientEvent('SiiK-safezone-stash:client:OpenStash', src, stashId, {
            maxweight = maxweight,
            slots = slots,
        })
        return
    end

    TriggerClientEvent('QBCore:Notify', src, 'No supported inventory found (need qb-inventory or qs-inventory).', 'error')
end

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

    openPersonalStash(src, stashId, label, Config.Stash.slots, Config.Stash.maxweight)
end)

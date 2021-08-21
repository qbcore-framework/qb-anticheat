-- Get permissions --

QBCore.Functions.CreateCallback('qb-anticheat:server:GetPermissions', function(source, cb)
    local group = QBCore.Functions.GetPermission(source)
    cb(group)
end)

-- Execute ban --

RegisterServerEvent('qb-anticheat:server:banPlayer')
AddEventHandler('qb-anticheat:server:banPlayer', function(reason)
    local src = source
    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Anti-Cheat", "white", GetPlayerName(src).." Has Been Banned For "..reason, false)
    exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(src),
        ['@license'] = QBCore.Functions.GetIdentifier(src, 'license'),
        ['@discord'] = QBCore.Functions.GetIdentifier(src, 'discord'),
        ['@ip'] = QBCore.Functions.GetIdentifier(src, 'ip'),
        ['@reason'] = reason,
        ['@expire'] = 2145913200,
        ['@bannedby'] = 'Anti-Cheat'
    })
    DropPlayer(src, "You Have Been Banned For Cheating. Contact Staff (or dont): https://discord.gg/")
end)

-- Fake events --
function NonRegisteredEventCalled(CalledEvent, source)
    TriggerClientEvent("qb-anticheat:client:NonRegisteredEventCalled", source, "Cheating", CalledEvent)
end


for x, v in pairs(Config.BlacklistedEvents) do
    RegisterServerEvent(v)
    AddEventHandler(v, function(source)
        NonRegisteredEventCalled(v, source)
    end)
end



-- RegisterServerEvent('banking:withdraw')
-- AddEventHandler('banking:withdraw', function(source)
--     NonRegisteredEventCalled('bank:withdraw', source)
-- end)

QBCore.Functions.CreateCallback('qb-anticheat:server:HasWeaponInInventory', function(source, cb, WeaponInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerInventory = Player.PlayerData.items
    local retval = false

    for k, v in pairs(PlayerInventory) do
        if v.name == WeaponInfo["name"] then
            retval = true
        end
    end
    cb(retval)
end)

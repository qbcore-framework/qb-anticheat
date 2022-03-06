local QBCore = exports['qb-core']:GetCoreObject()
local group = Config.Group
local IsDecorating = false
local flags = 0

RegisterNetEvent('qb-anticheat:client:ToggleDecorate', function(bool)
  IsDecorating = bool
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('qb-anticheat:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    IsDecorating = false
    flags = 0
end)

CreateThread(function() -- Superjump --
	while true do
        Wait(500)

        local ped = PlayerPedId()
        local player = PlayerId()

        if group == Config.Group and LocalPlayer.state.isLoggedIn then
            if IsPedJumping(ped) then
                local firstCoord = GetEntityCoords(ped)

                while IsPedJumping(ped) do
                    Wait(0)
                end

                local secondCoord = GetEntityCoords(ped)
                local lengthBetweenCoords = #(firstCoord - secondCoord)

                if (lengthBetweenCoords > Config.SuperJumpLength) then
                    flags = flags + 1
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** is flagged from anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Superjump)**")
                end
            end
        end
    end
end)

CreateThread(function() -- Speedhack --
	while true do
        Wait(500)

        local ped = PlayerPedId()
        local player = PlayerId()
        local speed = GetEntitySpeed(ped)
        local inveh = IsPedInAnyVehicle(ped, false)
        local ragdoll = IsPedRagdoll(ped)
        local jumping = IsPedJumping(ped)
        local falling = IsPedFalling(ped)

        if group == Config.Group and LocalPlayer.state.isLoggedIn then
            if not inveh then
                if not ragdoll then
                    if not falling then
                        if not jumping then
                            if speed > Config.MaxSpeed then
                                flags = flags + 1
                                TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** is flagged from anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Speedhack)**")
                            end
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()	-- Invisibility --
    while true do
        Wait(10000)

        local ped = PlayerPedId()
        local player = PlayerId()

        if group == Config.Group and LocalPlayer.state.isLoggedIn then
            if not IsDecorating then
                if not IsEntityVisible(ped) then
                    SetEntityVisible(ped, 1, 0)
                    TriggerEvent('QBCore:Notify', "QB-ANTICHEAT: You were invisible and have been made visible again!")
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Made player visible", "green", "** @everyone " ..GetPlayerName(player).. "** was invisible and has been made visible again by QB-Anticheat")
                end
            end
        end
    end
end)

CreateThread(function() -- Nightvision --
    while true do
        Wait(2000)

        local ped = PlayerPedId()
        local player = PlayerId()

        if group == Config.Group and LocalPlayer.state.isLoggedIn then
            if GetUsingnightvision(true) then
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** is flagged from anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Nightvision)**")
                end
            end
        end
    end
end)

CreateThread(function() -- Thermalvision --
    while true do
        Wait(2000)

        local ped = PlayerPedId()

        if group == Config.Group and LocalPlayer.state.isLoggedIn then
            if GetUsingseethrough(true) then
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** is flagged from anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Thermalvision)**")
                end
            end
        end
    end
end)

local function trim(plate)
    if not plate then return nil end
    return (string.gsub(plate, '^%s*(.-)%s*$', '%1'))
end

CreateThread(function() 	-- Spawned car --
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local player = PlayerId()
        local veh = GetVehiclePedIsIn(ped)
        local DriverSeat = GetPedInVehicleSeat(veh, -1)
        local plate = trim(GetVehicleNumberPlateText(veh))
        if LocalPlayer.state.isLoggedIn then
            if group == Config.Group then
                if IsPedInAnyVehicle(ped, true) then
                    for _, BlockedPlate in pairs(Config.BlacklistedPlates) do
                        if plate == BlockedPlate then
                            if DriverSeat == ped then
                                DeleteVehicle(veh)
                                TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Cheat detected!", "red", "** @everyone " ..GetPlayerName(player).. "** has been banned for cheating (Sat as driver in spawned vehicle with license plate **"..BlockedPlate..")**")
                                TriggerServerEvent("qb-anticheat:server:banPlayer", "Cheating")
                            end
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()	-- Check if ped has weapon in inventory --
    while true do
        Wait(5000)

        if LocalPlayer.state.isLoggedIn then

            local PlayerPed = PlayerPedId()
            local player = PlayerId()
            local CurrentWeapon = GetSelectedPedWeapon(PlayerPed)
            local WeaponInformation = QBCore.Shared.Weapons[CurrentWeapon]

            if WeaponInformation["name"] ~= "weapon_unarmed" then
                QBCore.Functions.TriggerCallback('qb-anticheat:server:HasWeaponInInventory', function(HasWeapon)
                    if not HasWeapon then
                        RemoveAllPedWeapons(PlayerPed, false)
                        TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Weapon removed!", "orange", "** @everyone " ..GetPlayerName(player).. "** had a weapon on them that they did not have in his inventory. QB Anticheat has removed the weapon.")
                    end
                end, WeaponInformation)
            end
        end
    end
end)

CreateThread(function() -- Max flags reached = ban, log, explosion & break --
    while true do
        Wait(500)
        local player = PlayerId()
        if flags >= Config.FlagsForBan then
            -- TriggerServerEvent("qb-anticheat:server:banPlayer", "Cheating")
            -- AddExplosion(coords, EXPLOSION_GRENADE, 1000.0, true, false, false, true)
            TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player banned! (Not really of course, this is a test duuuhhhh)", "red", "** @everyone " ..GetPlayerName(player).. "** Too often has been flagged by the anti-cheat and preemptively banned from the server")
            flags = 0
        end
    end
end)

RegisterNetEvent('qb-anticheat:client:NonRegisteredEventCalled', function(reason, CalledEvent)
    local player = PlayerId()
    TriggerServerEvent('qb-anticheat:server:banPlayer', reason)
    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player banned! (Not really of course, this is a test duuuhhhh)", "red", "** @everyone " ..GetPlayerName(player).. "** has event **"..CalledEvent.."tried to trigger (LUA injector!)")
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(5000)
        if Config.AntiGodMode.Check1 then
            if not IsPlayerDead(PlayerId()) then
                if GetPlayerInvincible_2(PlayerId()) then
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! GodMode", "red", "** @everyone " ..GetPlayerName(player).. "** Tried to use GodMode. (Method 1)")
                    flags = flags + 1
                end
            end
        end
        if Config.AntiGodMode.Check2 then
            if not IsPlayerDead(PlayerId()) then
                local bull, coll, steam, p7, dr = GetEntityProofs(PlayerPedId())
                if bull ~= 0 and coll ~= 0 and steam ~= 0 and p7 ~= 0 and dr ~= 0 then
                    TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! GodMode", "red", "** @everyone " ..GetPlayerName(player).. "** Tried to use GodMode. (Method 2)")
                    flags = flags + 1
                end
            end
        end
        if Config.AntiDUI then
            local duis = {
                {texturedict = "HydroMenu", texture = "HydroMenuHeader", name = "Hydro"},
                {texturedict = "John", texture = "John2", name = "Sugar"},
                {texturedict = "fm", texture = "menu_bg", name = "Fallout"},
                {texturedict = "MM", texture = "menu_bg", name="MetrixMethods Fallout"},
            }
            
            for i, duis in pairs(duis) do
                if duis.x and duis.y then
                    if GetTextureResolution(duis.texturedict, duis.texture).x == duis.x and GetTextureResolution(duis.texturedict, duis.texture).y == duis.y then
                        TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! Mod Menu injection", "red", "** @everyone " ..GetPlayerName(player).. "** tried to inject the following mod menu: **`"..duis.name.."`")
                        flags = flags + 1
                    end
                else 
                    if GetTextureResolution(duis.texturedict, duis.texture).x ~= 4.0 then
                        TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! Mod Menu injection", "red", "** @everyone " ..GetPlayerName(player).. "** tried to inject the following mod menu: **`"..duis.name.."`")
                        flags = flags + 1
                    end
                end
            end
        end

        if Config.AntiMenuStyles then
            if HasStreamedTextureDictLoaded('fm') or HasStreamedTextureDictLoaded('rampage_tr_main') or HasStreamedTextureDictLoaded('MenyooExtras') then
                TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! AntiMenuStyles injection", "red", "** @everyone " ..GetPlayerName(player).. "** tried to inject a menu with suspicious styles..")
                flags = flags + 1
            end
            if HasStreamedTextureDictLoaded('shopui_title_graphics_franklin') or HasStreamedTextureDictLoaded('deadline') then
                TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Player flagged! AntiMenuStyles injection", "red", "** @everyone " ..GetPlayerName(player).. "** tried to inject a menu with suspicious styles..")
                flags = flags + 1
            end
        end
    end
end)
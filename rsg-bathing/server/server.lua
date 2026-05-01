local RSGCore = exports['rsg-core']:GetCoreObject()
BathingSessions = {}

local webhook = Config.DiscordWebhook or 'YOUR_DISCORD_WEBHOOK_URL'

local function ParseIdentifiers(src)
    local identifiers = GetPlayerIdentifiers(src)
    local discordId, discordName = 'N/A', 'N/A'
    local steamId, steamName, steamProfile = 'N/A', GetPlayerName(src), 'N/A'

    for i = 1, #identifiers do
        local id = identifiers[i]
        if string.find(id, 'discord:') then
            discordId = string.sub(id, 9)
            discordName = '<@' .. discordId .. '>'
        elseif string.find(id, 'steam:') then
            steamId = id
            local steamHex = tonumber(steamId:gsub("steam:", ""), 16) or 0
            steamProfile = steamHex ~= 0 and string.format("https://steamcommunity.com/profiles/%d", steamHex) or "N/A"
        end
    end

    return discordId, discordName, steamId, steamName, steamProfile
end

local function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        return string.format('%.1f, %.1f, %.1f', coords.x, coords.y, coords.z)
    end
    return 'Unknown'
end

RegisterServerEvent('rsg-bathing:server:canEnterBath')
AddEventHandler('rsg-bathing:server:canEnterBath', function(town)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentMoney = Player.PlayerData.money['cash']

    if not BathingSessions[town] then
        if currentMoney >= Config.NormalBathPrice then
            Player.Functions.RemoveMoney('cash', Config.NormalBathPrice)
            BathingSessions[town] = src
            
            -- Adding Discord Logs 
            local discordId, discordName, steamId, steamName, steamProfile = ParseIdentifiers(src)
            local coords = GetPlayerCoords(src)

            local playerName = 'Unknown'
            if Player and Player.PlayerData.charinfo then
                playerName = (Player.PlayerData.charinfo.firstname or '') .. ' ' .. (Player.PlayerData.charinfo.lastname or '')
            end
            if playerName == '' then playerName = 'No Character' end

            local jobLabel = "Unknown"
            if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name then
                jobLabel  = Player.PlayerData.job.label
            end

            local citizenId = Player.PlayerData.citizenid or 'N/A'
            local serverId = tostring(src)  
            local profileLink = steamProfile ~= 'N/A' and ('[Click Here To View](' .. steamProfile .. ')') or 'N/A'

            local embed = {
                title = "Standard Bath Services",
                color = 3447003,  
                fields = {
                    { name = 'Player ID', value = tostring(serverId), inline = true },
                    { name = "Player Name", value=playerName, inline=true},
                    { name = 'CitizenID', value = citizenId, inline = true },
                    { name = 'Job', value = jobLabel, inline = true },
                    { name = 'Discord Name', value = discordName, inline = true },    
                    { name = 'Discord ID', value = discordId, inline = true },
                    { name = 'Steam Name', value = steamName, inline = true },
                    { name = 'Steam ID', value = steamId, inline = true },
                    { name = 'Steam Profile', value = profileLink, inline = false },
                    { name = 'Coordinates', value = coords, inline = true }
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")  
            }
            PerformHttpRequest(webhook, function() end, 'POST', json.encode({embeds={embed}}), {['Content-Type']='application/json'})
            -- End of Discord Logs

            Citizen.CreateThread(function()
                Citizen.Wait(Config.SessionTimeout or 600000)
                if BathingSessions[town] == src then
                    BathingSessions[town] = nil
                end
            end)
            
            TriggerClientEvent('rsg-bathing:client:StartBath', src, town)
        else
            TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_not_enough_money'), type = 'error', duration = 5000 })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_occupied'), type = 'error', duration = 5000 })
    end
end)

RegisterServerEvent('rsg-bathing:server:canEnterDeluxeBath')
AddEventHandler('rsg-bathing:server:canEnterDeluxeBath', function(animscene, town, cam)
    local src = source
    if not BathingSessions[town] == src then return end  -- Early exit if not owner
    
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end  -- Critical nil check
    
    local currentMoney = Player.PlayerData.money['cash']

    if currentMoney >= Config.DeluxeBathPrice then
        pcall(function()  -- Safe money removal
            Player.Functions.RemoveMoney('cash', Config.DeluxeBathPrice)
        end)
        
            -- Adding Discord Logs 
            local discordId, discordName, steamId, steamName, steamProfile = ParseIdentifiers(src)
            local coords = GetPlayerCoords(src)

            local playerName = 'Unknown'
            if Player and Player.PlayerData.charinfo then
                playerName = (Player.PlayerData.charinfo.firstname or '') .. ' ' .. (Player.PlayerData.charinfo.lastname or '')
            end
            if playerName == '' then playerName = 'No Character' end

            local jobLabel = "Unknown"
            if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name then
                jobLabel  = Player.PlayerData.job.label
            end

            local citizenId = Player.PlayerData.citizenid or 'N/A'
            local serverId = tostring(src)  
            local profileLink = steamProfile ~= 'N/A' and ('[Click Here To View](' .. steamProfile .. ')') or 'N/A'

            local embed = {
                title = "Deluxe Bath Services",
                color = 10181046,  
                fields = {
                    { name = 'Player ID', value = tostring(serverId), inline = true },
                    { name = 'Player Name', value = playerName, inline = true },
                    { name = 'Job', value = jobLabel, inline = true },
                    { name = 'CitizenID', value = citizenId, inline = true },
                    { name = 'Discord Name', value = discordName, inline = true },
                    { name = 'Discord ID', value = discordId, inline = true },
                    { name = 'Steam Name', value = steamName, inline = true },    
                    { name = 'Steam ID', value = steamId, inline = true },
                    { name = 'Steam Profile', value = profileLink, inline = false },
                    { name = 'Coordinates', value = coords, inline = true }
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")  
            }
            PerformHttpRequest(webhook, function() end, 'POST', json.encode({embeds={embed}}), {['Content-Type']='application/json'})
            -- End of Discord Logs

        Citizen.CreateThread(function()
            Citizen.Wait(Config.SessionTimeout or 600000)
            if BathingSessions[town] == src then
                BathingSessions[town] = nil
            end
        end)
        
        TriggerClientEvent('rsg-bathing:client:StartDeluxeBath', src, animscene, town, cam)
    else
        TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_not_enough_money'), type = 'error', duration = 5000 })
        TriggerClientEvent('rsg-bathing:client:HideDeluxePrompt', src)
    end
end)

RegisterServerEvent('rsg-bathing:server:setBathAsFree')
AddEventHandler('rsg-bathing:server:setBathAsFree', function(town)
    if BathingSessions[town] == source then
        BathingSessions[town] = nil
    end
end)

AddEventHandler('playerDropped', function()
    for town, player in pairs(BathingSessions) do
        if player == source then
            BathingSessions[town] = nil
        end
    end
end)
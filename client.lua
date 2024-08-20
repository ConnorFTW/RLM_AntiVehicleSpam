-- vehicleTracker.lua

local vehicleSpawnCount = {}
local lastSpawnTime = {}
local lastVehicle = {}
local playerVehicles = {} -- Table to store all vehicles spawned by each player

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Frequent checks for better responsiveness

        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)

        if currentVehicle ~= 0 and IsPedInAnyVehicle(playerPed, true) then
            local playerId = PlayerId()
            local serverId = GetPlayerServerId(playerId)
            local playerName = GetPlayerName(playerId)
            local currentTime = GetGameTimer()

            -- Initialize the spawn count, last spawn time, and last vehicle for this player if not set
            if vehicleSpawnCount[playerId] == nil then
                vehicleSpawnCount[playerId] = 0
                lastSpawnTime[playerId] = currentTime
                lastVehicle[playerId] = nil
                playerVehicles[playerId] = {} -- Initialize vehicle table for this player
            end

            -- Check if enough time has passed to reset the spawn count
            if currentTime - lastSpawnTime[playerId] > Config.ResetTime * 1000 then
                vehicleSpawnCount[playerId] = 0
                lastVehicle[playerId] = nil
                playerVehicles[playerId] = {} -- Reset tracked vehicles
            end

            -- Only increment the counter if the player has entered a new vehicle
            if currentVehicle ~= lastVehicle[playerId] then
                vehicleSpawnCount[playerId] = vehicleSpawnCount[playerId] + 1
                lastVehicle[playerId] = currentVehicle
                lastSpawnTime[playerId] = currentTime

                -- Track the vehicle
                table.insert(playerVehicles[playerId], currentVehicle)
            end

            -- Check if the player has spawned more vehicles than allowed in the config
            if vehicleSpawnCount[playerId] > Config.MaxVehicles then
                if Config.Punishment == "kick" then
                    -- Kick the player
                    TriggerServerEvent('vehicleTracker:kickPlayer', serverId)
                    -- Send a log to the webhook
                    TriggerServerEvent('vehicleTracker:sendWebhook', "Player Kicked", playerName .. " was kicked for spawning more than " .. Config.MaxVehicles .. " vehicles.", "Vehicle Tracker System")
                elseif Config.Punishment == "warn" then
                    -- Format the custom warning message
                    local warningMessage = Config.WarnMessage:gsub("{maxVehicles}", Config.MaxVehicles):gsub("{resetTime}", Config.ResetTime)

                    -- Send a chat notification to the player
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"[SYSTEM]", warningMessage}
                    })

                    -- Send a log to the webhook
                    TriggerServerEvent('vehicleTracker:sendWebhook', "Player Warned", playerName .. " was warned for spawning more than " .. Config.MaxVehicles .. " vehicles.", "Vehicle Tracker System")
                end

                -- Delete all vehicles spawned by the player
                for _, vehicle in ipairs(playerVehicles[playerId]) do
                    if DoesEntityExist(vehicle) then
                        DeleteEntity(vehicle)
                    end
                end

                -- Send a log to the webhook about vehicle deletion
                TriggerServerEvent('vehicleTracker:sendWebhook', "Vehicles Deleted", "All vehicles spawned by " .. playerName .. " were deleted.", "Vehicle Tracker System")

                -- Reset the count and tracked vehicles after triggering the punishment
                vehicleSpawnCount[playerId] = 0
                lastVehicle[playerId] = nil
                playerVehicles[playerId] = {}
            end
        end
    end
end)

-- Command to reset vehicle count manually (optional)
RegisterCommand("resetvehiclecount", function()
    local playerId = PlayerId()
    vehicleSpawnCount[playerId] = 0
    lastVehicle[playerId] = nil
    playerVehicles[playerId] = {}
    print("Vehicle spawn count reset for " .. GetPlayerName(playerId))
end, false)

-- Handle the kick on the server side
RegisterNetEvent('vehicleTracker:kickPlayer')
AddEventHandler('vehicleTracker:kickPlayer', function(serverId)
    DropPlayer(serverId, "You have been kicked for spawning too many vehicles.")
end)

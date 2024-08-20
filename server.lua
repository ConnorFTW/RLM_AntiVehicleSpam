-- server.lua

function sendToDisc(title, message, footer)
    local embed = {
        {
            ["color"] = 16711680, -- Red color
            ["title"] = "**" .. title .. "**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }

    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err == 204 then
            print("Webhook sent successfully.") -- Debugging message
        else
            print("Failed to send webhook. Status code: " .. (err or "nil") .. " | Response: " .. text)
        end
    end, 'POST', json.encode({
        username = "Vehicle Tracker",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('vehicleTracker:sendWebhook')
AddEventHandler('vehicleTracker:sendWebhook', function(title, message, footer)
    sendToDisc(title, message, footer)
end)

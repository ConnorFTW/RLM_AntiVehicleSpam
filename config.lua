-- Configuration file

Config = {}

-- Set the maximum number of vehicles a player can spawn before triggering the warning or punishment
Config.MaxVehicles = 5

-- Set the time window in seconds before the counter resets
Config.ResetTime = 15 -- Example: 60 seconds

-- Set the punishment type: "kick" or "warn"
Config.Punishment = "warn" -- Options: "kick", "warn"

-- Set the custom warning message (with placeholders)
Config.WarnMessage = "You have spawned more than {maxVehicles} vehicles within {resetTime} seconds!"

-- Set the webhook URL to send logs
Config.WebhookURL = "https://discord.com/api/webhooks/955166186436440145/r-EElpm2-8Pci--SdGD-MmdRFg7SLTwMny1pfwk3Yba7vA_YIA34nxXLdBzVoYOhgBr2"

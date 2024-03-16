local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Cmdr = require(ServerStorage.serverPackages.cmdr)

local cmdrService = {}

function cmdrService.start()
    Cmdr:RegisterHooksIn(script.Parent.Parent.cmdrHooks)
    Cmdr:RegisterCommandsIn(script.Parent.Parent.cmdrCommands)

    MessagingService:SubscribeAsync("Ban", function(banInfo: {Id: number, Reason: string})
        local playerLocated = Players:GetPlayerByUserId(banInfo.Id)
        if playerLocated then
            playerLocated:Kick(banInfo.Reason)
        end
    end)
end

return cmdrService
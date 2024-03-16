local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local playerDataService = require(script.Parent.Parent.services.playerDataService)

return function(_, player: Player | number, reason)
	if type(player) == "number" then
        MessagingService:PublishAsync("Ban", {Id = player, Reason = reason})
        local profile = playerDataService.ProfileStore:LoadProfileAsync(`Player_{player}`, "Steal")
        profile.Data.BanInfo.IsBanned = true
        profile.Data.BanReason = reason
        profile:Release()
        return `Pbanned {Players:GetNameFromUserIdAsync(player)}`
    else
        playerDataService.updateProfile(player, {
            BanInfo = {
                IsBanned = true,
                BanReason = reason
            }
        })
        player:Kick(reason)
        return `Pbanned {player.Name}`
	end

end

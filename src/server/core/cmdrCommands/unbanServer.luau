local Players = game:GetService("Players")

local playerDataService = require(script.Parent.Parent.services.playerDataService)

return function(_, userid: number)
    local profile = playerDataService.ProfileStore:LoadProfileAsync(`Player_{userid}`)
    profile.Data.BanInfo.IsBanned = false
    profile.Data.BanReason = ""
    profile:Release()
    return `Unbanned {Players:GetNameFromUserIdAsync(userid)}`
end

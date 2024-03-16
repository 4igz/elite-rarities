local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local playerDataService = require(script.Parent.playerDataService)

local timePlayedService = {}

local TIME_PLAYED_UNIT = 60 -- 1 per minute

function timePlayedService.start()
	local lastTimeForPlayer = {}
	RunService.Heartbeat:Connect(function()
		for _, player in Players:GetPlayers() do
			local now = tick()
			if now < (lastTimeForPlayer[player] or 0) + TIME_PLAYED_UNIT then
				return
			end
			lastTimeForPlayer[player] = now
			local profile = playerDataService.getProfile(player)
			if not profile then
				return
			end
			profile.Data.TimePlayed += 1
			playerDataService.setProfile(player, profile)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if lastTimeForPlayer[player] then
			lastTimeForPlayer[player] = nil
		end
	end)
end

return timePlayedService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local numberUtil = require(shared.utilities.numberUtil)
local playerDataService = require(script.Parent.playerDataService)
local rarityConfig = require(shared.configuations.rarityConfig)

local leaderstatService = {}

function leaderstatService.start()
	Players.PlayerAdded:Connect(function(player)
		local ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player

		local rebirths = Instance.new("StringValue")
		rebirths.Name = "Rebirths"
		rebirths.Parent = ls
		local luck = Instance.new("StringValue")
		luck.Name = "Luck"
		luck.Parent = ls
		local rarity = Instance.new("StringValue")
		rarity.Name = "Rarity"
		rarity.Parent = ls

		local profile = playerDataService.waitForProfile(player)
		if not profile then
			return
		end

		rebirths.Value = profile.Data.Rebirth
		luck.Value = numberUtil.simplifyNumber(profile.Data.Luck)
		if profile.Data.CurrentRarity > 0 then
			rarity.Value = rarityConfig[profile.Data.CurrentRarity].rarityName
		else
			rarity.Value = "None"
		end
	end)

	playerDataService.profileChanged:Connect(function(player, newProfile)
		local ls = player.leaderstats

		local rebirths = ls.Rebirths
		local luck = ls.Luck
		local rarity = ls.Rarity

		rebirths.Value = newProfile.Data.Rebirth
		luck.Value = numberUtil.simplifyNumber(newProfile.Data.Luck)
		if newProfile.Data.CurrentRarity > 0 then
			rarity.Value = rarityConfig[newProfile.Data.CurrentRarity].rarityName
		else
			rarity.Value = "None"
		end
	end)
end

return leaderstatService

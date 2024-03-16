local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local Zone = require(sharedPackages.Zone)
local monetizationUtil = require(shared.utilities.monetizationUtil)
local playerDataService = require(script.Parent.Parent.services.playerDataService)
local rarityConfig = require(shared.configuations.rarityConfig)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local sharedInfo = require(shared.sharedInfo)

local RebirthArea = Component.new({
	tag = "RebirthArea",
	extensions = { remoteComponentExtension },
	client = {},
})

function RebirthArea:construct()
	local zone = Zone.new(self.instance)

	zone.playerEntered:Connect(function(player: Player)
		local profile = playerDataService.getProfile(player)
		if not profile then
			return
		end
		if
			profile.Data.CurrentRarity
			>= math.min(sharedInfo.BaseRebirthRarity + profile.Data.Rebirth, #rarityConfig)
		then
			local rebirthsToAdd = 1
			monetizationUtil
				.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["2x Rebirth"])
				:andThen(function(owns)
					if owns then
						rebirthsToAdd += 1
					end
				end)
			profile.Data.Rebirth += rebirthsToAdd
			profile.Data.CurrentRarity = 0
			table.clear(profile.Data.CollectedRarities)
			profile.Data.Luck = 2
		end
		playerDataService.setProfile(player, profile)
	end)
end

return RebirthArea

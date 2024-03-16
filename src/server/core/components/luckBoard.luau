local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local services = ServerStorage.server.services
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local monetizationUtil = require(shared.utilities.monetizationUtil)
local playerDataService = require(services.playerDataService)
local rarityConfig = require(shared.configuations.rarityConfig)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local sharedInfo = require(shared.sharedInfo)

local LuckBoard = Component.new({
	tag = "LuckBoard",
	extensions = { remoteComponentExtension },
	client = {},
})

function LuckBoard:construct() end

function LuckBoard.client.getLuck(player: Player)
	local profile = playerDataService.getProfile(player)
	if not profile then
		return 0
	end
	if profile.Data.CurrentRarity == 0 then
		return 0
	end
	if #profile.Data.CollectedRarities == 0 then
		return 0
	end
	local totalLuckReturn = 0
	for _, i in profile.Data.CollectedRarities do
		totalLuckReturn += rarityConfig[i].luckReturn
	end
	local luckGamepassMod = 1
	monetizationUtil
		.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["2x Luck"])
		:andThen(function(owns)
			if owns then
				luckGamepassMod *= 2
			end
		end)
	monetizationUtil
		.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["3x Luck"])
		:andThen(function(owns)
			if owns then
				luckGamepassMod *= 3
			end
		end)
	local mod = luckGamepassMod * math.max(profile.Data.Rebirth * 2, 1)
	if profile.Data.InGroup then
		mod *= 1.25
	end
	return totalLuckReturn * math.max(mod, 1)
end

function LuckBoard:stop()
	self._trove:Destroy()
end

return LuckBoard

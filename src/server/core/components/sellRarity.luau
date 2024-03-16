local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared
local services = ServerStorage.server.services

local Component = require(sharedPackages.Component)
local Zone = require(sharedPackages.Zone)
local monetizationUtil = require(shared.utilities.monetizationUtil)
local playerDataService = require(services.playerDataService)
local rarityConfig = require(shared.configuations.rarityConfig)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local rollService = require(services.rollService)
local sharedInfo = require(shared.sharedInfo)
local network = require(sharedPackages.network)

local SellRarity = Component.new({
	tag = "SellArea",
	extensions = { remoteComponentExtension },
	client = {
		soldRarity = network.Server.RemoteSignal.new()
	},
})

function SellRarity:construct()
	local zone = Zone.new(self.instance)

	zone.playerEntered:Connect(function(player: Player)
		local profile = playerDataService.getProfile(player)
		if not profile then
			return
		end
		if profile.Data.CurrentRarity == 0 then
			-- TODO: Notify client they have no rarity to sell.
			return
		end
		if #profile.Data.CollectedRarities == 0 then
			return
		end
		local totalLuckReturn = 0
		for _, i in profile.Data.CollectedRarities do
			totalLuckReturn += rarityConfig[i].luckReturn
		end
		local luckMod = 1
		monetizationUtil
			.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["2x Luck"])
			:andThen(function(owns)
				if owns then
					luckMod *= 2
				end
			end)
		monetizationUtil
			.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["3x Luck"])
			:andThen(function(owns)
				if owns then
					luckMod *= 3
				end
			end)
		if profile.Data.InGroup then
			luckMod *= 1.25
		end
		local rebirthMod = profile.Data.Rebirth * 2
		profile.Data.Luck += (totalLuckReturn * luckMod) * math.max(rebirthMod, 1)
		profile.Data.CurrentRarity = 0
		profile.Data.RaritiesSold += 1
		SellRarity.client.soldRarity:fireClient(player)
		rollService.client.rarityUpdated:fireClient(player, 0)
		rollService.client.rolledRarity:fireClient(player, 0)
		table.clear(profile.Data.CollectedRarities)
		playerDataService.setProfile(player, profile)
	end)
end

return SellRarity

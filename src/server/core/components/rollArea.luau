local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local sharedPackages = ReplicatedStorage.sharedPackages
local services = script.Parent.Parent.services
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local Zone = require(sharedPackages.Zone)
local playerDataService = require(services.playerDataService)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local rollService = require(services.rollService)

local RollArea = Component.new({
	tag = "RollArea",
	extensions = { remoteComponentExtension },
	client = {},
})

function RollArea:construct()
	self.lastRollForPlayer = {}
	self.players = {}
	local rollingArea = self.instance

	local zone = Zone.new(rollingArea)

	zone.playerEntered:Connect(function(player: Player)
		table.insert(self.players, player)
	end)

	zone.playerExited:Connect(function(player: Player)
		local foundIdx = table.find(self.players, player)
		if foundIdx then
			table.remove(self.players, foundIdx)
		end
	end)

	self.zone = zone
end

function RollArea:start()
	RunService.Heartbeat:Connect(function()
		for _, player: Player in self.players do
			local profile = playerDataService.getProfile(player)
			if not profile then
				return
			end
			local rollCooldown = 2
			local now = tick()
			if profile.Data.DoubleRollspeed then
				rollCooldown /= 2
			end
			if now < (self.lastRollForPlayer[player] or 0) + rollCooldown then
				return
			end
			self.lastRollForPlayer[player] = now
			local char = player.Character
			if not (char and char.Parent) then
				return
			end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end
			local luck = profile.Data.Luck
			local rolledIdx = rollService.rollRarity(luck)
			table.insert(profile.Data.CollectedRarities, rolledIdx)
			rollService.client.rolledRarity:fireClient(player, rolledIdx)
			if rolledIdx > profile.Data.CurrentRarity then
				profile.Data.CurrentRarity = rolledIdx
				playerDataService.setProfile(player, profile)
				rollService.client.rarityUpdated:fireClient(player, rolledIdx)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if self.lastRollForPlayer[player] then
			self.lastRollForPlayer[player] = nil
		end
		if self.players[player] then
			self.players[player] = nil
		end
	end)
end

return RollArea

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local services = ServerStorage.server.services
local shared = ReplicatedStorage.shared
local assets = ServerStorage.assets
local overheadGui = assets.OverheadGui

local playerDataService = require(services.playerDataService)
local rarityConfig = require(shared.configuations.rarityConfig)
local sharedInfo = require(shared.sharedInfo)

local overheadService = {}

function overheadService.start()
	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function(character)
			local hrp = character:WaitForChild("HumanoidRootPart")
			if not hrp then
				return
			end
			local profile = playerDataService.waitForProfile(player)
			local currentRarity = profile.Data.CurrentRarity
			local rebirth = profile.Data.Rebirth
			local ohClone = overheadGui:Clone()
			if rebirth > 0 then
				local rebirthLabel = ohClone.Rebirth
				rebirthLabel.Visible = true
				rebirthLabel.Text = `Rebirth: {rebirth}`
				local rarityIdx = math.min(sharedInfo.BaseRebirthRarity + rebirth, #rarityConfig)
				rebirthLabel.TextColor3 = rarityConfig[rarityIdx].color
			end
			if currentRarity > 0 then
				local rarityLabel = ohClone.Rarity
				local rarityInfo = rarityConfig[currentRarity]
				rarityLabel.Text = rarityInfo.rarityName
				rarityLabel.TextColor3 = rarityInfo.color
			end
			ohClone.Parent = hrp
		end)
	end)

	playerDataService.profileChanged:Connect(
		function(player, newProfile: playerDataService.PlayerProfile)
			local character = player.Character
			if not character then
				return
			end
			local hrp = character:WaitForChild("HumanoidRootPart")
			if not hrp then
				return
			end
			local currentRarity = newProfile.Data.CurrentRarity
			local rebirth = newProfile.Data.Rebirth
			local gui = hrp:FindFirstChild("OverheadGui")
			if not gui then
				return
			end
			if rebirth > 0 then
				local rebirthLabel: TextLabel = gui.Rebirth
				rebirthLabel.Visible = true
				rebirthLabel.Text = `Rebirth: {rebirth}`
				local rarityIdx = math.min(sharedInfo.BaseRebirthRarity + rebirth, #rarityConfig)
				rebirthLabel.TextColor3 = rarityConfig[rarityIdx].color
			end
			if currentRarity > 0 then
				local rarityLabel: TextLabel = gui.Rarity
				local rarityInfo = rarityConfig[currentRarity]
				rarityLabel.Text = rarityInfo.rarityName
				rarityLabel.TextColor3 = rarityInfo.color
			else
				local rarityLabel: TextLabel = gui.Rarity
				rarityLabel.Text = "No Rarity"
				rarityLabel.TextColor3 = Color3.new(1, 1, 1)
			end
		end
	)
end

return overheadService

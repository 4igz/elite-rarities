local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local numberUtil = require(shared.utilities.numberUtil)
local rarityConfig = require(shared.configuations.rarityConfig)
local rollBoardGuiComponent = require(script.Parent.rollBoardGui)
local serviceUtil = require(shared.utilities.serviceUtil)

local playerDataService = serviceUtil.service("playerDataService")

local RarityDisplay = Component.new({
	tag = "RarityDisplay",
	extensions = {},
	requiredServerComponents = {},
})

function RarityDisplay:construct()
	local relativeRaritySelector: TextButton = self.instance:WaitForChild("RelativeRarity")
	local baseRaritySelector: TextButton = self.instance:WaitForChild("BaseRarity")

	local selected = "Base"

	relativeRaritySelector.MouseButton1Click:Connect(function()
		if selected ~= "Relative" then
			selected = "Relative"
			baseRaritySelector.BackgroundColor3 = Color3.fromRGB(100, 0, 50)
			relativeRaritySelector.BackgroundColor3 = Color3.fromRGB(5, 100, 0)
		else
			return
		end

		self:updateRelative()
	end)

	baseRaritySelector.MouseButton1Click:Connect(function()
		if selected ~= "Base" then
			selected = "Base"
			baseRaritySelector.BackgroundColor3 = Color3.fromRGB(5, 100, 0)
			relativeRaritySelector.BackgroundColor3 = Color3.fromRGB(100, 0, 50)
		else
			return
		end
		for _, guiComponent in rollBoardGuiComponent:all() do
			local rarityLabels =
				guiComponent.server.RollBoardGui:getRarityLabels(guiComponent.instance)

			for i, label in rarityLabels do
				local rarityInfo = rarityConfig[i]
				local baseChance =
					`{rarityInfo.rarityName}: 1 / {numberUtil.simplifyNumber(rarityInfo.chance)}`
				label.Text = baseChance
			end
		end
	end)

	playerDataService.profileChanged:connect(function(_)
		if selected ~= "Relative" then
			return
		end
		self:updateRelative()
	end)
end

function RarityDisplay:updateRelative()
	for _, guiComponent in rollBoardGuiComponent:all() do
		local playerLuck = playerDataService.getLuck()
		local rarityLabels = guiComponent.server.RollBoardGui:getRarityLabels(guiComponent.instance)

		for i, label in rarityLabels do
			local rarityInfo = rarityConfig[i]
			local relativeChance = `{rarityInfo.rarityName}: 1 / {numberUtil.simplifyNumber(
				rarityInfo.chance / playerLuck
			)}`
			label.Text = relativeChance
		end
	end
end

return RarityDisplay

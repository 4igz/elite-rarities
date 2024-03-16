local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local numberUtil = require(shared.utilities.numberUtil)
local rarityConfig = require(shared.configuations.rarityConfig)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)

local RollBoardGui = Component.new({
	tag = "RollBoardGui",
	extensions = { remoteComponentExtension },
	client = {},
})

function RollBoardGui:construct()
	local surfaceGui = self.instance
	local scrollingFrame: ScrollingFrame = surfaceGui.ScrollingFrame
	local templates = surfaceGui.Templates
	local title: TextLabel = templates.Title
	self.rarityLabels = {}

	for i, rarityInfo in rarityConfig do
		local newTitle = title:Clone()
		newTitle.LayoutOrder = i
		newTitle.BackgroundColor3 = rarityInfo.color
		newTitle.Visible = true
		newTitle.Text =
			`{rarityInfo.rarityName} - 1 / {numberUtil.simplifyNumber(rarityInfo.chance)}`
		newTitle.Parent = scrollingFrame
		table.insert(self.rarityLabels, newTitle)
	end
end

function RollBoardGui.client.getRarityLabels(_player: Player, instance: ScreenGui)
	local hasComponent
	for _, component in RollBoardGui:all() do
		if component.instance == instance then
			hasComponent = component
		end
	end
	return hasComponent.rarityLabels
end

return RollBoardGui

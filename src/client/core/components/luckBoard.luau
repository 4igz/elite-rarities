local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local luckTextLabel = playerGui:WaitForChild("MainUi"):WaitForChild("LuckLabel")
local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local numberUtil = require(shared.utilities.numberUtil)
local serviceUtil = require(shared.utilities.serviceUtil)

local playerDataService = serviceUtil.service("playerDataService")
local rollService = serviceUtil.service("rollService")

local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)

local LuckBoard = Component.new({
	tag = "LuckBoard",
	extensions = { remoteComponentExtension },
	requiredServerComponents = { "LuckBoard" },
})

function LuckBoard:start()
	local luckBoardLabel: TextLabel = self.instance.LuckDisplay
	luckTextLabel.Text = string.format(
		"🍀 Luck: x%s",
		numberUtil.simplifyNumber(playerDataService.getLuck(localPlayer))
	)
	luckBoardLabel.Text = `+{numberUtil.simplifyNumber(self.server.LuckBoard.getLuck())} Luck`
	rollService.rolledRarity:connect(function(_rollIdx: number)
		luckBoardLabel.Text = `+{numberUtil.simplifyNumber(self.server.LuckBoard.getLuck())} Luck`
	end)
	playerDataService.profileChanged:connect(function(newProfile)
		luckTextLabel.Text =
			string.format("🍀 Luck: x%s", numberUtil.simplifyNumber(newProfile.Luck))
	end)
end

return LuckBoard

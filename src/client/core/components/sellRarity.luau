local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mainUi = playerGui:WaitForChild("MainUi")
local rollFrame = mainUi:WaitForChild("RollFrame")
local rollLabel: TextLabel = rollFrame:WaitForChild("RollLabel")
local luckTextLabel = mainUi:WaitForChild("LuckLabel")
local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local Trove = require(sharedPackages.Trove)
local rarityConfig = require(shared.configuations.rarityConfig)
local serviceUtil = require(shared.utilities.serviceUtil)

local rollService = serviceUtil.service("rollService")

local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true)
local rng = Random.new()

local SellRarity = Component.new({
	tag = "SellArea",
	extensions = { remoteComponentExtension },
	requiredServerComponents = { "SellArea" },
})

function SellRarity:construct()
	self._trove = Trove.new()
end

function SellRarity:start()
	rollService.rolledRarity:connect(function(rarityIdx: number)
		if rarityIdx == 0 then
			return
		end
		local rarityInfo = rarityConfig[rarityIdx]
		local clr = rarityInfo.color
		rollLabel.Text =
			`You rolled <font color="rgb({math.floor(clr.R * 255)},{math.floor(clr.G * 255)},{math.floor(clr.B * 255)})">{rarityInfo.rarityName}</font>`
		rollFrame.Visible = true
		local roll = rng:NextInteger(0, 1)
		local tween =
			TweenService:Create(rollFrame, tweenInfo, { Rotation = if roll == 1 then 10 else -10 })
		tween.Completed:Connect(function()
			rollFrame.Rotation = 0
			task.wait(0.5)
			rollFrame.Visible = false
			tween:Destroy()
		end)
		tween:Play()
	end)
	self.server.SellArea.soldRarity:connect(function()
		local roll = rng:NextInteger(0, 1)
		local tween =
			TweenService:Create(luckTextLabel, tweenInfo, { Rotation = if roll == 1 then 10 else -10 })
		tween.Completed:Connect(function()
			luckTextLabel.Rotation = 0
			tween:Destroy()
		end)
		tween:Play()
	end)
end

return SellRarity

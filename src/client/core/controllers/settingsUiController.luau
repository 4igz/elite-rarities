local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mainUi = playerGui:WaitForChild("MainUi")
local settingsMenu = mainUi:WaitForChild("Menus"):WaitForChild("SettingsMenu")
local templates = settingsMenu:WaitForChild("Templates")
local iframe = settingsMenu:WaitForChild("ScrollingFrame")
local settingsButton = mainUi:WaitForChild("Buttons"):WaitForChild("Settings")

local shared = ReplicatedStorage.shared

local serviceUtil = require(shared.utilities.serviceUtil)
local uiController = require(script.Parent.uiController)

local playerDataService = serviceUtil.service("playerDataService")

type ButtonInfo = {
	type: string,
	imageId: number,
	stateName: string,

	-- Toggle type
	enabledText: string,
	disabledText: string,
	toggled: (Frame, boolean) -> (),
}

local settingsUiController = {}
local savedAccessories: { [Player]: { Accessory } } = {}

local function hideCharacter(player)
	local character = player.Character or player.CharacterAdded:Wait()
	if not character then
		return
	end
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	savedAccessories[player] = {}
	for _, accessory in humanoid:GetAccessories() do
		table.insert(savedAccessories[player], accessory:Clone())
	end
	humanoid:RemoveAccessories()
	for _, part: BasePart in character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end
		if part.Name == "HumanoidRootPart" then
			local oh = part:FindFirstChild("OverheadGui")
			oh.Enabled = false
			continue
		end
		part.Transparency = 1
	end
end

local function showCharacter(player)
	local character = player.Character or player.CharacterAdded:Wait()
	if not character then
		return
	end
	if savedAccessories[player] then
		local humanoid: Humanoid = character:WaitForChild("Humanoid")
		for _, accessory in savedAccessories[player] do
			humanoid:AddAccessory(accessory)
		end
		savedAccessories[player] = nil
	end
	for _, part: BasePart in character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end
		if part.Name == "HumanoidRootPart" then
			local oh = part:FindFirstChild("OverheadGui")
			oh.Enabled = true
			continue
		end
		part.Transparency = 0
	end
end

local function doToggle(toggleButton, info, enabled)
	if enabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(62, 204, 62)
		toggleButton.UIStroke.Color = Color3.new(0, 1, 0)
		toggleButton.Text = info.enabledText
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(172, 42, 42)
		toggleButton.UIStroke.Color = Color3.new(1, 0, 0)
		toggleButton.Text = info.disabledText
	end
end

local hidePlayers = false

local BUTTONS: { [string]: ButtonInfo } = {
	{
		type = "Toggle",
		imageId = 2243841635,
		enabledText = "Show Players",
		disabledText = "Hide Players",
		stateName = "OtherPlayersHidden",
		toggled = function(toggleFrame: Frame, enabled)
			hidePlayers = enabled
			for _, player in Players:GetPlayers() do
				if player == localPlayer then
					continue
				end
				if enabled then
					hideCharacter(player)
				else
					showCharacter(player)
				end
			end
			if enabled then
				toggleFrame.Icon.ImageColor3 = Color3.new(1, 0, 0)
			else
				toggleFrame.Icon.ImageColor3 = Color3.new(1, 1, 1)
				table.clear(savedAccessories)
			end
		end,
	},
	{
		type = "Toggle",
		imageId = 172648703,
		enabledText = "Disable Music",
		disabledText = "Enable Music",
		stateName = "MusicEnabled",
		toggled = function(toggleFrame: Frame, enabled)
			if enabled then
				workspace.Sound.Playing = true
				toggleFrame.Icon.Image = `rbxassetid://172648700`
			else
				workspace.Sound.Playing = false
				toggleFrame.Icon.Image = `rbxassetid://172649152`
			end
		end,
	},
}

function settingsUiController.start()
	local playerSettings = playerDataService.getSettings()
	hidePlayers = playerSettings["OtherPlayersHidden"]

	for i, buttonInfo in BUTTONS do
		if buttonInfo.type == "Toggle" then
			local toggleFrame = templates.Toggle:Clone()
			local toggleButton = toggleFrame.Toggle
			toggleFrame.LayoutOrder = i
			toggleFrame.Icon.Image = `rbxassetid://{buttonInfo.imageId}`
			local state = playerSettings[buttonInfo.stateName]
			buttonInfo.toggled(toggleFrame, state)
			doToggle(toggleButton, buttonInfo, state)
			toggleFrame.Visible = true
			toggleFrame.Parent = iframe

			toggleButton.MouseButton1Click:Connect(function()
				state = not state
				doToggle(toggleButton, buttonInfo, state)
				buttonInfo.toggled(toggleFrame, state)
				playerSettings[buttonInfo.stateName] = state
				playerDataService.updateSettings(playerSettings)
			end)
		end
	end

	for _, player in Players:GetPlayers() do
		player.CharacterAdded:Connect(function()
			if hidePlayers then
				hideCharacter(player)
			end
		end)
	end

	settingsButton.MouseButton1Click:Connect(function()
		uiController.toggle("SettingsMenu")
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function()
			if hidePlayers then
				hideCharacter(player)
			end
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if savedAccessories[player] then
			savedAccessories[player] = nil
		end
	end)
end

return settingsUiController

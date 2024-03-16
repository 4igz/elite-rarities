local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local numberUtil = require(shared.utilities.numberUtil)
local playerDataService = require(script.Parent.Parent.services.playerDataService)

local LB_DISPLAY_NUM = 25

local Leaderboard = Component.new({
	tag = "Leaderboard",
	extensions = {},
	client = {},
})

function Leaderboard:construct()
	self.trackedStat = self.instance:GetAttribute("TrackedStat")
	self.dataStore = DataStoreService:GetOrderedDataStore(self.trackedStat)
	self.gui = self.instance
	self.info = self.gui.Templates.Info
	self.scrollingFrame = self.gui:WaitForChild("ScrollingFrame")
	self.ui = self.scrollingFrame:WaitForChild("UI")
	self.header = self.gui.Header

	self.header.TrackedValue.Text = self.trackedStat

	while true do
		self:update()
		task.wait(120)
	end
end

function Leaderboard:update()
	for _, player in Players:GetPlayers() do
		if player.UserId > 0 then
			local profile = playerDataService.getProfile(player)
			if not profile then
				continue
			end
			pcall(function()
				--Wrap in a pcall so if Roblox is down, it won't error and break.
				self.dataStore:UpdateAsync(player.UserId, function(_)
					if not profile.Data[self.trackedStat] then
						error(`{self.trackedStat} does not exist in our profiles!`)
					end
					return profile.Data[self.trackedStat]
				end)
			end)
		end
	end
	local minValue = 1
	local maxValue = 10e99
	local pages = self.dataStore:GetSortedAsync(false, LB_DISPLAY_NUM, minValue, maxValue)
	local top = pages:GetCurrentPage()
	local list = {}
	for _, entry in top do
		local userId = entry.key
		local stat = numberUtil.simplifyNumber(entry.value)
		local username = "[Failed To Load]"
		local success, err = pcall(function()
			username = Players:GetNameFromUserIdAsync(userId)
		end)
		if not success then
			warn("Error getting name for " .. userId .. ". Error: " .. err)
		end
		local image = Players:GetUserThumbnailAsync(
			userId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size150x150
		)
		table.insert(list, { username, stat, image })
	end
	self.ui.Parent = script -- Save list layout
	self.scrollingFrame:ClearAllChildren() --Remove old frames
	self.ui.Parent = self.scrollingFrame
	for i, info in pairs(list) do
		local name = info[1]
		local val = info[2]
		local image = info[3]
		local color = Color3.new(1, 1, 1)
		if i == 1 then
			color = Color3.new(1, 1, 0) --1st place color
		elseif i == 2 then
			color = Color3.new(0.9, 0.9, 0.9) --2nd place color
		elseif i == 3 then
			color = Color3.fromRGB(166, 112, 0) --3rd place color
		end
		local new = self.info:Clone()
		new.Name = name
		new.LayoutOrder = i
		new.Image.Image = image
		new.Image.Place.Text = i
		new.Image.Place.TextColor3 = color
		new.Username.Text = name
		new.Username.TextColor3 = color
		new.Value.Text = val
		new.Value.TextColor3 = color
		new.Visible = true
		new.Parent = self.scrollingFrame
	end
	task.wait()
	self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.ui.AbsoluteContentSize.Y)
end

return Leaderboard

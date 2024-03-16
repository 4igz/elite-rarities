local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Signal = require(sharedPackages.Signal)
local monetizationUtil = require(shared.utilities.monetizationUtil)
local network = require(sharedPackages.network)
local sharedInfo = require(shared.sharedInfo)
local sift = require(sharedPackages.Sift)

local playerDataService = {
	client = {
		profileChanged = network.Server.RemoteSignal.new(),
	},
}
playerDataService.profileChanged = Signal.new()

local RETRY_DELAY = 0.1

local serverBannedPlayers = {}

-- ProfileTemplate table is what empty profiles will default to.
-- Updating the template will not include missing template values
--   in existing player profiles!
export type PlayerProfile = {
	Data: {
		TimePlayed: number,
		RaritiesSold: number,
		Donated: number,
		CurrentRarity: number,
		Rebirth: number,
		Luck: number,
		InGroup: boolean,
		RebirthTokens: number,
		DoubleRollspeed: boolean,
		CollectedRarities: { number },

		Settings: {
			OtherPlayersHidden: boolean,
			MusicEnabled: boolean,
		},

		BanInfo: {
			IsBanned: boolean,
			BanReason: string,
		},
	},
}

playerDataService.ProfileTemplate = {
	TimePlayed = 0,
	RaritiesSold = 0,
	Donated = 0,
	CurrentRarity = 0,
	Rebirth = 0,
	Luck = 2,
	InGroup = false,
	RebirthTokens = 0,
	DoubleRollspeed = false,
	CollectedRarities = {},

	Settings = {
		OtherPlayersHidden = false,
		MusicEnabled = true,
	},

	BanInfo = {
		IsBanned = false,
		BanReason = "",
	},
}

local ProfileService = require(ServerStorage.serverPackages.ProfileService)

playerDataService.ProfileStore = ProfileService.GetProfileStore("PlayerData", playerDataService.ProfileTemplate)

local Profiles = {} -- [player] = profile

local function playerAdded(player: Player)
	-- Server bans
	local banReason = serverBannedPlayers[player.UserId]
	if banReason then
		player:Kick(banReason)
	end
	local success, profile = pcall(function()
		return playerDataService.ProfileStore:LoadProfileAsync(`Player_{player.UserId}`)
	end)
	if profile and success then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			if profile.Data.BanInfo.IsBanned then
				player:Kick(`You have been banned from this experience! Reason: {profile.Data.BanInfo.BanReason}`)
				return
			end
			Profiles[player] = profile
			profile.Data.InGroup = player:IsInGroup(sharedInfo.GroupId)
			monetizationUtil
				.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["2x Roll Speed"])
				:andThen(function(owns)
					profile.Data.DoubleRollspeed = owns
				end)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick("Data profile could not be loaded.")
	end
end

function playerDataService.start()
	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end

	Players.PlayerAdded:Connect(playerAdded)

	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:Release()
		end
	end)
end

function playerDataService.serverBan(userId: number, reason: string)
	serverBannedPlayers[userId] = reason
end

function playerDataService.client.getLuck(player: Player)
	local profile = playerDataService.getProfile(player)
	if not profile then
		return 0
	end
	return profile.Data.Luck
end

function playerDataService.client.getSettings(player: Player)
	local profile = playerDataService.getProfile(player)
	if not profile then
		return
	end
	return profile.Data.Settings
end

function playerDataService.client.updateSettings(player: Player, settings)
	local profile = playerDataService.getProfile(player)
	if not profile then
		return
	end
	local playerSettings = profile.Data.Settings
	for name, value in settings do
		if not playerSettings[name] or type(value) ~= type(playerSettings[name]) then
			continue
		end
		playerSettings[name] = value
	end
	playerDataService.setProfile(player, profile)
end

-- Preferably used inside of PlayerAdded events
function playerDataService.waitForProfile(player: Player): PlayerProfile?
	while player:IsDescendantOf(Players) do
		local profile = Profiles[player]
		if profile then
			return profile
		end
		task.wait(RETRY_DELAY)
	end
end

function playerDataService.updateProfile(player: Player, newData: { [any]: any })
	local playerProfile = playerDataService.getProfile(player)
	local mergedData = sift.Dictionary.merge(playerProfile.Data, newData)
	playerProfile.Data = mergedData
	playerDataService.setProfile(player, mergedData)
end

-- Gives a copy of the profile rather than the actual profile for immutability purposes
function playerDataService.getProfile(player: Player): PlayerProfile?
	if player:IsDescendantOf(Players) and not Profiles[player] then
		return playerDataService.waitForProfile(player)
	end
	return Profiles[player]
end

function playerDataService.setProfile(player: Player, newProfile)
	if not (player:IsDescendantOf(Players) and Profiles[player]) then
		return
	end
	playerDataService.profileChanged:Fire(player, newProfile)
	playerDataService.client.profileChanged:fireClient(player, newProfile.Data)
end

return playerDataService

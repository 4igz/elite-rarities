local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local playerDataService = require(script.Parent.Parent.services.playerDataService)
local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)

local RebirthBoardGui = Component.new({
	tag = "RebirthBoardGui",
	extensions = { remoteComponentExtension },
	client = {},
})

function RebirthBoardGui.client.getRebirths(player: Player)
    local profile = playerDataService.getProfile(player)
    if not profile then
        return 0
    end

	return profile.Data.Rebirth
end

return RebirthBoardGui

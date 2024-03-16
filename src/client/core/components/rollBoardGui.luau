local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)

local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)

local RollBoardGui = Component.new({
	tag = "RollBoardGui",
	extensions = { remoteComponentExtension },
	requiredServerComponents = { "RollBoardGui" },
})

-- Used for communication with server

return RollBoardGui

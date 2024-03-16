local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local Component = require(sharedPackages.Component)
local sharedInfo = require(shared.sharedInfo)
local rarityConfig = require(shared.configuations.rarityConfig)
local serviceUtil = require(shared.utilities.serviceUtil)

local remoteComponentExtension = require(shared.componentExtensions.remoteComponent)
local playerDataService = serviceUtil.service("playerDataService")

local RebirthBoardGui = Component.new({
	tag = "RebirthBoardGui",
	extensions = { remoteComponentExtension },
	requiredServerComponents = { "RebirthBoardGui" },
})


function RebirthBoardGui:start()
    self:setLabelText()

    playerDataService.profileChanged:connect(function()
        self:setLabelText()
    end)
end

function RebirthBoardGui:setLabelText()
    local rebirthTextLabel: TextLabel = self.instance:WaitForChild("RebirthText")
    local rebirth = self.server.RebirthBoardGui.getRebirths()
	local rarityIdx = math.min(sharedInfo.BaseRebirthRarity + rebirth, #rarityConfig)
    rebirthTextLabel.Text = `{rarityConfig[rarityIdx].rarityName}+`
end

return RebirthBoardGui

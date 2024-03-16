local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.shared

local monetizationUtil = require(shared.utilities.monetizationUtil)
local sharedInfo = require(shared.sharedInfo)

local walkspeedService = {}

function walkspeedService.start()
    Players.PlayerAdded:Connect(function(player: Player)
        player.CharacterAdded:Connect(function(character)
            monetizationUtil.userOwnsGamepass(player.UserId, sharedInfo.Gamepasses["2x Walkspeed"]):andThen(function(owns)
                if owns then
					local hum = character:WaitForChild("Humanoid", 5)
					if not hum then
						return
					end
                    hum.WalkSpeed = 32
                end
            end)
        end)
    end)
end

return walkspeedService
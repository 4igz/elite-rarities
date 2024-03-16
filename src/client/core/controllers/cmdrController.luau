local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cmdrController = {}

function cmdrController.start()
	local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

	Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
end

return cmdrController

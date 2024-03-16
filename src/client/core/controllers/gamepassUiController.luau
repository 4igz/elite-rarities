local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mainUi = playerGui:WaitForChild("MainUi")
local bg = mainUi:WaitForChild("Menus"):WaitForChild("GamepassMenu")
local templates = bg:WaitForChild("Templates")
local iframe = bg:WaitForChild("ScrollingFrame")
local shoppingCart = mainUi:WaitForChild("Buttons"):WaitForChild("ShoppingCart")

local shared = ReplicatedStorage.shared

local uiController = require(script.Parent.uiController)
local sharedInfo = require(shared.sharedInfo)

local gamepassUiController = {}

function gamepassUiController.start()
	for name, id in sharedInfo.Gamepasses do
		task.spawn(function()
			local gamepassInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
			local gamepassInfoFrame = templates.GamepassInfo:Clone()
			local buy: TextButton = gamepassInfoFrame.Buy
			gamepassInfoFrame.Icon.Image = `rbxassetid://{gamepassInfo.IconImageAssetId}`
			gamepassInfoFrame.PassName.Text = name
			buy.Text = `{gamepassInfo.PriceInRobux}R$`
			gamepassInfoFrame.Visible = true
			gamepassInfoFrame.Parent = iframe

			buy.MouseButton1Click:Connect(function()
				MarketplaceService:PromptGamePassPurchase(localPlayer, id)
			end)
		end)
	end

	shoppingCart.MouseButton1Click:Connect(function()
		uiController.toggle("GamepassMenu")
	end)
end

return gamepassUiController

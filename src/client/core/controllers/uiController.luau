local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mainUi = playerGui:WaitForChild("MainUi")
local menus = mainUi:WaitForChild("Menus")

local uiController = {}

function uiController.toggle(menuName: string)
    for _, menu in menus:GetChildren() do
        if menu.Name == menuName then
            menu.Visible = not menu.Visible
            continue
        end
        menu.Visible = false
    end
end

return uiController
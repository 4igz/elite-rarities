local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local antiPlayerCollisions = {}

local playerCollisionGroupName = "Players"
PhysicsService:RegisterCollisionGroup(playerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(
	playerCollisionGroupName,
	playerCollisionGroupName,
	false
)

local previousCollisionGroups = {}

local function setCollisionGroup(object: BasePart)
	if object:IsA("BasePart") then
		previousCollisionGroups[object] = object.CollisionGroup
		object.CollisionGroup = playerCollisionGroupName
	end
end

local function setCollisionGroupRecursive(object: BasePart)
	setCollisionGroup(object)

	for _, child in ipairs(object:GetChildren()) do
		setCollisionGroupRecursive(child)
	end
end

local function resetCollisionGroup(object: BasePart)
	local previousCollisionGroupName = previousCollisionGroups[object]
	if not previousCollisionGroupName then
		return
	end

	object.CollisionGroup = playerCollisionGroupName
	previousCollisionGroups[object] = nil
end

local function onCharacterAdded(character)
	setCollisionGroupRecursive(character)

	character.DescendantAdded:Connect(setCollisionGroup)
	character.DescendantRemoving:Connect(resetCollisionGroup)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end

function antiPlayerCollisions.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return antiPlayerCollisions

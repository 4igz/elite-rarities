local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedPackages = ReplicatedStorage.sharedPackages
local shared = ReplicatedStorage.shared

local network = require(sharedPackages.network)
local rarityConfig = require(shared.configuations.rarityConfig)

local rng = Random.new(tick())

local rollService = {
	client = {
		rarityUpdated = network.Server.RemoteSignal.new(),
		rolledRarity = network.Server.RemoteSignal.new(),
	},
}

function rollService.rollRarity(luck: number): (number, rarityConfig.RarityInfo)
	local tw = 0 -- total weight
	local nameChanceMap = {}
	for _, rarityInfo in rarityConfig do
		tw += 1 / rarityInfo.chance
		nameChanceMap[rarityInfo.rarityName] = 1 / rarityInfo.chance
	end
	local roll = rng:NextNumber(0, tw) / luck
	local lowest = math.huge
	local lowestRarity = ""
	for rarity, chance in nameChanceMap do
		if roll < chance and chance < lowest then
			lowest = chance
			lowestRarity = rarity
		end
	end
	for i, rarityInfo in rarityConfig do
		if rarityInfo.rarityName == lowestRarity then
			return i
		end
	end
end

return rollService

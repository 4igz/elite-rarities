local playerDataService = require(script.Parent.Parent.services.playerDataService)

return function(_, players, reason)
	for _, player in pairs(players) do
        playerDataService.serverBan(player.UserId, reason)
		player:Kick(reason)
	end

	return `Banned {#players} players.`
end

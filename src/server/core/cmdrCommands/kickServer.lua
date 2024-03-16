return function(_, players, reason)
	for _, player in pairs(players) do
		player:Kick(reason)
	end

	return `Kicked {#players} players.`
end

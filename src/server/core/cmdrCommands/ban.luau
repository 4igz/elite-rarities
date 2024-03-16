return {
	Name = "ban",
	Description = "SERVER Bans a player or set of players.",
	Group = "Mod",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to ban.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "Give the player a reason why they were banned.",
		},
	},
}

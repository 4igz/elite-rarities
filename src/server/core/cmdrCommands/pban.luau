return {
	Name = "pban",
	Description = "PERMANENTLY Bans a player or set of players until unbanned.",
	Group = "Admin",
	Args = {
		{
			Type = "player @ number",
			Name = "player or userid",
			Description = "The players to pban.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "Give the player a reason why they were pbanned.",
		},
	},
}

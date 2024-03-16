return {
	Name = "kick";
	Description = "Kicks a player or set of players.";
	Group = "Mod";
	Args = {
		{
			Type = "players";
			Name = "players";
			Description = "The players to kick.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "Give the player a reason why they were kicked."
		}
	};
}
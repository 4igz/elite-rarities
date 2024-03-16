return {
	Name = "unban",
	Description = "Removes a players ban.",
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "player userid",
			Description = "The player to unban.",
		},
	},
}

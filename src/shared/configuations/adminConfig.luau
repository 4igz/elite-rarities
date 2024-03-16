return table.freeze({
	AdminLevels = {
		-- These will be configured automatically by someone later. Right now
		-- temporary command groups've been added in, just for testing.
		{
			role = "Moderator",
			commandGroups = { "Mod" },
			groupAccess = {
				[15412106] = 252,
			},
			whiteList = {},
		},

		{
			role = "Admin",
			commandGroups = { "Admin", "Mod" },
			groupAccess = {
				[15412106] = 253,
			},
			whiteList = {},
		},

		{
			role = "Developer",
			commandGroups = { "Developer", "Mod", "Admin" },
			groupAccess = {
				[15412106] = 254,
			},
			whiteList = {},
		},
	},

	ActivationKeys = { Enum.KeyCode.Semicolon },
	miscellaneous = { enableCmdrGuiToNonAdmins = false },
})

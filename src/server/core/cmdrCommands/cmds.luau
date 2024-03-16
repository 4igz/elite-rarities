local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedModules = ReplicatedStorage.shared

local sharedAdminUtil = require(sharedModules.utilities.sharedAdminUtil)

local DEFAULT_COMMAND_DEFINITION_ALIASES = {}

return {
	Name = "cmds",
	Description = "Displays a list of all commands along with their syntax, description and permission level.",
	Group = "Help",
	Args = {},

	ClientRun = function(context): string?
		local registry = context.Cmdr.Registry

		for _, commandDefinition in registry:GetCommands() do
			context:Reply(`Command name: {commandDefinition.Name}`)
			context:Reply(
				`\tSyntax: {table.concat(
					commandDefinition.Aliases or DEFAULT_COMMAND_DEFINITION_ALIASES,
					", "
				)}`
			)
			context:Reply(string.format("\tDescription: %s", commandDefinition.Description))
			context:Reply(
				`\tPermission level: {sharedAdminUtil.minimumAdminLevelForCommand(commandDefinition)}`
			)
			context:Reply(("-"):rep(20))
		end

		return ""
	end,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedAdminUtil = require(ReplicatedStorage.shared.utilities.sharedAdminUtil)

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "Help" then
			return
		end
		local playerCanExecuteCommand, minimumRoleRequiredToExecuteCommand =
			sharedAdminUtil.playerCanExecuteCommand(context.Executor, context.Group)

		if not playerCanExecuteCommand then
			return `Only {minimumRoleRequiredToExecuteCommand}+ can execute this command.`
		end
	end)
end

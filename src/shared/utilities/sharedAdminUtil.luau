local adminConfig = require(script.Parent.Parent.configuations.adminConfig)

local sharedAdminUtil = {}

local function getAdminRoleRequiredToExecuteCommand(commandGroup: string): string
	for _, adminLevel in adminConfig.AdminLevels do
		if not table.find(adminLevel.commandGroups, commandGroup) then
			continue
		end

		return adminLevel.role
	end

	return ""
end

local function playerIsWhiteListedForAdminLevel(player: Player, adminLevel): boolean
	if table.find(adminLevel.whiteList, player.UserId) then
		return true
	end

	for groupId, minimumGroupRank in adminLevel.groupAccess do
		local playerGroupRank = player:GetRankInGroup(groupId)

		if playerGroupRank >= minimumGroupRank then
			return true
		end
	end

	return false
end

function sharedAdminUtil.minimumAdminLevelForCommand(commandDefinition): number
	for _, adminLevel in adminConfig.AdminLevels do
		if not table.find(adminLevel.commandGroups, commandDefinition.Group) then
			continue
		end

		return adminLevel.role
	end

    return "Everyone"
end

function sharedAdminUtil.playerCanExecuteCommand(
	player: Player,
	commandGroup: string
): (boolean, string?)
	for _, adminLevel in adminConfig.AdminLevels do
		if
			table.find(adminLevel.commandGroups, commandGroup)
			and playerIsWhiteListedForAdminLevel(player, adminLevel)
		then
			return true
		end
	end

	return false, getAdminRoleRequiredToExecuteCommand(commandGroup)
end

return sharedAdminUtil

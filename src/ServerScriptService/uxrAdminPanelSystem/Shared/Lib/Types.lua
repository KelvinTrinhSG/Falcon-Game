--!strict

export type Color3Hex = string

export type RankFlags = {
	Kick: boolean?, Warn: boolean?, Ban: boolean?, ServerBan: boolean?,
	Unban: boolean?, ServerUnban: boolean?,
	ServerAnnouncement: boolean?, GlobalAnnouncement: boolean?,
	Notify: boolean?, Fly: boolean?,
	ConfigureCharacter: boolean?, ConfigureHumanoid: boolean?,
	ServerTeleportation: boolean?,
	ViewAuditLogs: boolean?, AuditActivities: boolean?, ViewProfile: boolean?,
	Bannable: boolean?, Kickable: boolean?, Warnable: boolean?,
}

export type Rank = {
	Level: number,
	Name: string,
	DisplayName: string?,
	Color: Color3Hex,
	Members: { number }?,
	Flags: RankFlags?,
}

export type Assignment = {
	Players: { number }?,
	Gamepasses: { number }?,
	Assets: { number }?,
	Groups: { { number } }?,
	Teams: { string }?,
}

export type Permission = string | { string }

export type ArgSpec = {
	name: string,
	type: string,
	default: any?,
	optional: boolean?,
	min: number?,
	max: number?,
	joinRest: boolean?,
	oneOf: { string }?,
}

export type CommandMeta = {
	Name: string?,
	Aliases: { string }?,
	Category: string?,
	Permission: Permission,
	Description: string?,
	Args: { ArgSpec }?,
	Log: boolean?,
	Webhook: boolean?,
	CommandText: string?,
}

export type CommandCtx = {
	actor: Player,
	modifiers: { [string]: any },
	notify: (text: string, kind: string?) -> (),
	apEvents: Folder,
	Players: any,
	Settings: any,
	Permissions: any,
	UtilModule: any,
}

export type CommandImpl = (ctx: CommandCtx, args: { [string]: any }) -> ()

export type LogEntry = {
	id: string,
	userId: number,
	adminName: string,
	command: string,
	target: string,
	description: string,
	time: number,
	date: any,
	dateString: string,
}

export type PermissionsConfig = {
	Ranks: { Rank },
	Assignments: { [string]: Assignment },
	AutoRankOwner: boolean,
	Resolution: "Max" | "First",
	FriendsRank: string?,
	VipServerOwnerRank: string?,
	FreeAdminRank: string?,
	NavSeeRank: string,
	CommandBarRank: string,
	LogsViewRank: string,
	PunishViewRank: string,
	PostMessageRank: string,
	GlobalPostRank: string,
}

export type SettingsConfig = {
	Debug: boolean,
	Prefix: string,
	SplitKey: string,
	CommandDebounce: number,
	CommandFrequencies: { [string]: number },
	VIPServerCommandBlacklist: { string },
	Messages: { [string]: string },
	Localization: { Self: string, All: string, Other: string },
	WarnThreshold: number?,
	WarnAutoAction: string?,
	WarnAutoBanDuration: number?,
	WelcomeNotification: boolean?,
}

return {}

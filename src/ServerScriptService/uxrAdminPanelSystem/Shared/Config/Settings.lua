--!strict
local Types = require(script.Parent.Parent.Lib.Types)

local Settings: Types.SettingsConfig = {

	Debug = true,

	-- Command parsing
	-- Cosmetic prefix shown in the UI ("u!ping"). The server strips it
	-- before lookup, so internal command names are bare ("ping").
	-- v2 CommandParser uses whitespace splitting, "&&" for chaining, and
	-- "," for multi-target.
	Prefix             = "u!",
	SplitKey           = " ",

	-- Rate limiting
	-- Default debounce (seconds) between any two commands from the same player.
	-- Set to 0 to disable the global gate; CommandFrequencies can override
	-- per-command.
	CommandDebounce    = 0.25,

	-- Per-command minimum gap, keyed by CommandName. Overrides CommandDebounce.
	CommandFrequencies = {
		shutdown     = 5,
		nuke         = 3,
		explosion    = 1,
		vote         = 10,
		permrank     = 2,
		rank         = 1,
	},

	-- Warning policy
	-- After WarnThreshold warnings, WarnAutoAction fires automatically.
	-- Set WarnThreshold to 0 to disable the auto-action. AutoAction options:
	--   "none"     record the warning only
	--   "kick"     kick on the threshold-th warn
	--   "tempban"  temp-ban for WarnAutoBanDuration seconds
	--   "ban"      permanent ban
	WarnThreshold        = 3,
	WarnAutoAction       = "kick",
	WarnAutoBanDuration  = 86400 * 7,   -- 7 days (used only for "tempban")

	-- VIP / private-server policy
	-- Commands rejected silently inside paid private (VIP) servers.
	VIPServerCommandBlacklist = {
		"permrank", "unpermrank",
		"ban", "tempban", "unban",
		"globalservermessage",
		"savemap", "loadmap",
	},

	-- Messages (templates use $token placeholders).
	Messages = {
		ServerClosed         = "The server has been shut down.",
		ServerCloseWarning   = "The server is being shut down by the administrator.",
		LockdownKick         = "A lockdown has been activated on this server and people without a whitelist cannot enter.",
		LockedKick           = "This server is locked. You cannot join.",

		KickMessage          = "You Are Kicked From The Game\nReason: $reason\n",
		BanDisplayReason     = "You are banned from this game. Reason: $reason",
		TempBanDisplayReason = "You are temporarily banned from this game. Reason: $reason | Duration: $duration",

		BanSuccess     = "Player permanently banned successfully",
		BanFail        = "Ban failed: $error",
		TempBanSuccess = "Player temporarily banned for $duration",
		TempBanFail    = "Temporary ban failed: $error",
	},

	-- Targeting keywords.
	Localization = {
		Self  = "me",
		All   = "all",
		Other = "other",
	},

	-- First-join welcome notifications
	-- The two "Welcome / Your rank is …" popups shown when a player's panel
	-- loads. Set to false to hide them for everyone (admins included).
	WelcomeNotification = true,

}

return Settings

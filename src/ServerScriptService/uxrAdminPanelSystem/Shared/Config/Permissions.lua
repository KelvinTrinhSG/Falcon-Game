--!strict
-- Rank system. Configuration is organised by rank: each entry lists who
-- holds the rank and what its source is (player IDs, gamepasses, groups,
-- teams). Commands reference ranks by name.

local Types = require(script.Parent.Parent.Lib.Types)

local Permissions: Types.PermissionsConfig = {} :: any

-- RANKS — ordered highest-first. Add or remove ranks freely; Level governs
-- ordering (higher = more power), Name is what commands reference, Color
-- is the rank badge color.
--
-- Flags are defender-side immunities. When an action targets a player whose
-- rank sets a flag to false, UtilModule:CanActOn(target, action) denies it.
-- nil or missing flags are treated as "allowed". This enables patterns like
-- "Owner cannot be banned even by another Owner".
--
-- Supported flags (extend freely; see UtilModule:CanActOn):
--   Bannable / Kickable / Mutable / Jailable / Killable / Configurable
Permissions.Ranks = {
	{ Name = "Owner",     DisplayName = "Owner",      Level = 5, Color = "#EF233C",
	  Flags = { Bannable = false, Kickable = false, Mutable = false, Jailable = true, Warnable = false } },
	{ Name = "HeadAdmin", DisplayName = "Head Admin", Level = 4, Color = "#9B59B6",
	  Flags = { Bannable = false, Kickable = false, Mutable = false, Warnable = false } },
	{ Name = "Admin",     DisplayName = "Admin",      Level = 3, Color = "#3498DB",
	  Flags = { Bannable = false } },
	{ Name = "Mod",       DisplayName = "Mod",        Level = 2, Color = "#1ABC9C", Flags = {} },
	{ Name = "VIP",       DisplayName = "VIP",        Level = 1, Color = "#F1C40F", Flags = {} },
	{ Name = "NonAdmin",  DisplayName = "Non Admin",  Level = 0, Color = "#95A5A6", Flags = {} },
}

-- ASSIGNMENTS — who holds which rank. Keyed by rank Name.
--   Players    = { userId, userId, ... }              direct user IDs
--   Gamepasses = { gamepassId, gamepassId, ... }      owning any grants the rank
--   Assets     = { assetId, assetId, ... }            owning any grants the rank
--   Groups     = { {groupId, rankInGroup}, ... }      in-group rank match
--   Teams      = { "TeamName", "TeamName", ... }      on that team
--
-- A player holds a rank if they match any entry in the rank's assignment.
-- When multiple ranks match, the highest Level wins (Resolution = "Max").
Permissions.Assignments = {

	Owner = {
		Players    = { 11115679011 },
		Gamepasses = {},
		Assets     = {},
		Groups     = { {231692500, 255} },   -- group owner
		Teams      = {},
	},

	HeadAdmin = {
		Players    = {},
		Gamepasses = {},
		Assets     = {},
		Groups     = {},
		Teams      = {},
	},

	Admin = {
		Players    = {},
		Gamepasses = {},
		Assets     = {},
		Groups     = { {231692500, 2} },
		Teams      = {},
	},

	Mod = {
		Players    = {},
		Gamepasses = {},
		Assets     = {},
		Groups     = {},
		Teams      = { "Police" },
	},

	VIP = {
		Players    = {},
		Gamepasses = {},                    -- e.g. { 23423424234 }
		Assets     = {},
		Groups     = { {231692500, 1} },
		Teams      = {},
	},

	-- NonAdmin is the fallback rank; no explicit assignments needed.
}

-- Special grants. Set a rank Name to enable, nil to disable.
Permissions.AutoRankOwner       = true        -- game creator becomes Owner
Permissions.FriendsRank         = nil         -- creator's friends, e.g. "VIP"
Permissions.VipServerOwnerRank  = nil         -- private-server owner, e.g. "Mod"
Permissions.FreeAdminRank       = "NonAdmin"  -- floor rank every joining player gets

-- Page gating: minimum rank required for each UI area.
Permissions.NavSeeRank        = "NonAdmin"   -- can see the panel
Permissions.CommandBarRank    = "VIP"        -- can use the command popup
Permissions.LogsViewRank      = "Mod"
Permissions.PunishViewRank    = "Mod"
Permissions.PostMessageRank   = "Mod"
Permissions.GlobalPostRank    = "Admin"

return Permissions

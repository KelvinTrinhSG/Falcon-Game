--!nocheck
-- Typed-schema metadata for every v2 command.
--
-- Per-entry schema:
--   Aliases      short alternates ("fl" → "fly")
--   Category     groups the command in the browser UI
--   Permission   minimum rank ("VIP" / "Mod" / "Admin" / "HeadAdmin" / "Owner")
--   Description  one-liner shown in tooltips / help
--   Args         ordered list of { name, type, default?, min?, max?,
--                  joinRest?, optional?, oneOf? }
--                Types: Players, Number, AssetId, Duration, String, Color,
--                       Bool, Rank, Material, Team
--   Log          bool — write a structured admin-action log entry
--   Webhook      bool — relay to your webhook endpoint via WebhookService
--
-- The CommandDispatcher resolves args via ArgTypes + TargetResolver and
-- invokes the impl (Server/Commands/<Category>.luau) once per resolved target.
--
-- Commands are alphabetised within each category for browser scannability.

local Commands = {}

-- Movement
Commands.fly = {
    Aliases = {"fl"},
    Category = "Movement",
    Permission = "Mod",
    Description = "Toggle flight on the target",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number",  default = 50, min = 1, max = 500 },
    },
    Log = true,
}
Commands.unfly = {
    Category = "Movement", Permission = "Mod",
    Description = "Force-stop flight mode",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.noclip = {
    Category = "Movement", Permission = "Mod",
    Description = "Toggle no-clip walking",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number",  default = 50, min = 1, max = 500 },
    },
    Log = true,
}
Commands.unnoclip = {
    Aliases = {"clip"},
    Category = "Movement", Permission = "Mod",
    Description = "Force-stop no-clip mode",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.flytool = {
    Category = "Movement", Permission = "Mod",
    Description = "Give a FLY tool",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number",  optional = true, min = 1, max = 500 },
    },
    Log = true,
}
Commands.unflytool = {
    Category = "Movement", Permission = "Mod",
    Description = "Take the FLY tool",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.nocliptool = {
    Category = "Movement", Permission = "Mod",
    Description = "Give a noclip tool",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number",  optional = true, min = 1, max = 500 },
    },
    Log = true,
}
Commands.unnocliptool = {
    Category = "Movement", Permission = "Mod",
    Description = "Take the noclip tool",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.walkspeed = {
    Aliases = {"ws"},
    Category = "Movement", Permission = "Mod",
    Description = "Set the walk speed",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number",  default = 16, min = 0, max = 5000 },
    },
    Log = true,
}
Commands.jumpspeed = {
    Aliases = {"jp", "jumppower", "jumpheight", "power"},
    Category = "Movement", Permission = "Mod",
    Description = "Set the jump height",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "height", type = "Number",  default = 7.2, min = 0, max = 5000 },
    },
    Log = true,
}
Commands.sit = {
    Category = "Movement", Permission = "VIP",
    Description = "Force the player to sit",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.jump = {
    Category = "Movement", Permission = "VIP",
    Description = "Force the player to jump",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.fov = {
    Category = "Movement", Permission = "VIP",
    Description = "Set the camera FOV",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "fov",    type = "Number",  default = 70, min = 1, max = 120 },
    },
    Log = true,
}
Commands.weld = {
    Category = "Movement", Permission = "Admin",
    Description = "Weld target to whatever's in front of you",
    Args = { { name = "target", type = "Players" } }, Log = true,
}
Commands.setspawn = {
    Aliases = {"setspawnpoint", "respawnlocation"},
    Category = "Movement", Permission = "Admin",
    Description = "Place a personal SpawnLocation under the target",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}

-- Combat
Commands.kill = {
    Category = "Combat", Permission = "Mod",
    Description = "Kill the player instantly",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.killall = {
    Category = "Combat", Permission = "HeadAdmin",
    Description = "Kill everyone but you",
    Args = {},
    Log = true,
}
Commands.damage = {
    Category = "Combat", Permission = "Mod",
    Description = "Subtract HP from the player",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number",  default = 25, min = 0, max = 10000 },
    },
    Log = true,
}
Commands.heal = {
    Category = "Combat", Permission = "Mod",
    Description = "Restore HP to the player",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number",  default = 25, min = 0, max = 10000 },
    },
    Log = true,
}
Commands.sethealth = {
    Aliases = {"health", "hp"},
    Category = "Combat", Permission = "Mod",
    Description = "Set HP to exact value",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "hp",     type = "Number",  min = 0, max = 10000 },
    },
    Log = true,
}
Commands.refresh = {
    Aliases = {"reload", "respawn"},
    Category = "Combat", Permission = "Mod",
    Description = "Respawn the player's character",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.clone = {
    Category = "Combat", Permission = "Mod",
    Description = "Make a static character copy",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.forcefield = {
    Aliases = {"ff"},
    Category = "Combat", Permission = "Mod",
    Description = "Toggle a visible forcefield",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unforcefield = {
    Aliases = {"unff"},
    Category = "Combat", Permission = "Mod",
    Description = "Force-remove the visible forcefield",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.god = {
    Category = "Combat", Permission = "Mod",
    Description = "Toggle godmode invincibility shield",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.ungod = {
    Category = "Combat", Permission = "Mod",
    Description = "Force-remove the godmode shield",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.explosion = {
    Aliases = {"boom", "explode"},
    Category = "Combat", Permission = "HeadAdmin",
    Description = "Detonate at player location",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "radius", type = "Number",  default = 4, min = 1, max = 200 },
    },
    Log = true,
}
Commands.freeze = {
    Category = "Combat", Permission = "Mod",
    Description = "Toggle frozen with ice block",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unfreeze = {
    Category = "Combat", Permission = "Mod",
    Description = "Force-unfreeze the player",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.nuke = {
    Category = "Combat", Permission = "Owner",
    Description = "Spawn a nuke near you",
    Args = {},
    Log = true,
    Webhook = true,
    Confirm = true,
}
Commands.fling = {
    Category = "Combat", Permission = "Mod",
    Description = "Launch player with high velocity",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.healall = {
    Category = "Combat", Permission = "Mod",
    Description = "Restore everyone to full HP",
    Args = {}, Log = true,
}
Commands.fix = {
    Category = "Combat", Permission = "Mod",
    Description = "Reset effects + speed/jump/HP without respawn",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.removeall = {
    Category = "Combat", Permission = "HeadAdmin",
    Description = "Strip an effect class from every player",
    Args = {
        { name = "effect", type = "String",
          oneOf = {"fire","smoke","sparkles","forcefield","ff","highlight"} },
    }, Log = true,
}

-- Cosmetic
Commands.highlight = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle an outline highlight",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unhighlight = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-remove the highlight",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.shirt = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set shirt by asset ID",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "asset",  type = "AssetId" },
    },
    Log = true,
}
Commands.pants = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set pants by asset ID",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "asset",  type = "AssetId" },
    },
    Log = true,
}
Commands.face = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set face by asset ID",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "asset",  type = "AssetId" },
    },
    Log = true,
}
Commands.bighead = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Enlarge the player's head",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "size",   type = "Number",  default = 5, min = 0.1, max = 100 },
    },
    Log = true,
}
Commands.smallhead = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Shrink the player's head",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "size",   type = "Number",  default = 0.5, min = 0.1, max = 100 },
    },
    Log = true,
}
Commands.normalhead = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Reset head to normal size",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.smoke = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle a smoke effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unsmoke = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-remove the smoke effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.fire = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle a fire effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unfire = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-remove the fire effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.sparkles = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle a sparkles effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.unsparkles = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-remove the sparkles effect",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.spin = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle a head spin effect",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "rate",   type = "Number",  default = 5, min = -100, max = 100 },
    },
    Log = true,
}
Commands.unspin = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-stop the head spin",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.size = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Multiply the body scale",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "scale",  type = "Number",  default = 2, min = 0.1, max = 50 },
    },
    Log = true,
}
Commands.height = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Multiply body height only",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "scale",  type = "Number",  default = 2, min = 0.1, max = 50 },
    },
    Log = true,
}
Commands.width = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Multiply body width only",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "scale",  type = "Number",  default = 2, min = 0.1, max = 50 },
    },
    Log = true,
}
Commands.giant = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Scale body parts by 5",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.dwarf = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Scale body parts by 0.5",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.fat = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Increase body depth and width",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.thin = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Reduce body depth and width",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.changename = {
    Aliases = {"name", "rename", "nick", "nickname"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set the overhead display name",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "name",   type = "String",  joinRest = true },
    },
    Log = true,
}
Commands.hidename = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle the overhead name display",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.showname = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-show the overhead name",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.invisible = {
    Aliases = {"inv"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle character invisibility on/off",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.visible = {
    Aliases = {"vis"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-show the character body",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.hideguis = {
    Aliases = {"nogui", "hideui"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Toggle all UIs except chat",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.showguis = {
    Aliases = {"showui"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Force-show all UI screens",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.material = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set the body part material",
    Args = {
        { name = "target",   type = "Players",  default = "me" },
        { name = "material", type = "Material" },
    },
    Log = true,
}
Commands.gold     = { Category = "Cosmetic", Permission = "Mod", Description = "Turn the body into gold",  Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.neon     = { Category = "Cosmetic", Permission = "Mod", Description = "Turn the body into neon",  Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.ghost    = { Category = "Cosmetic", Permission = "Mod", Description = "Turn the body ghostly transparent", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.glass    = { Category = "Cosmetic", Permission = "Mod", Description = "Turn the body into glass", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.ice      = { Category = "Cosmetic", Permission = "Mod", Description = "Turn the body into ice",   Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.sword    = { Category = "Cosmetic", Permission = "Mod", Description = "Give a basic combat sword", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.btools   = { Category = "Cosmetic", Permission = "Mod", Description = "Give F3X building tools", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.fart     = { Category = "Cosmetic", Permission = "VIP", Description = "Cosmetic green fart effect", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.clearhats = { Category = "Cosmetic", Permission = "Mod", Description = "Remove all hat accessories", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.disco    = { Category = "Cosmetic", Permission = "Admin", Description = "Start ambient color flash loop", Args = {}, Log = true }
Commands.undisco  = { Category = "Cosmetic", Permission = "Admin", Description = "Stop the ambient flash loop", Args = {}, Log = true }
Commands.skybox   = { Category = "Cosmetic", Permission = "Admin", Description = "Open the skybox picker", Args = {}, Log = true }

-- ColorCorrection presets (shared "uxrCorrection" effect under Lighting).
Commands.grayscale = { Aliases = {"b&w"}, Category = "Cosmetic", Permission = "Admin", Description = "Desaturate the screen", Args = {}, Log = true }
Commands.saturate  = { Category = "Cosmetic", Permission = "Admin", Description = "Over-saturate the screen", Args = {}, Log = true }
Commands.contrast  = { Category = "Cosmetic", Permission = "Admin", Description = "High-contrast post effect", Args = {}, Log = true }
Commands.inverted  = { Aliases = {"invert"}, Category = "Cosmetic", Permission = "Admin", Description = "Invert screen colors", Args = {}, Log = true }
Commands.tint = {
    Aliases = {"tintcolor"},
    Category = "Cosmetic", Permission = "Admin",
    Description = "Tint the screen with a color",
    Args = { { name = "color", type = "String", joinRest = true } }, Log = true,
}
Commands.unvisuals = {
    Aliases = {"disablevisuals"},
    Category = "Cosmetic", Permission = "Admin",
    Description = "Clear every Lighting effect we placed",
    Args = {}, Log = true,
}

-- RGB body cosmetic.
Commands.color = {
    Aliases = {"colour", "paint", "setcolor"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Color every body part",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "color",  type = "String", joinRest = true },
    }, Log = true,
}
Commands.reflectance = {
    Aliases = {"reflect"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set body reflectance 0-1",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number", default = 0.5, min = 0, max = 1 },
    }, Log = true,
}
Commands.transparency = {
    Aliases = {"opacity"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set body transparency 0-1",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number", default = 0.5, min = 0, max = 1 },
    }, Log = true,
}

-- Granular humanoid scaling.
Commands.headsize  = { Aliases = {"headscale"},   Category = "Cosmetic", Permission = "Mod", Description = "Set head scale", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 1, min = 0.1, max = 10 } }, Log = true }
Commands.hipheight = { Aliases = {"hipscale"},    Category = "Cosmetic", Permission = "Mod", Description = "Set humanoid hip height", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 2, min = 0, max = 50 } }, Log = true }
Commands.bodytype  = { Aliases = {"bodyscale", "bodyTypeScale", "btScale"},   Category = "Cosmetic", Permission = "Mod", Description = "BodyTypeScale 0=R15→1=slender", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 0, min = 0, max = 1 } }, Log = true }
Commands.depth     = { Aliases = {"depthscale"},  Category = "Cosmetic", Permission = "Mod", Description = "BodyDepthScale", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 1, min = 0.1, max = 10 } }, Log = true }
Commands.proportion= { Category = "Cosmetic", Permission = "Mod", Description = "Body proportion 0-1", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 0.5, min = 0, max = 1 } }, Log = true }
Commands.squash    = { Category = "Cosmetic", Permission = "Mod", Description = "Flatten the character", Args = { { name = "target", type = "Players", default = "me" }, { name = "scale", type = "Number", default = 0.5, min = 0.1, max = 1 } }, Log = true }

-- Glitch + ragdoll + title.
Commands.glitch    = { Aliases = {"glitched"}, Category = "Cosmetic", Permission = "Mod", Description = "Avatar randomized transparency/reflectance loop", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.unglitch  = { Category = "Cosmetic", Permission = "Mod", Description = "Stop the glitch loop", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.title = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Overhead title that survives respawn",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "text",   type = "String", joinRest = true },
    }, Log = true,
}
Commands.untitle = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Remove the overhead title",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.ragdoll = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Break joints into BallSocketConstraints",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.unragdoll = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Respawn the character to undo ragdoll",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}

-- CoreGui toggles. Optional `state` (true/false). Without it → toggle.
local _coreGuiArgs = {
    { name = "target", type = "Players", default = "me" },
    { name = "state",  type = "Bool", optional = true },
}
Commands.playerlist  = { Category = "Cosmetic", Permission = "Mod", Description = "Toggle the PlayerList CoreGui",  Args = _coreGuiArgs, Log = true }
Commands.backpack    = { Category = "Cosmetic", Permission = "Mod", Description = "Toggle the Backpack CoreGui",    Args = _coreGuiArgs, Log = true }
Commands.emotesmenu  = { Aliases = {"emotemenu", "emotes"}, Category = "Cosmetic", Permission = "Mod", Description = "Toggle the Emotes CoreGui", Args = _coreGuiArgs, Log = true }
Commands.chatwindow  = { Aliases = {"chatbox"},   Category = "Cosmetic", Permission = "Mod", Description = "Toggle the Chat CoreGui",   Args = _coreGuiArgs, Log = true }
Commands.healthbar   = { Category = "Cosmetic", Permission = "Mod", Description = "Toggle the Health CoreGui",      Args = _coreGuiArgs, Log = true }
Commands.captures    = { Category = "Cosmetic", Permission = "Mod", Description = "Toggle the Captures CoreGui",    Args = _coreGuiArgs, Log = true }
Commands.selfview    = { Category = "Cosmetic", Permission = "Mod", Description = "Toggle the SelfView CoreGui",    Args = _coreGuiArgs, Log = true }
Commands.resetbutton = { Category = "Cosmetic", Permission = "Mod", Description = "Enable/disable the reset button", Args = _coreGuiArgs, Log = true }

Commands.talk = {
    Aliases = {"chat"},
    Category = "Cosmetic", Permission = "Admin",
    Description = "Make a player appear to speak in system chat",
    Args = {
        { name = "target", type = "Players" },
        { name = "text",   type = "String", joinRest = true },
    }, Log = true,
}
Commands.bubblechat = {
    Aliases = {"forcebubblechat"},
    Category = "Cosmetic", Permission = "Admin",
    Description = "Render a chat bubble over a player",
    Args = {
        { name = "target", type = "Players" },
        { name = "text",   type = "String", joinRest = true },
    }, Log = true,
}

-- Costume parts.
Commands.korblox    = { Category = "Cosmetic", Permission = "Mod", Description = "Give Korblox parts", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.unkorblox  = { Category = "Cosmetic", Permission = "Mod", Description = "Remove Korblox parts", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.dominus    = { Category = "Cosmetic", Permission = "Mod", Description = "Give a Dominus hat", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.undominus  = { Category = "Cosmetic", Permission = "Mod", Description = "Remove the Dominus hat", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.headless   = { Category = "Cosmetic", Permission = "Mod", Description = "Hide the head + face", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.unheadless = { Category = "Cosmetic", Permission = "Mod", Description = "Restore the head + face", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }

-- Accessory / face granular.
Commands.clearaccessory = { Aliases = {"clearaccessories"}, Category = "Cosmetic", Permission = "Mod", Description = "Strip every accessory", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.accessory = {
    Aliases = {"addhat","sethat"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Give an accessory by asset id",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}
Commands.clearfaces = { Category = "Cosmetic", Permission = "Mod", Description = "Remove every face Decal", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }

-- Morphs.
Commands.character = {
    Aliases = {"char","morph"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Morph into another user's avatar",
    Args = {
        { name = "target",   type = "Players", default = "me" },
        { name = "username", type = "String" },
    }, Log = true,
}
Commands.uncharacter = { Aliases = {"unmorph"}, Category = "Cosmetic", Permission = "Mod", Description = "Reset the morph (respawn)", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }
Commands.bundle = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Apply a Roblox bundle by id",
    Args = {
        { name = "target",   type = "Players", default = "me" },
        { name = "bundleId", type = "Number" },
    }, Log = true,
}
Commands.unbundle = { Category = "Cosmetic", Permission = "Mod", Description = "Reset bundle (respawn)", Args = { { name = "target", type = "Players", default = "me" } }, Log = true }

-- Bundle morphs — Roblox-published Avatar Shop bundles only. The impl in
-- Cosmetic.luau pulls each id from a single table; this loop just stamps
-- metadata so they appear in `cmds` / autocomplete.
local _morphArgs = { { name = "target", type = "Players", default = "me" } }
for _, m in ipairs({
    {"buff",     "Apply the Buff Body bundle"},
    {"chibi",    "Apply the Chibi body bundle"},
    {"frog",     "Apply the Frog animal bundle"},
    {"snowman",  "Apply the Snowman bundle"},
    {"skeleton", "Apply the Skeleton bundle"},
    {"hamster",  "Apply the Hamster animal bundle"},
    {"capybara", "Apply the Capybara animal bundle"},
    {"penguin",  "Apply the Penguin animal bundle"},
    {"duck",     "Apply the Duck animal bundle"},
    {"goose",    "Apply the Goose animal bundle"},
}) do
    Commands[m[1]] = { Category = "Cosmetic", Permission = "Mod", Description = m[2], Args = _morphArgs, Log = true }
end

-- Explicit un* reverts for scaling commands.
local _justTarget = { { name = "target", type = "Players", default = "me" } }
Commands.unsize     = { Category = "Cosmetic", Permission = "Mod", Description = "Reset all body scales to 1", Args = _justTarget, Log = true }
Commands.undwarf    = { Category = "Cosmetic", Permission = "Mod", Description = "Reset from dwarf", Args = _justTarget, Log = true }
Commands.ungiant    = { Category = "Cosmetic", Permission = "Mod", Description = "Reset from giant", Args = _justTarget, Log = true }
Commands.unbodytype = { Category = "Cosmetic", Permission = "Mod", Description = "Reset bodytype scale to 0", Args = _justTarget, Log = true }
Commands.undepth    = { Category = "Cosmetic", Permission = "Mod", Description = "Reset body depth to 1", Args = _justTarget, Log = true }
Commands.unsquash   = { Category = "Cosmetic", Permission = "Mod", Description = "Reset squash to 1", Args = _justTarget, Log = true }
Commands.unwidth    = { Category = "Cosmetic", Permission = "Mod", Description = "Reset width to 1", Args = _justTarget, Log = true }
Commands.unheight   = { Category = "Cosmetic", Permission = "Mod", Description = "Reset height to 1", Args = _justTarget, Log = true }
Commands.unfat      = { Category = "Cosmetic", Permission = "Mod", Description = "Reset from fat", Args = _justTarget, Log = true }
Commands.unthin     = { Category = "Cosmetic", Permission = "Mod", Description = "Reset from thin", Args = _justTarget, Log = true }
Commands.unbighead  = { Category = "Cosmetic", Permission = "Mod", Description = "Reset head to normal", Args = _justTarget, Log = true }

-- Moderation
Commands.kick = {
    Category = "Moderation", Permission = "Admin",
    Description = "Kick with an optional reason",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true, Webhook = true,
}
Commands.kickall = {
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Kick everyone except you",
    Args = { { name = "reason", type = "String", default = "No reason provided", joinRest = true } },
    Log = true, Webhook = true, Confirm = true,
}
Commands.banall = {
    Category = "Moderation", Permission = "Owner",
    Description = "Permanently ban every player below you",
    Args = { { name = "reason", type = "String", default = "No reason provided", joinRest = true } },
    Log = true, Webhook = true, Confirm = true,
}
Commands.tpall = {
    Aliases = {"teleportall"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Bring every other player to one target",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.directBan = {
    Aliases = {"dBan"},
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Permanently ban by username or userId (offline-safe)",
    Args = {
        { name = "target", type = "String" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true, Webhook = true, Confirm = true,
}
Commands.ban = {
    Aliases = {"permBan", "pBan"},
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Permanently ban the player",
    Args = {
        { name = "target", type = "Players" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true, Webhook = true, Confirm = true,
}
Commands.tempban = {
    Aliases = {"timeban"},
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Ban for a set duration",
    Args = {
        { name = "target",   type = "Players" },
        { name = "duration", type = "Duration" },
        { name = "reason",   type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true, Webhook = true, Confirm = true,
}
Commands.unban = {
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Remove an existing player ban",
    Args = { { name = "target", type = "String" } },
    Log = true, Webhook = true,
}
Commands.mute = {
    Category = "Moderation", Permission = "Admin",
    Description = "Permanently mute the player",
    Args = {
        { name = "target", type = "Players" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true,
}
Commands.tempmute = {
    Aliases = {"timeout"},
    Category = "Moderation", Permission = "Admin",
    Description = "Mute for a set duration",
    Args = {
        { name = "target",   type = "Players" },
        { name = "duration", type = "Duration" },
        { name = "reason",   type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true,
}
Commands.unmute = {
    Category = "Moderation", Permission = "Admin",
    Description = "Remove the player's mute",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.muteall = {
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Mute every player at once",
    Args = {}, Log = true, Confirm = true,
}
Commands.warn = {
    Category = "Moderation", Permission = "Mod",
    Description = "Add a warning to the player",
    Args = {
        { name = "target", type = "Players" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    },
    Log = true, Webhook = true,
}
Commands.unwarn = {
    Category = "Moderation", Permission = "Mod",
    Description = "Remove the most recent warning",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.warns = {
    Aliases = {"warnings"},
    Category = "Moderation", Permission = "Mod",
    Description = "Show the player's warning history",
    Args = { { name = "target", type = "Players" } },
    Log = false,
}
Commands.note = {
    Category = "Moderation", Permission = "Mod",
    Description = "Leave an admin note on a player (works offline)",
    Args = {
        { name = "target", type = "String" },
        { name = "text",   type = "String", joinRest = true },
    },
    Log = true,
}
Commands.unnote = {
    Category = "Moderation", Permission = "Mod",
    Description = "Remove a note by index from the player",
    Args = {
        { name = "target", type = "String" },
        { name = "index",  type = "Number", default = 1, min = 1, max = 999 },
    },
    Log = true,
}
Commands.notes = {
    Category = "Moderation", Permission = "Mod",
    Description = "Show all admin notes on a player",
    Args = { { name = "target", type = "String" } },
    Log = false,
}
Commands.unmuteall = {
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Unmute every player at once",
    Args = {}, Log = true,
}
Commands.jail = {
    Category = "Moderation", Permission = "Admin",
    Description = "Local jail cell with timer",
    Args = {
        { name = "target",   type = "Players", default = "me" },
        { name = "duration", type = "Duration", optional = true },
    },
    Log = true,
}
Commands.sendjail = {
    Category = "Moderation", Permission = "Admin",
    Description = "Global jail surviving respawn",
    Args = {
        { name = "target",   type = "Players", default = "me" },
        { name = "duration", type = "Duration", optional = true },
    },
    Log = true,
}
Commands.unjail = {
    Category = "Moderation", Permission = "Admin",
    Description = "Release from any jail type",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}

-- ServerOps
Commands.lock      = { Category = "ServerOps", Permission = "Admin", Description = "Prevent new server joins", Args = {}, Log = true }
Commands.unlock    = { Category = "ServerOps", Permission = "Admin", Description = "Allow new server joins", Args = {}, Log = true }
Commands.pvpon     = { Category = "ServerOps", Permission = "Admin", Description = "Enable PVP for everyone", Args = {}, Log = true }
Commands.pvpoff    = { Category = "ServerOps", Permission = "Admin", Description = "Disable PVP with shields", Args = {}, Log = true }
Commands.lockdown  = { Aliases = {"serverlock"}, Category = "ServerOps", Permission = "HeadAdmin", Description = "Kick non-whitelisted players", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.unlockdown= { Category = "ServerOps", Permission = "HeadAdmin", Description = "Lift the active lockdown", Args = {}, Log = true }
Commands.addlockdown = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Add to the lockdown whitelist",
    Args = { { name = "target", type = "Players" } }, Log = true,
}
Commands.removelockdown = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Remove from the lockdown whitelist",
    Args = { { name = "target", type = "Players" } }, Log = true,
}
Commands.closeserver  = { Category = "ServerOps", Permission = "Owner", Description = "Close the entire server", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.shutdown     = { Category = "ServerOps", Permission = "Owner", Description = "Broadcast and shut down server", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.gshutdown = {
    Aliases = {"globalshutdown", "universalshutdown"},
    Category = "ServerOps", Permission = "Owner",
    Description = "Shut down every running server",
    Args = {}, Log = true, Webhook = true, Confirm = true,
}
Commands.globallockdown = {
    Aliases = {"glockdown", "universallock"},
    Category = "ServerOps", Permission = "Owner",
    Description = "Lock down every running server",
    Args = {}, Log = true, Webhook = true, Confirm = true,
}
Commands.globalunlockdown = {
    Aliases = {"gunlockdown", "universalunlock"},
    Category = "ServerOps", Permission = "Owner",
    Description = "Lift lockdown across all servers",
    Args = {}, Log = true, Webhook = true,
}
Commands.migrate = {
    Aliases = {"updateserver"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Reload this server onto the latest place version",
    Args = {}, Log = true, Webhook = true, Confirm = true,
}
Commands.gmigrate = {
    Aliases = {"globalmigrate", "universalmigrate"},
    Category = "ServerOps", Permission = "Owner",
    Description = "Reload EVERY server onto the latest place version",
    Args = {}, Log = true, Webhook = true, Confirm = true,
}
Commands.clearterrain = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Clear all terrain",
    Args = {}, Log = true, Confirm = true,
}
Commands.colorterrain = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Tint every terrain material",
    Args = { { name = "color", type = "String", joinRest = true } },
    Log = true,
}
Commands.restartserver= { Category = "ServerOps", Permission = "Owner", Description = "Restart into a fresh instance", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.createserver = { Category = "ServerOps", Permission = "Owner", Description = "Reserve a private server", Args = {}, Log = true }
Commands.time = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set the in-game clock time",
    Args = {
        { name = "hour",   type = "Number", default = 12, min = 0, max = 24 },
        { name = "minute", type = "Number", optional = true, min = 0, max = 59 },
    },
    Log = true,
}
Commands.sunrisetime = { Category = "ServerOps", Permission = "Admin", Description = "Set the time to sunrise", Args = {}, Log = true }
Commands.noontime    = { Category = "ServerOps", Permission = "Admin", Description = "Set the time to noon", Args = {}, Log = true }
Commands.sunsettime  = { Category = "ServerOps", Permission = "Admin", Description = "Set the time to sunset", Args = {}, Log = true }
Commands.nighttime   = { Category = "ServerOps", Permission = "Admin", Description = "Set the time to midnight", Args = {}, Log = true }
Commands.brightness = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting brightness 0-10",
    Args = { { name = "amount", type = "Number", default = 2, min = 0, max = 10 } }, Log = true,
}
Commands.ambience = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set ambient color (rgb or #hex)",
    Args = { { name = "color", type = "String", joinRest = true } }, Log = true,
}
Commands.fog = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set FogStart and FogEnd",
    Args = {
        { name = "start",    type = "Number", default = 0, min = 0, max = 10000 },
        { name = "distance", type = "Number", default = 500, min = 1, max = 10000 },
    }, Log = true,
}
Commands.gravity = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set workspace gravity (default 196)",
    Args = { { name = "amount", type = "Number", default = 196, min = 0, max = 1000 } }, Log = true,
}
Commands.ambient = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting.Ambient color",
    Args = { { name = "color", type = "Color" } }, Log = true,
}
Commands.outdoorambient = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting.OutdoorAmbient color",
    Args = { { name = "color", type = "Color" } }, Log = true,
}
Commands.colorshift = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting ColorShift (top + bottom)",
    Args = { { name = "color", type = "Color" } }, Log = true,
}
Commands.exposure = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting exposure compensation (-5..5)",
    Args = { { name = "amount", type = "Number", default = 0, min = -5, max = 5 } }, Log = true,
}
Commands.shadows = {
    Aliases = {"globalshadows"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Toggle Lighting global shadows",
    Args = { { name = "enabled", type = "Bool", default = true } }, Log = true,
}
Commands.fogstart = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting.FogStart",
    Args = { { name = "distance", type = "Number", default = 0, min = 0, max = 100000 } }, Log = true,
}
Commands.fogend = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting.FogEnd",
    Args = { { name = "distance", type = "Number", default = 500, min = 1, max = 100000 } }, Log = true,
}
Commands.diffusescale = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting EnvironmentDiffuseScale 0-1",
    Args = { { name = "scale", type = "Number", default = 1, min = 0, max = 1 } }, Log = true,
}
Commands.specularscale = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting EnvironmentSpecularScale 0-1",
    Args = { { name = "scale", type = "Number", default = 1, min = 0, max = 1 } }, Log = true,
}
Commands.latitude = {
    Aliases = {"geographiclatitude"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting GeographicLatitude (-90..90)",
    Args = { { name = "degrees", type = "Number", default = 41.7, min = -90, max = 90 } }, Log = true,
}
Commands.atmosphere = {
    Aliases = {"airdensity"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Atmosphere density 0-1 (creates one if absent)",
    Args = { { name = "density", type = "Number", default = 0.3, min = 0, max = 1 } }, Log = true,
}
Commands.winddir = {
    Aliases = {"winddirection"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Set GlobalWind direction (keeps current speed)",
    Args = {
        { name = "x", type = "Number", default = 1, min = -1000, max = 1000 },
        { name = "y", type = "Number", default = 0, min = -1000, max = 1000 },
        { name = "z", type = "Number", default = 0, min = -1000, max = 1000 },
    }, Log = true,
}
Commands.windspeed = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set GlobalWind speed (keeps current direction)",
    Args = { { name = "speed", type = "Number", default = 10, min = 0, max = 1000 } }, Log = true,
}
Commands.watercolor = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Terrain water color",
    Args = { { name = "color", type = "Color" } }, Log = true,
}
Commands.waterreflectance = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Terrain water reflectance 0-1",
    Args = { { name = "amount", type = "Number", default = 0, min = 0, max = 1 } }, Log = true,
}
Commands.watertransparency = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Terrain water transparency 0-1",
    Args = { { name = "amount", type = "Number", default = 0.5, min = 0, max = 1 } }, Log = true,
}
Commands.watersize = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Terrain water wave size 0-1",
    Args = { { name = "amount", type = "Number", default = 0.15, min = 0, max = 1 } }, Log = true,
}
Commands.waterspeed = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Terrain water wave speed",
    Args = { { name = "amount", type = "Number", default = 10, min = 0, max = 100 } }, Log = true,
}
Commands.savemap = { Category = "ServerOps", Permission = "Owner", Description = "Snapshot workspace to storage", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.loadmap = { Category = "ServerOps", Permission = "Owner", Description = "Restore the saved snapshot", Args = {}, Log = true, Webhook = true, Confirm = true }
Commands.setteam = {
    Aliases = {"team", "joinTeam"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Assign player to a team",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "team",   type = "Team" },
    },
    Log = true,
}
Commands.createteam = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Create a new player team",
    Args = {
        { name = "name",          type = "String" },
        { name = "color",         type = "Color" },
        { name = "autoAssignable",type = "Bool", default = false },
    },
    Log = true,
}
Commands.removeteam = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Delete a team by name",
    Args = { { name = "name", type = "String", joinRest = true } },
    Log = true,
}
Commands.teamrespawn = {
    Aliases = {"tmrs", "trs", "teamrs"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Respawn every player on a team",
    Args = { { name = "team", type = "Team" } },
    Log = true,
}
Commands.clearteams = {
    Aliases = {"ctm", "cleartm"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Delete every team in the game",
    Args = {},
    Log = true,
}
Commands.editteam = {
    Aliases = {"eteam"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Recolor an existing team",
    Args = {
        { name = "team",  type = "Team" },
        { name = "color", type = "Color" },
    },
    Log = true,
}
Commands.randomizeteams = {
    Aliases = {"randomteams", "rteams", "rteam"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Shuffle all players across the existing teams",
    Args = {},
    Log = true,
}
Commands.editdata = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Open the player data editor (leaderstats + nested values)",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.setstat = {
    Aliases = {"changestat", "change"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Set a leaderstat to a value",
    Args = {
        { name = "target", type = "Players" },
        { name = "stat",   type = "String" },
        { name = "value",  type = "String", joinRest = true },
    },
    Log = true,
}
Commands.addstat = {
    Aliases = {"add"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Add to a numeric leaderstat",
    Args = {
        { name = "target", type = "Players" },
        { name = "stat",   type = "String" },
        { name = "value",  type = "Number" },
    },
    Log = true,
}
Commands.subtractstat = {
    Aliases = {"substat", "substractstat", "subtract"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Subtract from a numeric leaderstat",
    Args = {
        { name = "target", type = "Players" },
        { name = "stat",   type = "String" },
        { name = "value",  type = "Number" },
    },
    Log = true,
}
Commands.resetstats = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Zero every leaderstat on the player",
    Args = { { name = "target", type = "Players" } },
    Log = true, Confirm = true,
}
Commands.giveblock = {
    Aliases = {"gb", "addblock"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Add blocks to a player's BlockInventory",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "block", type = "String", oneOf = {
            "RockBlock", "ConcreteBlock", "IceBlock", "FireBlock", "LavaBlock",
            "ToxicBlock", "GoldBlock", "PlasmaBlock", "CyberBlock", "TitanBlock",
        }},
        { name = "amount", type = "Number", default = 1, min = 1, max = 9999 },
    },
    Log = true, Webhook = true,
}
Commands.giveturret = {
    Aliases = {"gt", "addturret"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Add turrets to a player's BlockInventory",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "turret", type = "String", oneOf = {
            "CameraGuy", "EngineerCameraGuy", "SpeakerGuy", "TvGuy",
            "LargeScientistCameraman", "LargeSpeakerGuy", "LargeTvGuy",
            "LaserCameramanCar", "TitanCameraGuy", "TitanTVMan",
            "TitanSpeakerman", "UpgradedTitanCameraGuy",
        }},
        { name = "amount", type = "Number", default = 1, min = 1, max = 100 },
    },
    Log = true, Webhook = true,
}
Commands.givecash = {
    Aliases = {"gc", "addcash"},
    Category = "ServerOps", Permission = "Admin",
    Description = "Add cash to a player's leaderstats.Cash",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number",  default = 1000, min = 1, max = 1000000 },
    },
    Log = true, Webhook = true,
}
Commands.removestat = {
    Aliases = {"remove"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Remove a single leaderstat by name",
    Args = {
        { name = "target", type = "Players" },
        { name = "stat",   type = "String", joinRest = true },
    },
    Log = true,
}
Commands.setwarp = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Save current position as warp",
    Args = { { name = "name", type = "String", joinRest = true } },
    Log = true,
}
Commands.delwarp = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Delete a named warp point",
    Args = { { name = "name", type = "String", joinRest = true } },
    Log = true,
}
Commands.warps = {
    Aliases = {"listwarps", "warplist"},
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "List every active warp point",
}

-- Teleportation
Commands.teleport = {
    Aliases = {"tp", "to"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Teleport you to the player",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.bring = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Teleport the player to you",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.tpplayer = {
    Aliases = {"tpp"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Move one player to another",
    Args = {
        { name = "from", type = "Players" },
        { name = "to",   type = "String" },  -- resolved on impl side via TargetResolver.resolveSingle
    },
    Log = true,
}
Commands.warp = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Teleport you to saved warp",
    Args = { { name = "name", type = "String", joinRest = true } },
    Log = true,
}
Commands.view = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Lock camera onto the player",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.unview = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Release the locked camera",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.follow = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Cross-server follow another player",
    Args = { { name = "username", type = "String" } },
    Log = true, Webhook = true,
}
Commands.livetrack = {
    Aliases = {"track"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Open a live dashboard for the player",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.unlivetrack = {
    Aliases = {"untrack"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Close the live dashboard for a player",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.unlivetrackall = {
    Aliases = {"untrackall"},
    Category = "Teleportation", Permission = "Admin",
    Description = "Close every active live dashboard",
    Args = {}, Log = true,
}
Commands.rejoin = {
    Category = "Teleportation", Permission = "VIP",
    Description = "Teleport back into this same server",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.join = {
    Category = "Teleportation", Permission = "Admin",
    Description = "Join another player's server (cross-server)",
    Args = { { name = "target", type = "Players" } },
    Log = true, Webhook = true,
}
Commands.place = {
    Aliases = {"forceplace"},
    Category = "Teleportation", Permission = "HeadAdmin",
    Description = "Teleport player(s) to a specific placeId",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "placeId", type = "Number" },
    },
    Log = true, Webhook = true,
}

-- Inventory
Commands.clearinventory = {
    Aliases = {"clearinv"},
    Category = "Inventory", Permission = "Mod",
    Description = "Wipe backpack and equipped tools",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.viewinventory = {
    Category = "Inventory", Permission = "Admin",
    Description = "Open the player backpack viewer",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.viewhats = {
    Category = "Inventory", Permission = "Admin",
    Description = "Open the player hats viewer",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.viewtools = {
    Category = "Inventory", Permission = "Admin",
    Description = "Open the player tools viewer",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.handto = {
    Category = "Inventory", Permission = "Admin",
    Description = "Give your equipped tool to a player",
    Args = { { name = "target", type = "Players" } },
    Log = true,
}
Commands.award = {
    Category = "Utility", Permission = "HeadAdmin",
    Description = "Award a badge by id",
    Args = {
        { name = "target",  type = "Players" },
        { name = "badgeId", type = "Number" },
    },
    Log = true, Webhook = true,
}

-- Messaging
Commands.servermessage       = { Aliases = {"message", "m"}, Category = "Messaging", Permission = "Admin",     Description = "Compose a server-wide message",        Args = {}, Log = true }
Commands.globalservermessage = { Aliases = {"announce", "announcement", "a", "globalAnnouncement", "ga", "broadcast"}, Category = "Messaging", Permission = "HeadAdmin", Description = "Compose a cross-server message",       Args = {}, Log = true, Webhook = true }
Commands.privatemessage      = { Aliases = {"pm"}, Category = "Messaging", Permission = "Admin",     Description = "Compose a direct private message",     Args = { { name = "target", type = "Players" } }, Log = true }
Commands.chatmessage         = { Category = "Messaging", Permission = "Admin",     Description = "Compose a system chat message",        Args = {}, Log = true }
Commands.notifications = {
    Aliases = {"notifyhistory", "nhistory"},
    Category = "Messaging", Permission = "NonAdmin",
    Description = "Open your notification history",
    Args = {}, Log = false,
}
Commands.roleinfo = {
    Aliases = {"roles", "ranks"},
    Category = "Help", Permission = "NonAdmin",
    Description = "Show ranks and their command access",
    Args = {}, Log = false,
}
Commands.sellgamepass = {
    Category = "Messaging", Permission = "Admin",
    Description = "Prompt the player to buy a gamepass",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}
Commands.sellproduct = {
    Category = "Messaging", Permission = "Admin",
    Description = "Prompt the player to buy a developer product",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}
Commands.sellasset = {
    Category = "Messaging", Permission = "Admin",
    Description = "Prompt the player to buy a marketplace asset",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}

-- Check / info commands.
Commands.age = {
    Aliases = {"accountage"},
    Category = "Help", Permission = "Mod",
    Description = "Show account age of the target",
    Args = { { name = "target", type = "Players" } }, Log = false,
}
Commands.countdown = {
    Aliases = {"timer"},
    Category = "Messaging", Permission = "Admin",
    Description = "Broadcast a visible countdown to everyone",
    Args = {
        { name = "seconds", type = "Number", default = 10, min = 1, max = 600 },
        { name = "message", type = "String", default = "Countdown", joinRest = true },
    }, Log = true,
}
Commands.checkban = {
    Aliases = {"isbanned"},
    Category = "Moderation", Permission = "Mod",
    Description = "Look up Roblox ban status for a user",
    Args = { { name = "target", type = "String" } }, Log = false,
}
Commands.checkwarn = {
    Aliases = {"checkwarnings"},
    Category = "Moderation", Permission = "Mod",
    Description = "Show the player's warning history (alias of warns)",
    Args = { { name = "target", type = "Players" } }, Log = false,
}
Commands.checkpermissions = {
    Aliases = {"perms","mycommands"},
    Category = "Help", Permission = "NonAdmin",
    Description = "Open the role-info viewer",
    Args = {}, Log = false,
}

-- Tools.
Commands.speedcoil = {
    Aliases = {"scoil"},
    Category = "Inventory", Permission = "Admin",
    Description = "Give a Speed Coil",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.gravitycoil = {
    Aliases = {"gcoil"},
    Category = "Inventory", Permission = "Admin",
    Description = "Give a Gravity Coil",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}

-- Misc.
Commands.unblur = {
    Category = "Messaging", Permission = "Admin",
    Description = "Clear the player's screen blur",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.commandbar = {
    Aliases = {"cmdbar"},
    Category = "Help", Permission = "VIP",
    Description = "Open the command bar",
    Args = {}, Log = false,
}
Commands.uncommandbar = {
    Aliases = {"uncmdbar"},
    Category = "Help", Permission = "VIP",
    Description = "Close the command bar",
    Args = {}, Log = false,
}

-- Final wave: missing competitor commands.
Commands.clear = {
    Category = "Combat", Permission = "Admin",
    Description = "Wipe clones/nukes/effects from workspace",
    Args = {}, Log = true,
}
Commands.maxhealth = {
    Aliases = {"maxhp"},
    Category = "Combat", Permission = "Mod",
    Description = "Set the target's MaxHealth",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "hp",     type = "Number",  default = 100, min = 1, max = 100000 },
    }, Log = true,
}
Commands.apparate = {
    Aliases = {"warpforward"},
    Category = "Movement", Permission = "Mod",
    Description = "Teleport target forward along its look vector",
    Args = {
        { name = "target",   type = "Players", default = "me" },
        { name = "distance", type = "Number",  default = 8, min = 1, max = 200 },
    }, Log = true,
}
Commands.lockplayer = {
    Category = "Movement", Permission = "Admin",
    Description = "Lock all body parts (BasePart.Locked = true)",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.unlockplayer = {
    Category = "Movement", Permission = "Admin",
    Description = "Unlock all body parts",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.tool = {
    Category = "Inventory", Permission = "Admin",
    Description = "Give a Tool from Storage/Tools by name",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "name",   type = "String",  joinRest = true },
    }, Log = true,
}
Commands.give = {
    Category = "Inventory", Permission = "Admin",
    Description = "Generic tool give (alias of tool)",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "name",   type = "String",  joinRest = true },
    }, Log = true,
}
Commands.removetools = {
    Aliases = {"rtools", "notools", "deltools"},
    Category = "Inventory", Permission = "Mod",
    Description = "Clear Backpack + equipped + StarterGear tools",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.startergive = {
    Aliases = {"sgive"},
    Category = "Inventory", Permission = "Admin",
    Description = "Give a Storage tool that persists across respawns",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "name",   type = "String",  joinRest = true },
    }, Log = true,
}
Commands.starterremove = {
    Aliases = {"sremove", "unstartergive", "unsgive"},
    Category = "Inventory", Permission = "Admin",
    Description = "Remove a tool from the target's StarterGear",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "name",   type = "String",  joinRest = true },
    }, Log = true,
}
Commands.startertools = {
    Aliases = {"starttools", "stools"},
    Category = "Inventory", Permission = "Admin",
    Description = "Give every Storage tool to the target (persistent)",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.tools = {
    Aliases = {"toollist"},
    Category = "Inventory", Permission = "Mod",
    Description = "List the tools available in Storage/Tools",
    Args = {}, Log = false,
}
Commands.gear = {
    Category = "Inventory", Permission = "Admin",
    Description = "Give a marketplace gear by asset id",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}
Commands.rocket = {
    Category = "Inventory", Permission = "Admin",
    Description = "Give a classic Rocket Launcher",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.swag = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Burst-apply a hand-picked pool of accessories",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = true,
}
Commands.checkrank = {
    Aliases = {"playerrank"},
    Category = "Moderation", Permission = "Mod",
    Description = "Show the rank of any player (online or offline)",
    Args = { { name = "target", type = "String" } }, Log = false,
}
Commands.prefix = {
    Category = "Help", Permission = "NonAdmin",
    Description = "Show the current command prefix",
    Args = {}, Log = false,
}
Commands.hint = {
    Aliases = {"h", "serverHint", "sh", "shint"},
    Category = "Messaging", Permission = "Admin",
    Description = "Persistent top banner for all players",
    Args = {
        { name = "duration", type = "Number", default = 8, min = 1, max = 60 },
        { name = "text",     type = "String", joinRest = true },
    }, Log = true,
}
Commands.notice = {
    Aliases = {"notif"},
    Category = "Messaging", Permission = "Admin",
    Description = "Send a quiet notice toast to one player",
    Args = {
        { name = "target", type = "Players" },
        { name = "text",   type = "String", joinRest = true },
    }, Log = true,
}
Commands.restoremap = {
    Category = "ServerOps", Permission = "Owner",
    Description = "Restore the workspace from the original snapshot",
    Args = {}, Log = true, Webhook = true, Confirm = true,
}
-- Page openers — open the panel + switch to a specific tab.
Commands.panel = {
    Category = "Help", Permission = "NonAdmin",
    Description = "Open the admin panel",
    Args = {}, Log = false,
}
Commands.commands = {
    Aliases = {"cmds"},
    Category = "Help", Permission = "NonAdmin",
    Description = "Open the Commands page",
    Args = {}, Log = false,
}
Commands.settings = {
    Aliases = {"preferences", "config"},
    Category = "Help", Permission = "NonAdmin",
    Description = "Open the Settings page",
    Args = {}, Log = false,
}
Commands.logs = {
    Aliases = {"auditlogs", "chatLogs", "clogs", "banland", "banlist", "commandLogs"},
    Category = "Help", Permission = "Mod",
    Description = "Open the Logs page",
    Args = {}, Log = false,
}
Commands.manager = {
    Aliases = {"players"},
    Category = "Help", Permission = "Mod",
    Description = "Open the Players page",
    Args = {}, Log = false,
}

-- Action / messaging extras.
Commands.alert = {
    Category = "Messaging", Permission = "HeadAdmin",
    Description = "High-priority alert banner to every client",
    Args = { { name = "text", type = "String", joinRest = true } },
    Log = true, Webhook = true,
}
Commands.systemMessage = {
    Aliases = {"sm"},
    Category = "Messaging", Permission = "Admin",
    Description = "System-style chat broadcast",
    Args = { { name = "text", type = "String", joinRest = true } },
    Log = true,
}
Commands.countdown2 = {
    Aliases = {"timer2"},
    Category = "Messaging", Permission = "Admin",
    Description = "T-minus style countdown banner",
    Args = {
        { name = "seconds", type = "Number", default = 10, min = 1, max = 600 },
        { name = "message", type = "String", default = "Time", joinRest = true },
    }, Log = true,
}
Commands.crash = {
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Force-disconnect a player",
    Args = { { name = "target", type = "Players" } }, Log = true, Webhook = true, Confirm = true,
}
Commands.globalAlert = {
    Category = "Messaging", Permission = "Owner",
    Description = "Cross-server alert broadcast",
    Args = { { name = "text", type = "String", joinRest = true } },
    Log = true, Webhook = true,
}
Commands.punish = {
    Category = "Moderation", Permission = "Mod",
    Description = "Soft strike: warn + 15-min mute",
    Args = {
        { name = "target", type = "Players" },
        { name = "reason", type = "String", default = "No reason provided", joinRest = true },
    }, Log = true, Webhook = true,
}
Commands.shine    = { Category = "Cosmetic", Permission = "Mod", Description = "Neon + reflectance shine", Args = _justTarget, Log = true }
Commands.head = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Apply a head accessory by asset id",
    Args = {
        { name = "target",  type = "Players", default = "me" },
        { name = "assetId", type = "Number" },
    }, Log = true,
}
Commands.potatoHead = { Category = "Cosmetic", Permission = "Mod", Description = "Replace head with the Potato mesh", Args = _justTarget, Log = true }
Commands.giantDwarf = { Category = "Cosmetic", Permission = "Mod", Description = "Random size between 0.5x and 5x", Args = _justTarget, Log = true }
Commands.boost = {
    Category = "Movement", Permission = "Mod",
    Description = "Speed + jump composite buff",
    Args = _justTarget, Log = true,
}
Commands.nightVision = {
    Aliases = {"nv"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Enable green night-vision overlay on the player",
    Args = _justTarget, Log = true,
}
Commands.unNightVision = {
    Aliases = {"unnv"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Disable night-vision overlay",
    Args = _justTarget, Log = true,
}
Commands.laserEyes = {
    Aliases = {"le", "lazerEyes"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Beam eyes with optional color",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "color",  type = "String", default = "#FF1E1E", joinRest = true },
    }, Log = true,
}
Commands.unLaserEyes = {
    Aliases = {"unle"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Remove the red laser eyes",
    Args = _justTarget, Log = true,
}
Commands.emote = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Play an equipped emote by name or asset id",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "emote",  type = "String", joinRest = true },
    }, Log = true,
}
Commands.danceAndBundleReset = {
    Category = "Cosmetic", Permission = "Mod",
    Description = "Reload the player's character (clears dance/bundle morphs)",
    Args = _justTarget, Log = true,
}
Commands.globalVote = {
    Aliases = {"gv", "gVote", "globalPoll", "gPoll", "gp"},
    Category = "Messaging", Permission = "HeadAdmin",
    Description = "Open the vote launcher with global-mode pre-checked",
    Args = {}, Log = true,
}
Commands.chatTag = {
    Aliases = {"ctag"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set a custom chat tag prefix",
    Args = {
        { name = "target", type = "Players" },
        { name = "tag",    type = "String", joinRest = true },
    }, Log = true,
}
Commands.chatTagColor = {
    Aliases = {"tagColor"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set chat tag color (#hex or named)",
    Args = {
        { name = "target", type = "Players" },
        { name = "color",  type = "String", joinRest = true },
    }, Log = true,
}
Commands.chatName = {
    Aliases = {"cname"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Override the player's chat display name",
    Args = {
        { name = "target", type = "Players" },
        { name = "name",   type = "String", joinRest = true },
    }, Log = true,
}
Commands.chatNameColor = {
    Aliases = {"nameColor"},
    Category = "Cosmetic", Permission = "Mod",
    Description = "Set chat display name color (#hex or named)",
    Args = {
        { name = "target", type = "Players" },
        { name = "color",  type = "String", joinRest = true },
    }, Log = true,
}
Commands.control = {
    Category = "Movement", Permission = "HeadAdmin",
    Description = "Take over the target's character body (puppet)",
    Args = { { name = "target", type = "Players" } }, Log = true, Webhook = true,
}
Commands.uncontrol = {
    Category = "Movement", Permission = "HeadAdmin",
    Description = "Release the current control / puppet",
    Args = {}, Log = true,
}
Commands.chatHijacker = {
    Aliases = {"spychat"},
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Silently spy on a player's chat messages",
    Args = { { name = "target", type = "Players" } }, Log = true, Webhook = true,
}
Commands.unchathijack = {
    Aliases = {"unspychat"},
    Category = "Moderation", Permission = "HeadAdmin",
    Description = "Stop spying on a player's chat",
    Args = { { name = "target", type = "Players" } }, Log = true,
}
Commands.lockMap = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Anchor and lock every BasePart in workspace",
    Args = {}, Log = true, Confirm = true,
}
Commands.insert = {
    Category = "ServerOps", Permission = "HeadAdmin",
    Description = "Insert a marketplace asset into workspace",
    Args = { { name = "assetId", type = "Number" } }, Log = true,
}
Commands.globalPlace = {
    Category = "ServerOps", Permission = "Owner",
    Description = "Cross-server teleport one player to a placeId",
    Args = {
        { name = "target",  type = "Players" },
        { name = "placeId", type = "Number" },
    }, Log = true, Webhook = true,
}
Commands.globalForcePlace = {
    Category = "ServerOps", Permission = "Owner",
    Description = "Cross-server teleport multiple players by name to a placeId",
    Args = {
        { name = "placeId", type = "Number" },
        { name = "names",   type = "String", joinRest = true },
    }, Log = true, Webhook = true,
}
Commands.fogColor = {
    Category = "ServerOps", Permission = "Admin",
    Description = "Set Lighting.FogColor (rgb or #hex)",
    Args = { { name = "color", type = "String", joinRest = true } }, Log = true,
}
Commands.superJump = {
    Category = "Movement", Permission = "Mod",
    Description = "Mega jump height (200)",
    Args = _justTarget, Log = true,
}
Commands.heavyJump = {
    Category = "Movement", Permission = "Mod",
    Description = "Heavy-feeling boosted jump (100)",
    Args = _justTarget, Log = true,
}
Commands.fast = {
    Category = "Movement", Permission = "Mod",
    Description = "Quick walkspeed (50)",
    Args = _justTarget, Log = true,
}
Commands.slow = {
    Category = "Movement", Permission = "Mod",
    Description = "Half walkspeed (6)",
    Args = _justTarget, Log = true,
}
Commands.fly2 = {
    Category = "Movement", Permission = "Mod",
    Description = "Alternate fly variant",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number", default = 75, min = 1, max = 500 },
    }, Log = true,
}
Commands.noclip2 = {
    Category = "Movement", Permission = "Mod",
    Description = "Alternate noclip variant",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "speed",  type = "Number", default = 75, min = 1, max = 500 },
    }, Log = true,
}
Commands.vote                = { Category = "Messaging", Permission = "HeadAdmin", Description = "Open the vote launcher menu",          Args = {}, Log = true }
Commands.ping                = { Category = "Messaging", Permission = "Admin",     Description = "Show the player network ping",         Args = { { name = "target", type = "Players" } }, Log = true }
Commands.radio = {
    Category = "Messaging", Permission = "Admin",
    Description = "Give a portable BoomBox tool",
    Args = { { name = "target", type = "Players", default = "me" } },
    Log = true,
}
Commands.blur = {
    Category = "Messaging", Permission = "Admin",
    Description = "Blur the player's screen",
    Args = {
        { name = "target", type = "Players", default = "me" },
        { name = "amount", type = "Number",  default = 12, min = 0, max = 56 },
    },
    Log = true,
}

-- Help
Commands.help = {
    Aliases = {"?"},
    Category = "Help", Permission = "NonAdmin",
    Description = "Show command usage or list all",
    Args = { { name = "query", type = "String", optional = true, joinRest = true } },
    Log = false,
}

-- Utility
Commands.sound = {
    Category = "Utility", Permission = "VIP",
    Description = "Play a sound by asset ID",
    Args = { { name = "asset", type = "AssetId" } },
    Log = true,
}
Commands.stopsound = {
    Category = "Utility", Permission = "VIP",
    Description = "Stop a specific active sound",
    Args = { { name = "asset", type = "AssetId" } },
    Log = true,
}
Commands.pitch = {
    Aliases = {"playbackSpeed"},
    Category = "Utility", Permission = "VIP",
    Description = "Set playback pitch of all active sounds",
    Args = { { name = "pitch", type = "Number", default = 1, min = 0.1, max = 10 } },
    Log = true,
}
Commands.volume = {
    Aliases = {"loudness"},
    Category = "Utility", Permission = "VIP",
    Description = "Set volume of all active sounds",
    Args = { { name = "volume", type = "Number", default = 0.5, min = 0, max = 10 } },
    Log = true,
}
Commands.pause = {
    Aliases = {"pausemusic"},
    Category = "Utility", Permission = "VIP",
    Description = "Pause all active sounds (keeps position)",
    Args = {}, Log = true,
}
Commands.resume = {
    Aliases = {"resumemusic"},
    Category = "Utility", Permission = "VIP",
    Description = "Resume paused sounds",
    Args = {}, Log = true,
}
Commands.stopallsounds = {
    Aliases = {"stop", "stopmusic", "musicoff"},
    Category = "Utility", Permission = "VIP",
    Description = "Stop every active sound effect",
    Args = {},
    Log = true,
}
Commands.whois = {
    Aliases = {"userinfo"},
    Category = "Utility", Permission = "Mod",
    Description = "Show a player's userId, rank, and account age",
    Args = { { name = "target", type = "Players" } }, Log = false,
}
Commands.playercount = {
    Aliases = {"plrcount", "countplayers", "countplrs"},
    Category = "Utility", Permission = "Mod",
    Description = "Show the current player count",
    Args = {}, Log = false,
}
Commands.serverage = {
    Aliases = {"uptime"},
    Category = "Utility", Permission = "Mod",
    Description = "Show how long this server has been running",
    Args = {}, Log = false,
}
Commands.gameid = {
    Category = "Utility", Permission = "Mod",
    Description = "Show the GameId (universe id)",
    Args = {}, Log = false,
}
Commands.jobid = {
    Category = "Utility", Permission = "Mod",
    Description = "Show this server's JobId",
    Args = {}, Log = false,
}
Commands.placeid = {
    Category = "Utility", Permission = "Mod",
    Description = "Show the PlaceId",
    Args = {}, Log = false,
}
Commands.showfps = {
    Aliases = {"getfps", "checkfps", "playerfps"},
    Category = "Utility", Permission = "Mod",
    Description = "Measure and report a player's FPS",
    Args = { { name = "target", type = "Players", default = "me" } }, Log = false,
}
Commands.setproperty = {
    Aliases = {"setprop"},
    Category = "Utility", Permission = "Owner",
    Description = "Set an instance property by path",
    Args = {
        { name = "path",     type = "String" },
        { name = "property", type = "String" },
        { name = "value",    type = "String", joinRest = true },
    },
    Log = true, Webhook = true,
}
Commands.getproperty = {
    Aliases = {"getprop"},
    Category = "Utility", Permission = "HeadAdmin",
    Description = "Read an instance property by path",
    Args = {
        { name = "path",     type = "String" },
        { name = "property", type = "String" },
    },
    Log = false,
}
Commands.loop = {
    Category = "Utility", Permission = "Admin",
    Description = "Repeat a command every <delay> seconds",
    Args = {
        { name = "delay",   type = "Number", default = 1, min = 0.25, max = 3600 },
        { name = "command", type = "String", joinRest = true },
    },
    Log = true,
}
Commands.unloop = {
    Category = "Utility", Permission = "Admin",
    Description = "Stop the loop for a specific command",
    Args = { { name = "command", type = "String", joinRest = true } },
    Log = true,
}
Commands.unloopall = {
    Category = "Utility", Permission = "Admin",
    Description = "Stop every active loop you own",
    Args = {},
    Log = true,
}

-- Rank management
Commands.rank = {
    Aliases = {"serverrank", "temprank", "temporaryrank"},
    Category = "Rank", Permission = "Owner",
    Description = "Assign a temporary runtime rank",
    Args = {
        { name = "target", type = "Players" },
        { name = "rank",   type = "Rank" },
    },
    Log = true, Webhook = true,
}
Commands.permrank = {
    Category = "Rank", Permission = "Owner",
    Description = "Assign a persistent saved rank",
    Args = {
        { name = "target", type = "Players" },
        { name = "rank",   type = "Rank" },
    },
    Log = true, Webhook = true,
}
Commands.unrank = {
    Category = "Rank", Permission = "Owner",
    Description = "Clear the runtime rank override",
    Args = { { name = "target", type = "Players" } },
    Log = true, Webhook = true,
}
Commands.unpermrank = {
    Category = "Rank", Permission = "Owner",
    Description = "Clear the persistent rank override",
    Args = { { name = "target", type = "Players" } },
    Log = true, Webhook = true,
}

-- Auto-fill convenience fields so consumers can pass `cmd` around without
-- knowing the key. CommandText is synthesised from Args (`<name>` for required,
-- `[name=default]` for defaulted, `[name]` for optional).
local function synthText(name, args)
    local parts = { name }
    for _, a in ipairs(args or {}) do
        if a.default ~= nil then
            table.insert(parts, ("[%s=%s]"):format(a.name, tostring(a.default)))
        elseif a.optional then
            table.insert(parts, ("[%s]"):format(a.name))
        else
            table.insert(parts, ("<%s>"):format(a.name))
        end
    end
    return table.concat(parts, " ")
end

for name, def in pairs(Commands) do
    def.Name        = name
    def.CommandText = def.CommandText or synthText(name, def.Args)
end

-- Quiet flag: suppresses the dispatcher's auto-success "✓ <cmd>" toast for
-- commands that already provide their own UI feedback (modal, banner, rich
-- per-command notify). Without this they'd double-toast on every run. The
-- generic toast still fires for everything else — cosmetic effects, scale
-- changes, teleports, etc — so admins always get a confirmation.
local QUIET = {
    -- Page / modal openers (visual is the feedback)
    "panel", "commands", "cmds", "settings", "logs", "manager", "help",
    "roleinfo", "ranks", "roles", "checkpermissions", "perms",
    "notifications", "nhistory", "notifyhistory",
    "editdata", "viewinventory", "viewhats", "viewtools",
    "skybox", "vote", "view", "unview",
    "livetrack", "unlivetrack", "unlivetrackall",
    "commandbar", "uncommandbar",
    "servermessage", "globalservermessage", "privatemessage", "chatmessage",
    -- Broadcasts (target = everyone; actor doesn't need self-confirm)
    "hint", "alert", "countdown", "countdown2", "globalAlert", "systemMessage",
    -- Self-notifying (impl emits its own richer notify)
    "note", "unnote", "notes",
    "warn", "unwarn", "warns", "checkwarn",
    "checkban", "checkrank", "age", "prefix", "ping",
    "clear", "removeall", "fix",
    "setproperty", "getproperty",
    "loop", "unloop", "unloopall",
    "restoremap", "lockMap", "insert", "warps",
    "setstat", "addstat", "subtractstat", "removestat", "resetstats", "givecash", "giveturret", "giveblock",
    "control", "uncontrol", "chatHijacker", "unchathijack", "punish",
    "korblox",  -- impl has own success notify
}
for _, n in ipairs(QUIET) do
    if Commands[n] then Commands[n].Quiet = true end
end

return Commands

--!nocheck

local out = {}
local function merge(src)
    for name, fn in pairs(src) do
        if out[name] then
            warn(("[uxrAPS v5] duplicate command impl '%s' — second registration wins"):format(name))
        end
        out[name] = fn
    end
end

merge(require(script.Movement))
merge(require(script.Cosmetic))
merge(require(script.Combat))
merge(require(script.Moderation))
merge(require(script.ServerOps))
merge(require(script.Teleportation))
merge(require(script.Inventory))
merge(require(script.Messaging))
merge(require(script.RankCommands))
merge(require(script.Utility))
merge(require(script.Help))

return out

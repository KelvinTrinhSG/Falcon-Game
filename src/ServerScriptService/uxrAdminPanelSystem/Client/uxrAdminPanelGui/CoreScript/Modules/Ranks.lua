--!nocheck

local Ranks = {}

function Ranks.init(ctx)
    local UtilModule  = ctx.UtilModule
    local Permissions = ctx.Permissions
    local LocalPlayer = ctx.LocalPlayer

    local myRank   = UtilModule:GetRank(LocalPlayer)
    local nonAdmin = UtilModule.GetRankByName("NonAdmin")

    local function rankByName(name)
        return UtilModule.GetRankByName(name) or nonAdmin
    end

    local function getCommandRank(cmd)
        local cp = cmd.Permission or cmd.CommandPermission
        if type(cp) == "string" then return rankByName(cp) end
        if type(cp) == "table" and #cp > 0 then
            local best
            for _, name in ipairs(cp) do
                local r = rankByName(name)
                if r and (not best or r.Level < best.Level) then best = r end
            end
            return best or rankByName("Mod")
        end
        return rankByName("Mod")
    end

    return {
        myRank         = myRank,
        nonAdmin       = nonAdmin,
        rankByName     = rankByName,
        getCommandRank = getCommandRank,
    }
end

return Ranks

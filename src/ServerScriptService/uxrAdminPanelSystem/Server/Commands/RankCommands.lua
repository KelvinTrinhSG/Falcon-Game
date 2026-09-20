--!nocheck

local S = require(script.Parent._shared)
local UtilModule = S.UtilModule

return {
    rank = function(ctx, args)
        UtilModule:SetRuntimeRank(args.target.UserId, args.rank)
    end,
    permrank = function(ctx, args)
        UtilModule:SetPermRank(args.target.UserId, args.rank)
    end,
    unrank = function(ctx, args)
        UtilModule:SetRuntimeRank(args.target.UserId, nil)
    end,
    unpermrank = function(ctx, args)
        UtilModule:SetPermRank(args.target.UserId, nil)
    end,
}

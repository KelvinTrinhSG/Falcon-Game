--!nocheck

local StatsHelpers = {}

function StatsHelpers.setStat(card, title, count, useRichText)
    if not card then return end
    local t = card:FindFirstChild("TitleTextLabel")
    local c = card:FindFirstChild("CountTextLabel")
    if t and title ~= nil then t.Text = title end
    if c and count ~= nil then
        if useRichText then c.RichText = true end
        c.Text = tostring(count)
    end
end

function StatsHelpers.countAdmins(ctx)
    local n = 0
    for _, p in ipairs(ctx.Players:GetPlayers()) do
        local r = ctx.UtilModule:GetRank(p)
        if r and r.Level > 0 then n += 1 end
    end
    return n
end

return StatsHelpers

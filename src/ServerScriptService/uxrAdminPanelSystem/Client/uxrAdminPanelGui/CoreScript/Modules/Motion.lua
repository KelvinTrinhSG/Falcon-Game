--!nocheck
local Motion = {}

Motion.info       = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
Motion.quick      = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)
Motion.smooth     = TweenInfo.new(1.0, Enum.EasingStyle.Exponential)
Motion.info_2     = TweenInfo.new(0.8, Enum.EasingStyle.Exponential)
Motion.back       = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
Motion.long_back  = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
Motion.processing = TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
Motion.pulsating  = TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 1)
Motion.two_rev    = TweenInfo.new(1.0, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true)

local TweenService = game:GetService("TweenService")
function Motion.tween(inst, presetName, goals)
    return TweenService:Create(inst, Motion[presetName] or Motion.info, goals)
end

return Motion

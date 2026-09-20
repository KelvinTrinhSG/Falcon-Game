--!nocheck

local TweenService = game:GetService("TweenService")

local Animations = {}

local OPEN_TI  = TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TI = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local FADE_TI  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_TI = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SHRUNK_SCALE = 0.92

local baseScale = 1
local deviceScale = 1
local function effective() return baseScale * deviceScale end

local function getUIScale(mainFrame)
    local s = mainFrame:FindFirstChild("PanelScale")
              or mainFrame:FindFirstChildOfClass("UIScale")
    if not s then
        s = Instance.new("UIScale")
        s.Name = "PanelScale"
        s.Scale = baseScale
        s.Parent = mainFrame
    end
    return s
end

local function panelOpen(screen, mainFrame)
    local uiScale = getUIScale(mainFrame)
    screen.Enabled = true
    uiScale.Scale = effective() * SHRUNK_SCALE
    TweenService:Create(uiScale, OPEN_TI, { Scale = effective() }):Play()
end

local function panelClose(screen, mainFrame)
    local uiScale = getUIScale(mainFrame)
    local t = TweenService:Create(uiScale, CLOSE_TI, { Scale = effective() * SHRUNK_SCALE })
    t:Play()
    t.Completed:Connect(function()
        screen.Enabled = false
        uiScale.Scale = effective()
    end)
end

function Animations.setScreenEnabled(screen, mainFrame, _origSize, value)
    if value == screen.Enabled then return end
    if value then panelOpen(screen, mainFrame)
    else          panelClose(screen, mainFrame) end
end

function Animations.toggleScreen(screen, mainFrame, origSize)
    Animations.setScreenEnabled(screen, mainFrame, origSize, not screen.Enabled)
end

local FULLSCREEN_TI = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
function Animations.setBaseScale(mainFrame, newBase)
    baseScale = newBase
    local uiScale = getUIScale(mainFrame)
    TweenService:Create(uiScale, FULLSCREEN_TI, { Scale = effective() }):Play()
end
function Animations.getBaseScale()
    return baseScale
end
function Animations.setDeviceScale(mainFrame, ds)
    deviceScale = ds
    getUIScale(mainFrame).Scale = effective()
end

local POPUP_SHRUNK = 0.94
function Animations.setPopupVisible(popup, origSize, value)
    if value == popup.Visible then return end
    if value then
        popup.Visible = true
        popup.Size = UDim2.new(
            origSize.X.Scale * POPUP_SHRUNK, origSize.X.Offset * POPUP_SHRUNK,
            origSize.Y.Scale * POPUP_SHRUNK, origSize.Y.Offset * POPUP_SHRUNK
        )
        TweenService:Create(popup, OPEN_TI, { Size = origSize }):Play()
    else
        local shrunk = UDim2.new(
            origSize.X.Scale * POPUP_SHRUNK, origSize.X.Offset * POPUP_SHRUNK,
            origSize.Y.Scale * POPUP_SHRUNK, origSize.Y.Offset * POPUP_SHRUNK
        )
        local t = TweenService:Create(popup, CLOSE_TI, { Size = shrunk })
        t:Play()
        t.Completed:Connect(function()
            popup.Visible = false
            popup.Size = origSize
        end)
    end
end

function Animations.tween(instance, goal, ti)
    TweenService:Create(instance, ti or HOVER_TI, goal):Play()
end

Animations.OPEN_TI  = OPEN_TI
Animations.CLOSE_TI = CLOSE_TI
Animations.FADE_TI  = FADE_TI
Animations.HOVER_TI = HOVER_TI

local PADDING = 150
function Animations.openFromSource(modal, sourceGuiObject, targetPos, targetSize)
    if not (sourceGuiObject and modal) then return end
    local srcAbsPos  = sourceGuiObject.AbsolutePosition
    local srcAbsSize = sourceGuiObject.AbsoluteSize

    local startSize = UDim2.fromOffset(srcAbsSize.X + PADDING, srcAbsSize.Y + PADDING)
    local startPos  = UDim2.fromOffset(
        srcAbsPos.X + srcAbsSize.X * 0.5 - (srcAbsSize.X + PADDING) * 0.5,
        srcAbsPos.Y + srcAbsSize.Y * 0.5 - (srcAbsSize.Y + PADDING) * 0.5
    )
    modal.Size     = startSize
    modal.Position = startPos
    modal.Visible  = true
    if modal:IsA("CanvasGroup") then modal.GroupTransparency = 1 end

    local sizeTween = TweenService:Create(modal, OPEN_TI, { Size = targetSize })
    local posTween  = TweenService:Create(modal, OPEN_TI, { Position = targetPos })
    sizeTween:Play(); posTween:Play()
    if modal:IsA("CanvasGroup") then
        TweenService:Create(modal, OPEN_TI, { GroupTransparency = 0 }):Play()
    end
end

return Animations

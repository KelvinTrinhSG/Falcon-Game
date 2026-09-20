--!nocheck

local Theme = {}

Theme.gray1  = Color3.fromRGB( 20,  20,  20)
Theme.gray2  = Color3.fromRGB( 25,  25,  25)
Theme.gray3  = Color3.fromRGB( 27,  27,  27)
Theme.gray4  = Color3.fromRGB( 34,  34,  34)
Theme.gray5  = Color3.fromRGB( 47,  47,  47)
Theme.gray6  = Color3.fromRGB( 48,  48,  48)
Theme.gray7  = Color3.fromRGB( 55,  55,  55)
Theme.gray8  = Color3.fromRGB( 56,  56,  56)
Theme.gray9  = Color3.fromRGB( 65,  65,  65)
Theme.gray10 = Color3.fromRGB( 88,  88,  88)
Theme.gray11 = Color3.fromRGB(104, 102, 103)

Theme.white  = Color3.fromRGB(255, 255, 255)

Theme.success  = Color3.fromRGB( 26, 188, 156)
Theme.warning  = Color3.fromRGB(241, 196,  15)
Theme.danger   = Color3.fromRGB(239,  35,  60)

Theme.themes = {
    Slate   = { primary = Color3.fromRGB(  0, 140, 255), glyph = "" },
    Blurple = { primary = Color3.fromRGB( 88, 101, 242), glyph = "" },
    Red     = { primary = Color3.fromRGB(239,  35,  60), glyph = "" },
    Orange  = { primary = Color3.fromRGB(255, 135,   0), glyph = "" },
    Green   = { primary = Color3.fromRGB( 46, 204, 113), glyph = "" },
    Pink    = { primary = Color3.fromRGB(232,  62, 140), glyph = "" },
    Purple  = { primary = Color3.fromRGB(155,  89, 182), glyph = "" },
    Mono    = { primary = Color3.fromRGB(200, 200, 200), glyph = "" },
}

Theme.themeOrder = { "Slate", "Blurple", "Red", "Orange", "Green", "Pink", "Purple", "Mono" }

local currentName = "Slate"
Theme.primary = Theme.themes.Slate.primary

Theme.changed = Instance.new("BindableEvent")

function Theme.current()
    return currentName
end

function Theme.set(name)
    local def = Theme.themes[name]
    if not def then
        warn("[Theme] unknown theme: "..tostring(name))
        return false
    end
    currentName = name
    Theme.primary = def.primary
    Theme.changed:Fire(name, def)
    return true
end

local function isBright(c)
    return (c.R * 0.299 + c.G * 0.587 + c.B * 0.114) > 0.5
end

function Theme.adjust(color, delta)
    delta = delta or 0.3
    local sign = isBright(color) and -1 or 1
    local r = math.clamp(color.R + sign * delta, 0, 1)
    local g = math.clamp(color.G + sign * delta, 0, 1)
    local b = math.clamp(color.B + sign * delta, 0, 1)
    return Color3.new(r, g, b)
end

function Theme.specular(color, hiFactor, shadowFactor)
    hiFactor     = hiFactor or 1.4
    shadowFactor = shadowFactor or 0.3
    local hi = Color3.new(
        math.clamp(color.R * hiFactor, 0, 1),
        math.clamp(color.G * hiFactor, 0, 1),
        math.clamp(color.B * hiFactor, 0, 1)
    )
    local sh = Color3.new(color.R * shadowFactor, color.G * shadowFactor, color.B * shadowFactor)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,   hi),
        ColorSequenceKeypoint.new(0.5, sh),
        ColorSequenceKeypoint.new(1,   hi),
    })
end

return Theme

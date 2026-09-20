--!nocheck

local Templates = {}

function Templates.getTemplate(scrollingFrame)
    local grid = scrollingFrame:FindFirstChildOfClass("UIGridLayout")
    if not grid then return nil end
    local tpl = grid:FindFirstChild("TemplateFrame")
    if tpl and not tpl:GetAttribute("uxrKeepInvisible") then
        tpl.Visible = false
        tpl:SetAttribute("uxrKeepInvisible", true)
    end
    return tpl
end

function Templates.clearList(scrollingFrame)
    for _, c in ipairs(scrollingFrame:GetChildren()) do
        if not (c:IsA("UIGridLayout") or c:IsA("UIListLayout") or c:IsA("UIPadding")) then
            c:Destroy()
        end
    end
end

function Templates.cloneTemplate(scrollingFrame)
    local tpl = Templates.getTemplate(scrollingFrame)
    if not tpl then return nil end
    local clone = tpl:Clone()
    clone.Visible = true
    clone.Parent = scrollingFrame
    return clone
end

function Templates.safeText(inst, name, value)
    if not inst then return end
    local node = inst:FindFirstChild(name)
    if node and (node:IsA("TextLabel") or node:IsA("TextBox") or node:IsA("TextButton")) then
        node.Text = tostring(value)
    end
end

function Templates.safeRichText(inst, name, value)
    if not inst then return end
    local node = inst:FindFirstChild(name)
    if node and (node:IsA("TextLabel") or node:IsA("TextBox") or node:IsA("TextButton")) then
        node.RichText = true
        node.Text = tostring(value)
    end
end

return Templates

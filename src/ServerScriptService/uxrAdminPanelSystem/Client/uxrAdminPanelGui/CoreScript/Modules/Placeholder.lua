--!nocheck

local Placeholder = {}

function Placeholder.bindPlaceholder(textBox)
    if not textBox then return end
    local parent = textBox.Parent
    if not parent then return end
    local label = parent:FindFirstChild("SearchTextLabel")
                or parent:FindFirstChild("TypeLabel")
    if not label then return end
    local function update()
        label.Visible = (textBox.Text == "" and not textBox:IsFocused())
    end
    update()
    textBox.Focused:Connect(function() label.Visible = false end)
    textBox.FocusLost:Connect(update)
    textBox:GetPropertyChangedSignal("Text"):Connect(update)
end

function Placeholder.wireAll(ctx)
    local pages = ctx.pages
    Placeholder.bindPlaceholder(ctx.searchFrame:FindFirstChild("SearchTextBox"))
    Placeholder.bindPlaceholder(pages.Players.SearchFrame.SearchTextBox)
    Placeholder.bindPlaceholder(pages.Commands.SearchFrame.SearchTextBox)
    Placeholder.bindPlaceholder(pages.Servers.SearchFrame.SearchTextBox)
    Placeholder.bindPlaceholder(pages.Logs.SearchFrame.SearchTextBox)
    Placeholder.bindPlaceholder(ctx.commandFrame.SearchFrame.SearchTextBox)
    Placeholder.bindPlaceholder(pages.Chat.TextFrame.ChatTextBox)
end

return Placeholder

--!nocheck

local MessagingService = game:GetService("MessagingService")

local Secret = require(script.Parent.SharedSecret)

local CrossServer = {}

function CrossServer.publish(topic, data)
    if type(topic) ~= "string" or topic == "" then return end
    local envelope = {
        secret = Secret.value,
        origin = game.JobId,
        data   = data or {},
    }
    local ok, err = pcall(function()
        MessagingService:PublishAsync(topic, envelope)
    end)
    if not ok then
        warn(("[uxrAPS] publish %s failed: %s"):format(topic, tostring(err)))
    end
    return ok
end

function CrossServer.subscribe(topic, handler)
    if type(topic) ~= "string" or topic == "" then return end
    if type(handler) ~= "function" then return end
    task.spawn(function()
        local ok, err = pcall(function()
            MessagingService:SubscribeAsync(topic, function(message)
                local env = message.Data
                if type(env) ~= "table" then return end
                if env.secret ~= Secret.value then
                    warn(("[uxrAPS] dropped unsigned %s payload"):format(topic))
                    return
                end
                handler(env.data or {}, env.origin)
            end)
        end)
        if not ok then
            warn(("[uxrAPS] subscribe %s failed: %s"):format(topic, tostring(err)))
        end
    end)
end

return CrossServer

--!nocheck

local CommandRegistry = require(script.Parent.CommandRegistry)

local Builder = {}
Builder.__index = Builder

local function newBuilder(name)
    return setmetatable({
        _def = {
            Name        = tostring(name),
            Aliases     = {},
            Permission  = "Mod",
            Category    = "Custom",
            Description = "",
            Args        = {},
            Log         = true,
            Webhook     = false,
            Confirm     = false,
        },
        _finalized = false,
    }, Builder)
end

function Builder:alias(...)
    for _, a in ipairs({ ... }) do
        table.insert(self._def.Aliases, tostring(a))
    end
    return self
end

function Builder:perm(rankName)
    self._def.Permission = tostring(rankName)
    return self
end

function Builder:category(cat)
    self._def.Category = tostring(cat)
    return self
end

function Builder:desc(text)
    self._def.Description = tostring(text)
    return self
end

function Builder:arg(name, typeName, opts)
    local spec = { name = tostring(name), type = tostring(typeName) }
    if type(opts) == "table" then
        for k, v in pairs(opts) do spec[k] = v end
    end
    table.insert(self._def.Args, spec)
    return self
end

function Builder:log(b)     self._def.Log     = b ~= false return self end
function Builder:webhook(b) self._def.Webhook = b == true  return self end
function Builder:confirm(b) self._def.Confirm = b == true  return self end

function Builder:code(fn)
    if type(fn) ~= "function" then
        warn(("[CommandsAPI] %s: :code(fn) needs a function"):format(self._def.Name))
        return nil
    end
    if self._finalized then
        warn(("[CommandsAPI] %s: :code() called twice — second call ignored"):format(self._def.Name))
        return self._def
    end
    self._finalized = true
    self._def.Code = fn
    return CommandRegistry.add(self._def)
end

local CommandsAPI = {}

function CommandsAPI.register(name)
    if type(name) ~= "string" or name == "" then
        warn("[CommandsAPI] register: name must be a non-empty string")
        return newBuilder("_invalid")
    end
    return newBuilder(name)
end

return CommandsAPI

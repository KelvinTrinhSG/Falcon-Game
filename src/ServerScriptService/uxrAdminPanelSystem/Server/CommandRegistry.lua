--!nocheck

local CommandRegistry = {}

local byName   = {}
local byAlias  = {}

local function lower(s) return tostring(s or ""):lower() end

local function registerOne(name, def)
    local key = lower(name)
    def.Name = name
    byName[key] = def
    for _, alias in ipairs(def.Aliases or {}) do
        byAlias[lower(alias)] = key
    end
end

function CommandRegistry.init(metadata, impls)
    byName, byAlias = {}, {}
    local missing = {}
    for name, meta in pairs(metadata) do
        local impl = impls[name]
        if impl then
            local def = table.clone(meta)
            def.Code = impl
            registerOne(name, def)
        else
            table.insert(missing, name)
        end
    end
    if #missing > 0 then
        warn(("[uxrAPS v5] %d commands have metadata but no impl: %s")
             :format(#missing, table.concat(missing, ", ")))
    end
end

function CommandRegistry.add(def)
    if type(def) ~= "table" or not def.Name or not def.Code then
        warn("[uxrAPS v5] CommandRegistry.add: def needs Name + Code")
        return nil
    end
    local key = lower(def.Name)
    if byName[key] then
        warn(("[uxrAPS v5] CommandRegistry.add: '%s' already exists — overwriting"):format(def.Name))
    end
    registerOne(def.Name, def)
    return def
end

function CommandRegistry.get(name)
    local key = lower(name)
    return byName[key] or byName[byAlias[key] or ""]
end

function CommandRegistry.all()
    return byName
end

return CommandRegistry

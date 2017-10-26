--==== From https://www.lua.org/pil/12.1.2.html
local dbg = require 'Q/UTILS/lua/debugger'
local function basicSerialize (o)
    if type(o) == "number" or type(o) == "boolean" then
        return tostring(o)
    elseif type(o) == "string" then  
        return string.format("%q", o)
    else
        assert(nil)
    end
end

local function is_l_exception(k,v)
    if type(v) == "function" then return true end
    if type(v) == "cdata" then return true end
    return false
end

local function is_g_exception(k,v)
    if type(v) == "function" then return true end
    if type(v) == "cdata" then return true end
    if k == "coroutine" then return true end
    if k == "io" then return true end
    if k == "utils" then return true end
    if k == "Q" then return true end
    if k == "lVector" then return true end
    if k == "Vector" then return true end
    if k == "ffi" then return true end
    if k == "package" then return true end
    if k == "_G" then return true end
    if k == "jit" then return true end
    if k == "lfs" then return true end
    if k == "posix" then return true end
    if k == "q_core" then return true end
    if k == "q" then return true end
    if k == "math" then return true end
    if k == "table" then return true end
    if k == "os" then return true end
    if k == "string" then return true end
    if k == "debug" then return true end
    if k == "_VERSION" then return true end
    if k == "libs" then return true end
    if string.match(k, "^g_") then return true end
    if k == "bit" then return true end
    if k == "arg" then return true end
    return false
end


-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function save(name, value, saved)
local function save(name, value, saved, file)
    if is_l_exception(name, value) then return end
    saved = saved or {}       -- initial value
    file = file or io
    file:write(name, " = ")
    if type(value) == "number" or 
       type(value) == "string" or 
       type(value) == "boolean" then
        file:write(basicSerialize(value), "\n")
    elseif type(value) == "table" then
        if saved[value] then    -- value already saved?
            file:write(saved[value], "\n")  -- use its previous name
        else
            saved[value] = name   -- save name for next time
            file:write("{}\n")     -- create a new table
            for k,v in pairs(value) do      -- save its fields
                local fieldname = string.format("%s[%s]", name,
                    basicSerialize(k))
                save(fieldname, v, saved, file)
            end
        end
    elseif type(value) == "lVector" then
        if saved[value] then
            file:write(saved[value], "\n")
        else
            saved[value] = name
            local persist_str = value:reincarnate()
            file:write(persist_str)
            file:write("\n")
            if type(value) == "lVector" then
                save(name .. "._meta", value._meta, saved, file)
            end
        end
    else
        --error("cannot save a " .. type(value))
    end
end

local function save_global(filename)
    assert(filename ~= nil, "A valid filename has to be given")
    local filepath = string.format("%s/%s", os.getenv("Q_METADATA_DIR"), filename)
    local file = assert(io.open(filepath, "w+"), "Unable to open file for writing")
    file:write("local lVector = require 'Q/RUNTIME/lua/lVector'\n")
    -- file:write("local Vector = require 'libvector'\n")
    -- file:write("local Dictionary = require 'Dictionary'\n")



    local saved = {}
    -- TODO get requires in place to be added in v2 like require "Vector"
    for k,v in pairs(_G) do
        if not is_g_exception(k,v) then
          print("Saving ", k, v)
          save(k, v, saved, file)
        end
    end
    file:close()
    print("Saved to " .. filepath)
end
return save_global

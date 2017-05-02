--==== From https://www.lua.org/pil/12.1.2.html

local function basicSerialize (o)
    if type(o) == "number" then
        return tostring(o)
    else   -- assume it is a string
        return string.format("%q", o)
    end
end

-- TODO Indrajeet make 2 args, one is name of table, other is filename
-- function save(name, value, saved)
local function save(name, value, saved)
    saved = saved or {}       -- initial value
    io.write(name, " = ")
    if type(value) == "number" or type(value) == "string" then
        io.write(basicSerialize(value), "\n")
    elseif type(value) == "table" then
        if saved[value] then    -- value already saved?
            io.write(saved[value], "\n")  -- use its previous name
        else
            saved[value] = name   -- save name for next time
            io.write("{}\n")     -- create a new table
            for k,v in pairs(value) do      -- save its fields
                local fieldname = string.format("%s[%s]", name,
                    basicSerialize(k))
                save(fieldname, v, saved)
            end
        end
    elseif value.persist ~= nil then
        if saved[value] then
            io.write(saved[value], "\n")
        else
            saved[value] = name
            local persist_str = value:persist()
            io.write(persist_str)
            io.write("\n")
            -- elseif type(value) == "Column" then
            -- elseif type(value) == "Vector" then
            -- elseif type(value) == "Dictionary" then
        end
    else
        error("cannot save a " .. type(value))
    end
end

return save

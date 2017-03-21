local Dictionary = {}
Dictionary.__index = Dictionary

setmetatable(Dictionary, {
        __call = function (cls, ...)
            return cls.get_instance(...)
        end,
    })

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Dictionary then
        return "Dictionary"
    end
    return otype
end

function Dictionary.get_instance(dict_name)
    local dict = _G["Q_DICTIONARIES"][dict_name]
    if not dict then
        local dict = setmetatable({}, Dictionary)
        _G["Q_DICTIONARIES"][dict_name] = dict
        dict.string_to_index = {}
        dict.index_to_string = {}
    end
    return dict
end

-- Given a index, if that index exists in dictionary then the string corresponding to that index is returned, null otherwise
function Dictionary:get_string_by_index(index)
    return self.index_to_string[index]
end

-- Given a string, if that string  exists in dictionary then the corresponding index to that string, null otherwise
function Dictionary:get_index_by_string(text)
    return self.string_to_index[text]
end

function Dictionary:add(text)
    assert(text and text ~= "", "Cannot add nil or empty string in dictionary")
    local index = self:get_index_by_string(text)
    if not index then
        index = #self.index_to_string + 1
        self.string_to_index[text] = index
        self.index_to_string[index] = text
    end
    return index
end

function Dictionary:conditional_add(text, condition)
    if condition then
        return self:add(text)
    else
        local index = self:get_index_by_string(text)
        if index then 
            return index
        else
            error("Text does not exist in dictionary")
        end
    end
end

function Dictionary:get_size()
    return #self.index_to_string
end

return Dictionary

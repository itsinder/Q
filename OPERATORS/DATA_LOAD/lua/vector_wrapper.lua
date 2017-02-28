package.path = package.path .. ";../../../Q2/code/?.lua"

local Vector = require 'Vector'
require 'q_c_functions'
require 'pl'
local Dictionary = require 'dictionary'


local Vector_Wrapper = {}
Vector_Wrapper.__index = Vector_Wrapper

setmetatable(Vector_Wrapper, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
})

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Vector_Wrapper then
        return "Vector_Wrapper"
    end
    return otype
end


local function allocate_chunk(self)
  if self.current_chunk == nil  then 
    self.current_chunk =  allocate_chunk_data(self.ctype, self.size_of_data, self.chunk_size)
    if(self.nn_v ~= nil) then self.nn_current_chunk =  allocate_chunk_data(self.nn_ctype, self.nn_size_of_data, self.chunk_size) end
  else
    reset_chunk_data(self.current_chunk, self.size_of_data, self.chunk_size)     
    if self.nn_v ~= nil then
      reset_chunk_data(self.nn_current_chunk, self.nn_size_of_data, self.chunk_size) 
    end
    self.current_idx = 0
  end
end  



function Vector_Wrapper.new(metadata, chunk_size)
  local self = setmetatable({}, Vector_Wrapper)
  
  self.name = metadata.name
  self.data_type = metadata.type 
  self.ctype = g_qtypes[self.data_type]["ctype"]
  if self.data_type == "SC" then
    self.size_of_data = metadata.size
  else
    self.size_of_data = g_qtypes[self.data_type]["width"]
  end
 
  self.v =  Vector{field_type=self.data_type, 
                  field_size=self.size_of_data, filename= _G["Q_DATA_DIR"] .. "_" ..metadata.name, 
                  write_vector=true}
  self.chunk_size = chunk_size or 15 --if value is not specified default to 15
  self.current_idx = 0
  self.current_chunk = nil
  self.nn_current_chunk = nil    
  self.col_num_nil = nil
  
  -- If user does no specify null value, then treat null = true as default
  if metadata.null == nil or metadata.null == "" then
    metadata.null = true
  end
  
  -- Null vector 
  if metadata.null == true then
    self.nn_data_type = "I1"
    self.nn_ctype = g_qtypes[self.nn_data_type]["ctype"]
    self.nn_size_of_data = g_qtypes[self.nn_data_type]["width"]  
    self.nn_v = Vector{field_type="I1",
                      field_size=g_qtypes["I1"]["width"],
                      filename= _G["Q_DATA_DIR"] .. "_nn_" ..metadata.name, write_vector=true}   
  end 
  
  if metadata.type == "SV" then
    self.dict = assert(Dictionary(metadata), "Error while creating/accessing dictionary for metadata " )
    self.dict_name = metadata.dict
    self.add_new_value = metadata.add or true   
  end 

  -- allocate first chunk on creation
  allocate_chunk(self)  
  return self
end


      
function Vector_Wrapper:write(data)

  local IS_NULL  = 0; 
  if self.data_type == "SV" then 
    -- dictionary throws error if any during the add operation

    if data ~= nil and stringx.strip(data) ~= "" then 
      local ret_number = self.dict:add_with_condition(data, self.add_new_value)                    
      -- return is number, convert it to string
      data = tostring(ret_number)
    else
      data = nil
    end
    
  elseif self.data_type == "SC" then 
    -- do not strip any value for SC
    if data ~= nil then 
      assert( string.len(data) <= self.size_of_data -1, " contains string greater than allowed size. Please correct data or metadata.")  
    end
  else
    -- for int, float strip the value first if its not nil and then 
    if data ~= nil then 
      data = stringx.strip(data)
    end
  end
 
  if data == nil or data == "" then 
    -- nil values
    assert( self.nn_v ~= nil, " Null value found in not null field .. column number " ) 
    IS_NULL = "0"
    if self.col_num_nil== nil then 
      self.col_num_nil =  1 
    else 
      self.col_num_nil = self.col_num_nil + 1
    end       
    data = nil -- this value will be replaced by \0 in the covert function which coverts string to c data   
  else
    -- Not nil value        
    if self.nn_v ~= nil then
      IS_NULL = "1" 
    end
  end
            
  -- --------------------------------------
  -- if chunk is full then write it out by calling the vector put chunk method and allocate next set of chunk
  if self.current_idx ~= 0 and   ( self.current_idx % self.chunk_size ) == 0 then
    self.v:put_chunk(self.current_chunk, self.chunk_size )
    if self.nn_v ~= nil then 
      self.nn_v:put_chunk(self.nn_current_chunk, self.chunk_size ) 
    end 
    allocate_chunk(self)  
  end

  -- Get the pointer for data on the current index   
  -- Call convert function to convert the data to appropriate C Data
  if self.data_type == "SC" then
    convert_txt_to_c(self.data_type, data, self.current_chunk + (self.current_idx * self.size_of_data), self.size_of_data)
  else 
    convert_txt_to_c(self.data_type, data, self.current_chunk + self.current_idx, self.size_of_data)
  end
  
  if self.nn_v ~= nil then  
    convert_txt_to_c(self.nn_data_type, IS_NULL, self.nn_current_chunk + self.current_idx, self.nn_size_of_data)
  end
  self.current_idx = self.current_idx + 1    
end

function Vector_Wrapper:flush()
  if self.current_idx > 0  then
    if self.current_idx == self.chunk_size then
      self.v:put_chunk(self.current_chunk, self.chunk_size )
      if self.nn_v ~= nil then
        self.nn_v:put_chunk(self.nn_current_chunk, self.chunk_size)
      end
    else 
      self.v:put_chunk(self.current_chunk, (self.current_idx) % self.chunk_size)
      if self.nn_v ~= nil then
        self.nn_v:put_chunk(self.nn_current_chunk, (self.current_idx) % self.chunk_size)
      end
    end
  end
end
  
function Vector_Wrapper:close()
    self:flush()  
    self.v:eov()  -- close the vector
    if self.nn_v ~= nil then 
      self.nn_v:eov()
      if self.col_num_nil == nil or self.col_num_nil == 0 then    
        local nn_filepath = _G["Q_DATA_DIR"] .."_nn_" .. self.name
        assert(file.delete(nn_filepath))
      end
    end
end
  
function Vector_Wrapper:get_vector()
  return self.v
end

function Vector_Wrapper:get_nn_vector()
  return self.nn_v
end

return Vector_Wrapper

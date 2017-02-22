package.path = package.path .. ";../../../Q2/code/?.lua"

local Vector = require 'Vector'
require 'q_c_functions'
require 'pl'


function Vector_Wrapper(metadata, chunk_size)
  
  local self = {
    name = nil,
    data_type = nil,
    function_name = nil,
    ctype = nil,
    size_of_data = 0,
    
    nn_data_type = nil,
    nn_function_name = nil,
    nn_ctype = nil,
    nn_size_of_data = 0,
    
    dict_name = nil,
    add_new_value = nil,
    dict = nil,
    
    v = nil,
    nn_v = nil,
    col_num_nil = nil,
      
    chunk_size = 15, 
    current_idx = 0,
    current_chunk = nil,
    nn_current_chunk = nil    
  }
  
  -- -----------------------------------------
  -- Initialize all fields required by closure
  -- -----------------------------------------
  self.name = metadata.name
  self.data_type = metadata.type 
  self.function_name = g_qtypes[self.data_type]["txt_to_ctype"]
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
  
  -- Null vector 
  if metadata.null == true or metadata.null == "true" then
    self.nn_data_type = "I1"
    self.nn_function_name = g_qtypes[self.nn_data_type]["txt_to_ctype"]
    self.nn_ctype = g_qtypes[self.nn_data_type]["ctype"]
    self.nn_size_of_data = g_qtypes[self.nn_data_type]["width"]  
    self.nn_v = Vector{field_type="I1",
                      field_size=g_qtypes["I1"]["width"],
                      filename= _G["Q_DATA_DIR"] .. "_nn_" ..metadata.name, write_vector=true}   
  end 
  
  if(metadata.type == "SV") then
    self.dict = assert(Dictionary(metadata), "Error while creating/accessing dictionary for metadata " )
    self.dict_name = metadata.dict
    self.add_new_value = metadata.add or true   
  end 
  
  

  -- -----------------------------
  -- Private Functions 
  -- ------------------------------
  local allocate_chunk = function()
    if(self.current_chunk == nil ) then 
      self.current_chunk =  allocate_chunk_data(self.ctype, self.size_of_data ,self.chunk_size)
      if(self.nn_v ~= nil) then self.nn_current_chunk =  allocate_chunk_data(self.nn_ctype, self.nn_size_of_data ,self.chunk_size) end
    else
      reset_chunk_data(self.current_chunk, self.size_of_data ,self.chunk_size)     
      if(self.nn_v ~= nil) then reset_chunk_data(self.nn_current_chunk, self.nn_size_of_data ,self.chunk_size) end
      self.current_idx = 0
    end
  end  
  -- --------------------------------------
  
  -- ----------------------- 
  -- Public functions
  -- ---------------------
       
  local write = function(data)
  
    local IS_NULL  = 0; 
    if self.data_type == "SV" then 
      -- dictionary throws error if any during the add operation

      if data ~= nil and stringx.strip(data) ~= "" then 
        local ret_number = self.dict.add_with_condition(data, self.add_new_value)                    
        -- return is number, convert it to string
        data = tostring(ret_number)
      else
        data = nil
      end
      
    elseif self.data_type == "SC" then 
      -- do not strip any value for SC
      if data ~= nil then 
        assert( string.len(data) <= self.size_of_data -1 , " contains string greater than allowed size. Please correct data or metadata.")  
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
      if(self.nn_v ~= nil) then
        IS_NULL = "1" 
      end
    end
              
    -- --------------------------------------
    -- if chunk is full then write it out by calling the vector put chunk method and allocate next set of chunk
    if(self.current_idx ~= 0 and   ( self.current_idx ) % self.chunk_size == 0) then
      self.v:put_chunk(self.current_chunk, self.chunk_size )
      if(self.nn_v ~= nil) then self.nn_v:put_chunk(self.nn_current_chunk, self.chunk_size ) end 
      allocate_chunk()  
    end

    -- Get the pointer for data on the current index   
    -- Call convert function to convert the data to appropriate C Data
    if(self.data_type == "SC") then
      convert_data(self.function_name, self.data_type, data, self.current_chunk + (self.current_idx * self.size_of_data) ,   self.size_of_data)
    else 
      convert_data(self.function_name, self.data_type, data, self.current_chunk + self.current_idx ,   self.size_of_data)
    end
    
    if(self.nn_v ~= nil) then  
      convert_data(self.nn_function_name, self.nn_data_type, IS_NULL, self.nn_current_chunk + self.current_idx ,   self.nn_size_of_data)
    end
    self.current_idx = self.current_idx + 1    
  end
                  
  local flush = function()
    if(self.current_idx > 0 ) then
      if(self.current_idx == self.chunk_size) then
        self.v:put_chunk(self.current_chunk, self.chunk_size )
        if(self.nn_v ~= nil) then  self.nn_v:put_chunk(self.nn_current_chunk, self.chunk_size ) end
      else 
        self.v:put_chunk(self.current_chunk, (self.current_idx) % self.chunk_size)
        if(self.nn_v ~= nil) then self.nn_v:put_chunk(self.nn_current_chunk, (self.current_idx) % self.chunk_size) end
      end
    end
  end
  
  local close = function()
      flush()  
      self.v:eov()  -- close the vector
      if(self.nn_v ~= nil) then 
        self.nn_v:eov()
        if self.col_num_nil == nil or self.col_num_nil == 0 then    
          local nn_filepath = _G["Q_DATA_DIR"] .."_nn_" .. self.name
          assert(file.delete(nn_filepath))
        end
      end
  end
  
  local get_vector = function()
    return self.v;
  end

  local get_nn_vector = function()
    return self.nn_v;
  end


  
  local vector_wrapper_function = {
    write = write,
    flush = flush, 
    close = close,
    get_vector = get_vector,
    get_nn_vector = get_nn_vector
  }              

  -- allocate first chunk on creation
  allocate_chunk()
  
  return vector_wrapper_function 
  
end
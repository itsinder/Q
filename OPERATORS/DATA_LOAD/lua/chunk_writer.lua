package.path = package.path .. ";../../../Q2/code/?.lua"

local Vector = require 'Vector'
require 'q_c_functions'
require 'pl'


function Writer(metadata, chunk_size)
  
  local self = {
    data_type = nil,
    function_name = nil,
    ctype = nil,
    size_of_data = 0,
    
    v = nil,
    
    chunk_size = 15, 
    current_idx = 0,
    current_chunk = nil    
  }
  
  -- -----------------------------------------
  -- Initialize all fields required by closure
  -- -----------------------------------------
   
  self.data_type = metadata.type 
  self.function_name = g_qtypes[self.data_type]["txt_to_ctype"]
  self.ctype = g_qtypes[self.data_type]["ctype"]
  if self.data_type == "SC" then
    self.size_of_data = metadata.size
  else
    self.size_of_data = g_qtypes[self.data_type]["width"]
  end
 
  self.v =  Vector{field_type=metadata.type, filename= _G["Q_DATA_DIR"] .. "_" ..metadata.name, write_vector=true}
  self.chunk_size = chunk_size or 15 --if value is not specified default to 15
  

  -- -----------------------------
  -- Private Functions 
  -- ------------------------------
  local allocate_chunk = function()
    self.current_chunk =  allocate_chunk_data(self.ctype, self.size_of_data ,self.chunk_size)
    self.current_idx = 0
  end

  local write_data_to_vector = function()
    -- write chunk, by calling vector put chunk with appropriate data
    if self.data_type == "SC" then    
      self.v:put_chunk(self.current_chunk, (self.chunk_size) * self.size_of_data)
    else
      self.v:put_chunk(self.current_chunk, (self.chunk_size)) 
    end 
  end
  
  -- --------------------------------------
  
  -- ----------------------- 
  -- Public functions
  -- ---------------------
       
  local write = function(data)
    -- if chunk is full then write it out by calling the vector put chunk method and allocate next set of chunk
    if(self.current_idx ~= 0 and   ( self.current_idx ) % self.chunk_size == 0) then 
      write_data_to_vector() 
      allocate_chunk()
    end
    
    -- Get the pointer for data on the current index   
    -- Call convert function to convert the data to appropriate C Data
    convert_data(self.function_name, self.ctype, data, self.current_chunk + self.current_idx ,   self.size_of_data)
    self.current_idx = self.current_idx + 1
    
  end
                  
  local flush = function()
    if(self.current_idx > 0 ) then
      -- write chunk, by calling vector put chunk with appropriate data
      if self.data_type == "SC" then 
        self.v:put_chunk(self.current_chunk, ( (self.current_idx) % self.chunk_size ) * self.size_of_data)
      else
        self.v:put_chunk(self.current_chunk, (self.current_idx) % self.chunk_size)
      end 
    end
  end
  
  local close = function()
      flush()  
      self.v:eov()  -- close the vector
  end
  
  local writer_function = {
    write = write,
    flush = flush, 
    close = close
  }              

  -- allocate first chunk on creation
  allocate_chunk()
  
  return writer_function 
  
end
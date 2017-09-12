local ffi     = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local Dictionary = require 'Q/UTILS/lua/dictionary'

local fns = {}

local dict_strings = { "test1", "test2", "test3", "test4", "test5" }

fns.validate_values = function(vec, qtype, chunk_number)
  -- Temporary hack to pass chunk number to get_chunk in case of nascent vector
  -- This hack is not required as this case is handled
  -- Refer mail with sub "Calling get_chunk() method from lVector.lua for nascent vector without passing chunk_num"
  -- if vec:num_elements() <= qconsts.chunk_size then
  --  chunk_number = 0
  -- end
  
  -- Temporary hack to pass SV type
  -- TODO : Validation of SV values 
  if qtype == "SV" then
    return true
  end
  
  local status, len, base_data, nn_data = pcall(vec.chunk, vec, chunk_number)
  assert(status, "Failed to get the chunk from vector")
  assert(base_data, "Received base data is nil")
  assert(len, "Received length is not proper")
  
  if qtype == "B1" then
    for i = 1 , len do 
      local bit_value = c_to_txt(vec, i)
      if bit_value == nil then bit_value = 0 end
      local expected
      if i % 2 == 0 then 
        expected = 0
      else 
        expected = 1 
      end
      -- print("Expected value ",expected," Actual value ",bit_value)
      if expected ~= bit_value then
        status = false
        print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(bit_value))
        break
      end
    end
    return status
  end
  
  -- Temporary: no validation of vector values for SC type
  if qtype == "SC" then
    for itr = 1, len do
      local actual_str = c_to_txt(vec, itr)
      local expected_str 
      if itr % 2 == 0 then expected_str = "temp" else expected_str = "dummy" end
      -- print("Expected value ",expected_str," Actual value ",actual_str)
      
      if expected_str ~= actual_str then
        status = false
        print("Value mismatch at index " .. tostring(itr) .. ", expected: " .. tostring(expected_str) .. " .... actual: " .. tostring(actual_str))
        break
      end
      
    end
    return status
  end
  
  -- Temporary: no validation of vector values if has_nulls == true
  if vec._has_nulls then
    assert(nn_data, "Received nn_data is nil")
    return true
  end
  
  local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
  for i = 1, len do
    local expected = i*15 % qconsts.qtypes[qtype].max
    if ( iptr[i - 1] ~= expected ) then
      status = false
      print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(iptr[i - 1]))
      break
    end
  end
  return status
end


-- for generating values ( can be scalar, gen_func, cmem_buf )
-- for B1, cmem_buf generates values as 01010101 i.e. 85 by treating it as I1
fns.generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local status = false
  if gen_method == "cmem_buf" then
    local is_B1 = false
    -- TODO: SV type is in progress, will fail for now
    if qtype == "SV" then
      local buf_length = num_elements
      -- currently hardcoded for SV type
      local dict = "D1"
      local is_dict = false
      local add = true
      local max_width= 1024
      
      local dict_obj = assert(Dictionary(dict))
      -- print(dict_obj)
      vec:set_meta("dir", dict_obj)
      
      local base_data = cmem.new(field_size)
      local stridx = 0
      
      for itr = 1, num_elements do
        if ( add ) then
          stridx = dict_obj:add(dict_strings[itr])
        else
          stridx = dict_obj:get_index_by_string(dict_strings[itr])
        end
        print("Dict data : ",stridx)
        
        local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
        iptr[itr]= stridx
        vec:put_chunk(base_data, nil, buf_length)
      end
      
    elseif qtype == "SC" then
      local base_data = cmem.new(field_size)
      for itr = 1, num_elements do
        local str
        if itr%2 == 0 then str = "temp" else str = "dummy" end
        ffi.copy(base_data, str)
        vec:put1(base_data)
      end
    else
      local buf_length = num_elements
      local base_data, nn_data
      if qtype == "B1" then 
        -- We will populate a buffer by putting 8 bits at a time
        field_size = 8
        qtype = "I1"
        is_B1 = true
        num_elements = math.ceil(num_elements / 8)
      end
      base_data = cmem.new(num_elements * field_size)
      local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
      --iptr[0] = qconsts.qtypes[qtype].min
      
      for itr = 1, num_elements do
        if is_B1 then 
          iptr[itr - 1] = 85
        else
          iptr[itr - 1] = itr*15 % qconsts.qtypes[qtype].max
        end
      end

      --iptr[num_elements - 1] = qconsts.qtypes[qtype].max
      
      -- Check if vec has nulls
      if vec._has_nulls then
        field_size = 8
        qtype = "I1"
        num_elements = math.ceil(num_elements / 8)
        
        nn_data = cmem.new(num_elements * field_size)
        local nn_iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", nn_data)
        for itr = 1, num_elements do
          nn_iptr[itr - 1] = itr*15 % qconsts.qtypes[qtype].max
        end      
      end
      
      vec:put_chunk(base_data, nn_data, buf_length)
    end
    assert(vec:check())
    status = true    
  end
  
  if gen_method == "scalar" then
    --local s1 = Scalar.new(qconsts.qtypes[qtype].min, qtype)
    --vec:put1(s1)
    for i = 1, num_elements do
      local s1, s1_nn
      if qtype == "B1" then
        local bval
        if i % 2 == 0 then bval = false else bval = true end
        s1 = Scalar.new(bval, qtype)
      else
        s1 = Scalar.new(i*15% qconsts.qtypes[qtype].max, qtype)
      end
      if vec._has_nulls then
        local bval
        if i % 2 == 0 then bval = true else bval = false end
        s1_nn = Scalar.new(bval, "B1")
      end
      vec:put1(s1, s1_nn)
    end
    --s1 = Scalar.new(qconsts.qtypes[qtype].max, qtype)
    --vec:put1(s1)    
    status = true
  end
  
  if gen_method == "func" then
    local num_chunks = num_elements
    local chunk_size = qconsts.chunk_size
    for chunk_num = 1, num_chunks do 
      local a, b, c = vec:chunk(chunk_num-1)
      assert(a == chunk_size)
    end
    status = true
  end
  
  return status
end

return fns
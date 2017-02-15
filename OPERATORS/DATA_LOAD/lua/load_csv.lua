package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

require 'chunk_writer'
require 'globals'
require 'parser'
require 'dictionary'
require 'q_c_functions'
require 'pl'
require 'utils'


-- ----------------
-- load( "CSV file to load", "meta data", "Global Metadata") 
-- Loads the CSV file and stores in the Q internal format
-- 
-- returns : table containing list of files for each column defined in metadata. 
--           If any error was encountered during load operation then negative status code  
-- ----------------

-- validate meta-data & create vector + null vector for each of the file being created 
local vector_wrapper = {}
local col_count = 0 --each field in the metadata represents one column in csv file
local col_idx = 0
local row_idx = 0
local col_num_nil = {}  
local validate_input, initialize, cleanup

function load( csv_file_path, metadata , G)
  
  validate_input(csv_file_path, metadata, G)   
  initialize(metadata)  
  
  for line in io.lines(csv_file_path) do
 
    -- local col_values= parse_csv_line(line,',')       -- call to parse to parse the line of csv file
    local status, col_values = pcall(parse_csv_line, line, ',' )
    assert( status == true , "Input file line " .. row_idx .. " : contains invalid data. Please check data") 
    
    if(#col_values ~= col_count) then 
     -- If its the single column and nil is allowed then its a valid case
     --TODO : If the last column is null
    
     if(col_count == 1) then
      --[[assert(nil_vector_wrapper[col_count] ~= nil, "Null value found in not null field") --]] 
     else
      error("Column count does not match with count of column in metadata")
     end
      
    end
    
    for col_idx = 1, col_count do
    
      local data_type_short_code = metadata[col_idx]["type"];
      local txt_to_ctype_func_name = g_qtypes[data_type_short_code]["txt_to_ctype"]
      local ctype = g_qtypes[data_type_short_code]["ctype"]
      local size_of_data = g_qtypes[data_type_short_code]["width"]
      
      local current_value = col_values[col_idx]
      
      -- Now vector_wrapper handles null value handling and string to c_type value conversion
      vector_wrapper[col_idx].write(current_value)

    end  
    row_idx = row_idx + 1
  end
  
  --cleanup
  cleanup(metadata)  
  -- close all vectors & delete the null vector if it is not required..
  return vector_wrapper
end

initialize = function(metadata)
  

  -- initialize value which needs to be written to null vector, since it will be either 0 or 1
  -- Initialize all the values
  vector_wrapper = {}
  col_count = 0 --each field in the metadata represents one column in csv file
  col_idx = 0
  row_idx = 0
  col_num_nil = {}      
  col_count = #metadata
    
  for i = 1, col_count do 
    -- If metadata name is not empty/null, then only create new vector
    if stringx.strip(metadata[i].name) ~= "" then
      vector_wrapper[i] = assert(Vector_Wrapper(metadata[i]))
    end    
  end

end

cleanup = function(metadata)
  for i = 1, col_count do 
    -- If metadata name is not empty/null, then only create new vector
    if stringx.strip(metadata[i].name) ~= "" then
      vector_wrapper[i].close()
    end     
  end
end


validate_input =  function(csv_file_path, metadata, G)
  assert( metadata ~= nil, "Metadata should not be nil")
  assert( type(metadata) == "table", "Metadata type should be table")
  assert( valid_file(csv_file_path),"Please make sure that csv_file_path is correct")
  -- Check if the directory required by this load operation exists
  assert( valid_dir(_G["Q_DATA_DIR"]),"Please make sure that Q_DATA_DIR points to correct directory")
  assert( valid_dir(_G["Q_META_DATA_DIR"]) , "Please make sure that Q_META_DATA_DIR points to correct directory")
  
  local col_names = {}
  -- now look at fields of metadata
  for i,m in pairs(metadata) do
    assert(m.name ~= nil, "metadata " .. i .. " : name cannot be null")
    assert(m.type ~= nil, "metadata " .. i .. " : type cannot be null")
    assert(g_qtypes[m.type] ~= nil, "metdata " .. i .. " : type contains invalid q type")
    -- if not null is specified then only true/false is the acceptable value
    if(m.null ~= nil) then 
      assert( (m.null == true or m.null == "true" or m.null == false or m.null == "false" ), "metdata " .. i .. " : null can contain true/false only" )
    end
    
    -- check if the same column name is found before in metadata
    if(m.name ~= "") then 
      assert( col_names[m.name] == nil , "metadata " .. i .. " : duplicate column name is not allowed") 
      col_names[m.name] = 1 
    end
    -- Perform check based on metadata type
    -- nothing more needs to be checked for integer, float field in addition to the above checks
    --if(m.type == "I1" or m.type == "I2" or m.type == "I4" or m.type == "I8") then   
    --elseif(m.type == "F4" or m.type == "F8") then 
    
    if(m.type == "SC") then 
      assert(m.size ~= nil , "metadata " .. i .. " : size should be specified for fixed length strings")
      assert(tonumber(m.size) , "metadata " .. i .. " : size should be valid number")
      
    elseif(m.type == "varchar") then
      assert(m.dict ~= nil,"metadata " .. i .. " : dict cannot be null")
      assert(m.is_dict ~= nil, "metadata " .. i .. " : is_dict cannot be null")
      assert(m.is_dict == true or m.is_dict == "true" or m.is_dict == false or m.is_dict == "false", "metadata " .. i .. " : is_dict can contain true/false only")
      if(m.is_dict == true or m.is_dict == "true") then 
        assert(m.add ~= nil, "metadata " .. i .. " : add cannot be null for dictionary which has is_dict true")
        assert(m.add == true or m.add == "true" or m.add == false or m.add == "false", "metadata " .. i .. " : add can contain true/false only")
      end
    end     
  end
  
  -- file should not be empty
  assert( path.getsize(csv_file_path) ~= 0 , "File should not be empty")
     
end


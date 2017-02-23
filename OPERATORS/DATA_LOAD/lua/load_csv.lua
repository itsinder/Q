package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"


require 'vector_wrapper'
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

function load( csv_file_path, metadata , load_global_settings)
  
  validate_input(csv_file_path, metadata, load_global_settings)   
  initialize(metadata)  
  
  for line in assert(io.lines(csv_file_path)) do
 
    -- call to parse to parse the line of csv file
    local status, col_values = pcall(parse_csv_line, line, ',' )
    assert( status == true , "Input file line " .. row_idx .. " : contains invalid data. Please check data") 
    assert(#col_values == col_count, "Error : row : " .. row_idx .. " Column count does not match with count of column in metadata")
    
    for col_idx = 1, col_count do
      local current_value = col_values[col_idx]
      local status, ret_message = pcall(vector_wrapper[col_idx].write, current_value)
      assert(status ~= false , "Error at row : " .. row_idx .. " column : " .. col_idx .. " : " .. tostring(ret_message)) 
    end  
    row_idx = row_idx + 1
  end
  
  cleanup(metadata)  
  return vector_wrapper
end

initialize = function(metadata)
  

  -- initialize value which needs to be written to null vector, since it will be either 0 or 1
  -- Initialize all the values
  vector_wrapper = {}
  col_count = 0 --each field in the metadata represents one column in csv file
  col_idx = 0
  row_idx = 1
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


validate_input =  function(csv_file_path, metadata_table, load_global_settings)
  assert( metadata_table ~= nil, "Metadata should not be nil")
  assert( type(metadata_table) == "table", "Metadata type should be table")
  assert( valid_file(csv_file_path),"Please make sure that csv_file_path is correct")
  -- Check if the directory required by this load operation exists
  assert( valid_dir(_G["Q_DATA_DIR"]),"Please make sure that Q_DATA_DIR points to correct directory")
  assert( valid_dir(_G["Q_META_DATA_DIR"]) , "Please make sure that Q_META_DATA_DIR points to correct directory")
  
  local col_names = {}
  -- now look at fields of metadata
  for metadata_idx,metadata in pairs(metadata_table) do
    assert(metadata.name ~= nil, "metadata " .. metadata_idx .. " : name cannot be null")
    assert(metadata.type ~= nil, "metadata " .. metadata_idx .. " : type cannot be null")
    assert(g_qtypes[metadata.type] ~= nil, "metadata " .. metadata_idx .. " : type contains invalid q type")
    -- if not null is specified then only true/false is the acceptable value
    if(metadata.null ~= nil) then 
      assert( (metadata.null == true or metadata.null == "true" or metadata.null == false or metadata.null == "false" ), "metdata " .. metadata_idx .. " : null can contain true/false only" )
    end
    
    -- check if the same column name is found before in metadata
    if(metadata.name ~= "") then 
      assert( col_names[metadata.name] == nil , "metadata " .. metadata_idx .. " : duplicate column name is not allowed") 
      col_names[metadata.name] = 1 
    end
    -- Perform check based on metadata type
   
    if(metadata.type == "SC") then 
      assert(metadata.size ~= nil , "metadata " .. metadata_idx .. " : size should be specified for fixed length strings")
      assert(tonumber(metadata.size) , "metadata " .. metadata_idx .. " : size should be valid number")
      
    elseif(metadata.type == "SV") then
      assert(metadata.dict ~= nil,"metadata " .. metadata_idx .. " : dict cannot be null")
      assert(metadata.is_dict ~= nil, "metadata " .. metadata_idx .. " : is_dict cannot be null") -- m["is_dict"]
      assert(metadata.is_dict == true or metadata.is_dict == "true" or metadata.is_dict == false or metadata.is_dict == "false", "metadata " .. metadata_idx .. " : is_dict can contain true/false only")
      if(metadata.is_dict == true or metadata.is_dict == "true") then 
        assert(metadata.add ~= nil, "metadata " .. metadata_idx .. " : add cannot be null for dictionary which has is_dict true")
        assert(metadata.add == true or metadata.add == "true" or metadata.add == false or metadata.add == "false", "metadata " .. metadata_idx .. " : add can contain true/false only")
      end
    end     
  end
  
  -- file should not be empty
  assert( path.getsize(csv_file_path) ~= 0 , "File should not be empty")
     
end


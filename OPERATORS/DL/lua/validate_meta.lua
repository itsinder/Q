package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
require 'globals'
-- require 'parser'
-- require 'dictionary'
-- require 'q_c_functions'
require 'pl'
require 'utils'


function validate_meta(metadata_table)
  assert( metadata_table ~= nil, "Metadata should not be nil")
  assert( type(metadata_table) == "table", "Metadata type should be table")
  -- assert( valid_file(csv_file_path),"Please make sure that csv_file_path is correct")
  -- Check if the directory required by this load operation exists
  assert( valid_dir(_G["Q_DATA_DIR"]), "Please make sure that Q_DATA_DIR points to correct directory")
  assert( valid_dir(_G["Q_META_DATA_DIR"]), "Please make sure that Q_META_DATA_DIR points to correct directory")
  
  local col_names = {}
  -- now look at fields of metadata
  for metadata_idx, metadata in pairs(metadata_table) do
    assert(type(metadata) == "table" , "Meta data element must be a table")
    assert(metadata.name ~= nil, "metadata " .. metadata_idx .. " : name cannot be null")
    assert(metadata.type ~= nil, "metadata " .. metadata_idx .. " : type cannot be null")
    assert(g_qtypes[metadata.type] ~= nil, "metadata " .. metadata_idx .. " : type contains invalid q type")
    -- if not null is specified then only true/false is the acceptable value
    if metadata.null ~= nil then 
      assert((metadata.null == true  or metadata.null == false ), "metdata " .. metadata_idx .. " : null can contain true/false only" )
    end
    
    -- check if the same column name is found before in metadata
    if metadata.name ~= "" then 
      assert( col_names[metadata.name] == nil , "metadata " .. metadata_idx .. " : duplicate column name is not allowed") 
      col_names[metadata.name] = 1 
    end
    -- Perform check based on metadata type
   
    if metadata.type == "SC" then 
      assert(metadata.size ~= nil, "metadata " .. metadata_idx .. " : size should be specified for fixed length strings")
      assert(tonumber(metadata.size), "metadata " .. metadata_idx .. " : size should be valid number")
      
    elseif metadata.type == "SV" then
      assert(tonumber(metadata.max_length) > 0, "Must have a max length for SV type if used")
      assert(metadata.dict ~= nil, "metadata " .. metadata_idx .. " : dict cannot be null")
      assert(metadata.dict_exists ~= nil, "metadata " .. metadata_idx .. " : dict_exists cannot be null") -- m["dict_exists"]
      assert(metadata.dict_exists == true or metadata.dict_exists == false , "metadata " .. metadata_idx .. " : dict_exists can contain true/false only")
      if metadata.dict_exists == true then 
        assert(metadata.add ~= nil, "metadata " .. metadata_idx .. " : add cannot be null for dictionary which has dict_exists true")
        assert(metadata.add == true or metadata.add == false, "metadata " .. metadata_idx .. " : add can contain true/false only")
      end
    end
    return true
  end
  
  -- file should not be empty
  -- assert( path.getsize(csv_file_path) ~= 0, "File should not be empty")     
end

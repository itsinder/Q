require 'globals'

function validate_meta(metadata_table)
  assert( metadata_table ~= nil, "Metadata should not be nil")
  assert( type(metadata_table) == "table", "Metadata type should be table")
  
  local col_names = {}
  -- now look at fields of metadata
  for metadata_idx, metadata in pairs(metadata_table) do
    assert(metadata.name ~= nil, "metadata " .. metadata_idx .. " : name cannot be null")
    assert(metadata.qtype ~= nil, "metadata " .. metadata_idx .. " : type cannot be null")
    assert(g_qtypes[metadata.qtype] ~= nil, "metadata " .. metadata_idx .. " : type contains invalid q type")
    -- if not null is specified then only true/false is the acceptable value
    if metadata.has_nulls ~= nil then 
      assert((metadata.has_nulls == true  or metadata.has_nulls == false ), "metdata " .. metadata_idx .. " : null can contain true/false only" )
    end
    
    -- check if the same column name is found before in metadata
    if metadata.name ~= "" then 
      assert( col_names[metadata.name] == nil , "metadata " .. metadata_idx .. " : duplicate column name is not allowed") 
      col_names[metadata.name] = 1    
    end
    -- Perform check based on metadata type
   
    if metadata.qtype == "SC" then 
      assert(metadata.size ~= nil, "metadata " .. metadata_idx .. " : size should be specified for fixed length strings")
      assert(tonumber(metadata.size), "metadata " .. metadata_idx .. " : size should be valid number")
      
    elseif metadata.qtype == "SV" then
      assert(metadata.dict ~= nil, "metadata " .. metadata_idx .. " : dict cannot be null")
      assert(metadata.is_dict ~= nil, "metadata " .. metadata_idx .. " : dict_exists cannot be null")
      assert(metadata.is_dict == true or metadata.is_dict == false , "metadata " .. metadata_idx .. " : dict_exists can contain true/false only")
      if metadata.is_dict == true then 
        assert(metadata.add ~= nil, "metadata " .. metadata_idx .. " : add cannot be null for dictionary which has dict_exists true")
        assert(metadata.add == true or metadata.add == false, "metadata " .. metadata_idx .. " : add can contain true/false only")
      end
    end     
  end
end



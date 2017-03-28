require 'globals'
local metadata_string = "metadata"

function validate_meta(metadata_table)
  assert( metadata_table ~= nil, g_err.METADATA_NULL_ERROR)
  assert( type(metadata_table) == "table", g_err.METADATA_TYPE_TABLE)
  
  local col_names = {}
  -- now look at fields of metadata
  for metadata_idx, metadata in pairs(metadata_table) do
    assert(metadata.name ~= nil, metadata_string .. metadata_idx .. g_err.METADATA_NAME_NULL)
    assert(metadata.qtype ~= nil, metadata_string .. metadata_idx .. g_err.METADATA_TYPE_NULL)
    assert(g_qtypes[metadata.qtype] ~= nil, metadata_string .. metadata_idx .. g_err.INVALID_QTYPE)
    -- if not null is specified then only true/false is the acceptable value
    if metadata.has_nulls ~= nil then 
      assert((metadata.has_nulls == true  or metadata.has_nulls == false ), metadata_string .. metadata_idx .. g_err.INVALID_NN_BOOL_VALUE )
    end
    
    -- check if the same column name is found before in metadata
    if metadata.name ~= "" then 
      assert( col_names[metadata.name] == nil , metadata_string .. metadata_idx .. g_err.DUPLICATE_COL_NAME) 
      col_names[metadata.name] = 1    
    end
    -- Perform check based on metadata type
   
    if metadata.qtype == "SC" then 
      assert(metadata.size ~= nil, metadata_string .. metadata_idx .. g_err.SC_SIZE_MISSING)
      assert(tonumber(metadata.size), metadata_string .. metadata_idx .. g_err.SC_INVALID_SIZE)
      
    elseif metadata.qtype == "SV" then
      assert(metadata.dict ~= nil, metadata_string .. metadata_idx .. g_err.DICT_NULL_ERROR)
      assert(metadata.is_dict ~= nil, metadata_string .. metadata_idx .. g_err.IS_DICT_NULL)
      assert(metadata.is_dict == true or metadata.is_dict == false , metadata_string .. metadata_idx .. g_err.INVALID_IS_DICT_BOOL_VALUE)
      if metadata.is_dict == true then 
        assert(metadata.add ~= nil, metadata_string .. metadata_idx .. g_err.ADD_DICT_ERROR)
        assert(metadata.add == true or metadata.add == false, metadata_string .. metadata_idx ..g_err.INVALID_ADD_BOOL_VALUE)
      end
    end     
  end
end



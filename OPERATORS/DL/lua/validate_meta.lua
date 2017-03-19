package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
require 'globals'
plpath = require 'pl.path'


function validate_meta(
  M -- meta data table 
  )
  assert(type(M) == "table", "Metadata should be table")
  assert(plpath.isdir(_G["Q_META_DATA_DIR"]), 
  "Q_META_DATA_DIR not a directory")
  
  local col_names = {}
  -- now look at fields of metadata
  for midx, fldM in pairs(M) do
    local col = "Column " .. midx .. ": "
    assert(type(fldM) == "table", col .. "column descriptor must be table")
    assert(fldM.name ~= nil, col .. "name cannot be null")
    assert(fldM.qtype ~= nil, col .. "qtype cannot be null")
    assert(g_qtypes[fldM.qtype] ~= nil, 
    col ..  "qtype contains invalid q type")
    if fldM.has_nulls then 
      assert((fldM.has_nulls == true  or fldM.has_nulls == false ), 
      col .. "has_nulls can contain true/false only" )
    else
      fldM.has_nulls = false
    end
    if fldM.is_load then 
      assert((fldM.is_load == true  or fldM.is_load == false ), 
      col .. "is_load can contain true/false only" )
    else
      fldM.is_load = true
    end
    if ( fldM.is_load ) then 
      assert(not col_names[fldM.name],
      col .. "duplicate column name is not allowed") 
      col_names[fldM.name] = true 
    end
    if fldM.qtype == "SC" then 
      assert(fldM.size,  
      col .. ": size should be specified for SC")
      local sz = assert(tonumber(fldM.size), 
      col .. " : size should be valid number")
      assert(sz <= g_max_size_SC,
      col .. " : size too large for SC")
    end
    if fldM.qtype == "SV" then
      assert(tonumber(fldM.max_length) > 0, 
      col .. "Specify max_length for SV")
      assert(fldM.dict,
      col .. "Must specify dictionary for SV")
      assert(fldM.dict_exists == true or fldM.dict_exists == false, 
      col .. "dict_exists must be true or false")
      if fldM.dict_exists == true then 
        -- TODO Verify that dictionary exists
        assert(fldM.add == true or fldM.add == false, 
        col .. ":add must be true or false if dict_exists = true for SV")
      end
    end
  end
  return true
end

package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
require 'globals'
local pl = require 'pl'
local dbg = require 'debugger'

function validate_meta(
  M -- meta data table 
  )
  -- local plpath = require 'pl.path'
  plpath = require 'pl.path'
  assert(type(M) == "table", "Metadata should be table")
  assert(plpath.isdir(_G["Q_META_DATA_DIR"]), 
  "Q_META_DATA_DIR not a directory")
  
  local col_names = {}
  -- now look at fields of metadata
  local num_cols_to_load = 0
  for midx, fld_M in pairs(M) do
    local col = "Column " .. midx .. ": "
    assert(type(fld_M) == "table", col .. "column descriptor must be table")
    assert(fld_M.name,  col .. "name cannot be null")
    assert(fld_M.qtype, col .. "qtype cannot be null")
    assert(g_qtypes[fld_M.qtype], 
    col ..  "qtype contains invalid q type")
    if fld_M.has_nulls ~= nil then 
      assert((fld_M.has_nulls == true  or fld_M.has_nulls == false ), 
      col .. "has_nulls can contain true/false only" )
    else
      fld_M.has_nulls = false
    end
    if fld_M.is_load ~= nil then 
      assert((fld_M.is_load == true  or fld_M.is_load == false ), 
      col .. "is_load can contain true/false only" )
    else
      fld_M.is_load = true
    end
    if ( fld_M.is_load ) then 
      assert(not col_names[fld_M.name],
      col .. "duplicate column name is not allowed") 
      col_names[fld_M.name] = true 
      num_cols_to_load = num_cols_to_load + 1
    end
    if fld_M.qtype == "SC" then 
      assert(
      (tonumber(fld_M.width) >= 2) and 
      (tonumber(fld_M.width) <= g_max_width_SC), 
      col .. " : width for SC not valid")
    end
    if fld_M.qtype == "SV" then
      assert(
      (tonumber(fld_M.max_width) >= 2) and 
      (tonumber(fld_M.max_width) <= g_max_width_SV), 
      col .. " : width for SV not valid")
      
      assert(fld_M.dict, col .. "Must specify dictionary for SV")

      assert(fld_M.dict_exists == true or fld_M.dict_exists == false, 
      col .. "dict_exists must be true or false")

      if fld_M.dict_exists == true then 
        -- TODO Verify that dictionary exists
        assert(fld_M.add == true or fld_M.add == false, 
        col .. ":add must be true or false if dict_exists = true for SV")
      else
        fld_M.add = true
      end
      -- TODO  everybodu can add to a dict or nobody can add to it 
      --
    end
  end
  assert(num_cols_to_load > 0, "Must load at least one column")
  return true
end

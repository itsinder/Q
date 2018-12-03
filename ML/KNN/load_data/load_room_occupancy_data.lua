local Q = require 'Q'
local plpath = require 'pl.path'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/ML/KNN/load_data/"

local function load_data(data_file_path, metadata_file_path)
  local data_file = script_dir .. "/../data/occupancy/occupancy.csv"
  local metadata_file = script_dir .. "/../data/occupancy/occupancy_meta.lua"
  if data_file_path then
    assert(type(data_file_path) == "string")
    data_file = data_file_path
  end
  if metadata_file_path then
    assert(type(metadata_file_path) == "string")
    metadata_file = metadata_file_path
  end
  assert(plpath.isfile(metadata_file), "ERROR: Please check metadata_file_path " .. metadata_file)
  assert(plpath.isfile(data_file), "ERROR: Please check data_file")
  local optargs = { is_hdr = false, use_accelerator = true }
  local M = dofile(metadata_file)
  local status, ret = pcall(Q.load_csv, data_file, M, optargs)
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  print("Data load done !!")
  return ret
end

return load_data

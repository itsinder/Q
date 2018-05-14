local Q = require 'Q'
local plpath = require 'pl.path'

local q_meta_dir = os.getenv("Q_METADATA_DIR")
local q_meta_file = os.getenv("Q_METADATA_FILE")
local q_src_root = os.getenv("Q_SRC_ROOT")

local script_dir = q_src_root .. "/ML/KNN/load_data/"

local get_train_test_split = function(split_ratio, T_data)
  local train_data = {}
  local test_data = {}
  local total_length
  for i, v in pairs(T_data) do
    total_length = v:length()
    break
  end
  local random_vec = Q.rand({lb = 0, ub = 1, qtype = "F4", len = total_length}):eval()
  local random_vec_bool = Q.vsleq(random_vec, split_ratio):eval()
  for i, v in pairs(T_data) do
    train_data[i] = Q.where(v, random_vec_bool):eval()
    test_data[i] = Q.where(v, Q.vnot(random_vec_bool)):eval()
  end
  return train_data, test_data
end


local function load_data(metadata_file, data_file)
  assert(plpath.isfile(metadata_file), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(data_file), "ERROR: Please check data_file")
  local optargs = { is_hdr = false, use_accelerator = true }
  local M = dofile(metadata_file)
  local status, ret = pcall(Q.load_csv, data_file, M, optargs)
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  return ret
end

assert(#arg == 2, "Usage: luajit load_room_occupancy_data.lua <csv_file_path> <split_ratio>")

local metadata_file = script_dir .. "room_occupancy_meta.lua"
local data_file = arg[1]
local split_ratio = tonumber(arg[2])
local T = load_data(metadata_file, data_file)
Train, Test = get_train_test_split(split_ratio, T)

--[[
print("Input Sample Length")
for i, v in pairs(T) do
  print(v:length())
end
print("################################")
print("Train Sample Length")
for i, v in pairs(Train) do
  print(v:length())
end
print("################################")
print("Test Sample Length")
for i, v in pairs(Test) do
  print(v:length())
end
]]

local saved_file_path
if q_meta_file then
  saved_file_path = q_meta_file
elseif q_meta_dir then
  saved_file_path = q_meta_dir .. "/room_occupancy.saved"
else
  saved_file_path = script_dir .. "room_occupancy.saved"
end

Q.save(saved_file_path)
print("Done")

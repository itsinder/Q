package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

require 'load_csv'
require 'utils'
local plpath = require 'pl.path'

assert( #arg == 2 , "ERROR: Please provide metadata_file_path followed by data_file_path")
  
local metadata_file_path = arg[1]
local csv_file_path = arg[2]

assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
 
local M = dofile(metadata_file_path)
preprocess_bool_values(M, "null", "dict_exists", "add")

--set defaults..
if _G["Q_DATA_DIR"] == nil then
  _G["Q_DATA_DIR"] = "./out/"     
end

if _G["Q_META_DATA_DIR"] == nil then
  _G["Q_META_DATA_DIR"] = "./metadata/"
end
-- create dictionary table if it does not exists
if _G["Q_DICTIONARIES"] == nil then
  _G["Q_DICTIONARIES"] = {}
end

-- call load function to load the data
local status, ret = pcall(load_csv, csv_file_path, M )
assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 

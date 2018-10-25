local Q = require 'Q'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local plpath        = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/lua/"
assert(plpath.isdir(path_to_here))

local function split_csv(data_file, meta_data_file, args)
  
  assert(data_file, "csv file not provided")
  assert(meta_data_file, "metadata file not provided")
  local split_ratio = 0.5
  if args.split_ratio then
    assert(type(args.split_ratio) == "number")
    assert(args.split_ratio < 1 and args.split_ratio > 0)
    split_ratio = args.split_ratio
  end
  assert(split_ratio < 1 and split_ratio > 0)
  
  local feature_of_interest
  if args.feature_of_interest then
    assert(type(args.feature_of_interest) == "table")
    feature_of_interest = args.feature_of_interest
  end
  
  local seed = 100
  -- loading the input csv datafile
  local T = Q.load_csv(data_file, dofile(meta_data_file), { is_hdr = args.is_hdr })
  
  -- splitting the loaded csv file into train & test
  local Train, Test = split_train_test(T, split_ratio, feature_of_interest, 100)
  
  -- printing the train & test data into separate csv files
  local path = Q_SRC_ROOT .. "/ML/KNN/data/"
  -- getting the print_csv opt_args 'print_order' field from metadata file
  local print_order = {}
  local M = dofile(meta_data_file)
  for i=1,#M do
    print_order[#print_order+1] = M[i].name
  end
  local dest_path, file_name = plpath.splitpath(data_file)
  local file_n = plpath.splitext(file_name)
  Q.print_csv(Train, {opfile = dest_path .. "/" .. file_n .. "_train.csv", print_order = print_order })
  Q.print_csv(Test, {opfile = dest_path .. "/" .. file_n .. "_test.csv", print_order = print_order })
end

return split_csv

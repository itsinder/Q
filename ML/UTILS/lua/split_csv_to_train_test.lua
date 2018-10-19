local Q = require 'Q'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local plpath        = require 'pl.path'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/ML/DT/lua/"
assert(plpath.isdir(path_to_here))

local function split_csv(data_file, meta_data_file, args)
  
  assert(data_file, "csv file not provided")
  assert(meta_data_file, "metadata file not provided")
  local split_ratio = 0.7
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
  Q.print_csv(Train, {opfile = path .. "train_data.csv"})
  Q.print_csv(Test, {opfile = path .. "test_data.csv"})
end

return split_csv
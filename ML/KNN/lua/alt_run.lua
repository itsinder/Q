local Q = require 'Q'
local Scalar = require 'libsclr'
local plpath = require 'pl.path'
local alt_voting = require 'alt_voting'

local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local script_dir = q_src_root .. "/ML/KNN/data/"
assert(plpath.isdir(script_dir))

local split = require 'Q/ML/UTILS/lua/split'
local get_meta_file = require 'Q/ML/UTILS/lua/get_meta_file'

-- CHANGE BELOW 
local meta_data_file = script_dir .. "/occupancy/occupancy_meta.lua"
local data_file     = script_dir .. "/occupancy/occupancy.csv"
local split_ratio   = 0.8
local goal = "occupy_status"
-- CHANGE ABOVE

-- T = load_data(meta_data_file, data_file)
T = Q.load_csv(data_file, dofile(meta_data_file))
Train, Test = split(T, split_ratio)
g_train = assert(Train[goal]); Train[goal] = nil
g_test  = assert(Test[goal]);  Test[goal] = nil
n_train = g_train:length()
n_test  = g_test:length()
local m = 0
for k, v in pairs(Train) do m = m + 1 end 


alpha = Q.const({ val = 1, len = m, qtype = "F4"}):eval()
vote = {}
local x
for g = 0, 1 do -- 2 values of goal. Hard coded for now. 
  local gval = Scalar.new(g, "I4")
  x = Q.vseq(g_train, gval)
  local l_train = {}
  for attr, vec in pairs(Train) do
    l_train[attr] = Q.where(vec, x):eval():set_name("test")
    n_train = l_train[attr]:length()
  end
  

  vote[g] = Q.const({ val = 0, len = n_test, qtype = "F4"}):eval()
  alt_voting(l_train, m, n_train, alpha, Test, n_test, vote[g])
  -- Q.print_csv(vote[g])
end
x = nil



  



Q.save(get_meta_file())
print("Done")

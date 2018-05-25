local Q = require 'Q'
local Scalar = require 'libsclr'
local plpath = require 'pl.path'
local alt_voting = require 'alt_voting'
local alt_scale = require 'alt_scale'
local prediction_from_votes = require 'prediction_from_votes'

local q_src_root = os.getenv("Q_SRC_ROOT")
assert(plpath.isdir(q_src_root))
local script_dir = q_src_root .. "/ML/KNN/data/"
assert(plpath.isdir(script_dir))

local function delete_attr(T, g)
  local g_attr = assert(T[g]); 
  x = {}
  for k, v in pairs(T) do 
    if ( k ~= g ) then
      x[k] = v
    end
  end
return x, g_attr
end

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
-- TODO T = delete_attr(T, goal)
Train, g_train = delete_attr(Train, goal)
Test,  g_test  = delete_attr(Test,  goal)

n_train = g_train:length()
n_test  = g_test:length()

local n
for k, v in pairs(Train) do 
  n = v:length(); 
  -- local filename = "_" .. k; Q.print_csv(v, { opfile = filename})
end

alt_scale(T, m, n)

alpha = Q.const({ val = 1, len = m, qtype = "F4"}):eval()
vote = {}
num_g = {}
local x
for g = 0, 1 do -- 2 values of goal. Hard coded for now. 
  local gval = Scalar.new(g, "I4")
  x = Q.vseq(g_train, gval)
  local l_train = {}
  for attr, vec in pairs(Train) do
    l_train[attr] = Q.where(vec, x):eval():set_name("test")
    n_train = l_train[attr]:length()
    num_g[g] = n_train
  end
  

  vote[g] = Q.const({ val = 0, len = n_test, qtype = "F4"}):eval()
  alt_voting(l_train, m, n_train, alpha, Test, n_test, vote[g])
  -- Q.print_csv(vote[g])
end
g_predicted = prediction_from_votes(vote) -- pass n_g ?
-- local jnk = Q.vveq(g_predicted, g_test):eval()
local n1, n2 = Q.sum(Q.vveq(g_predicted, g_test)):eval()
local accuracy = Scalar.new(100, "F8") * n1:conv("F8") / n2:conv("F8")
n1:conv("I8")
n2:conv("I8")
print("Accuracy is " .. n1:to_str() .. " out of " .. n2:to_str() .. " = " .. accuracy:to_str())
Q.print_csv({vote[0], vote[1], g_predicted, g_test}, { opfile = "_x" })

Q.save(get_meta_file())
print("Done")

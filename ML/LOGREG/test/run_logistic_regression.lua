require 'Q/UTILS/lua/strict'
local plpath  = require 'pl.path'
local Q       = require 'Q'
local make_betas = require 'Q/ML/LOGREG/lua/make_betas'
--=================================================
-- START: modifications for different data sets
data_set = "study_hours_vs_pass"

data_dir = os.getenv("Q_SRC_ROOT") .. "/ML/LOGREG/data/" .. data_set
assert(plpath.isdir(data_dir))
meta_dir = "Q/ML/LOGREG/data/" .. data_set 

local train_file = data_dir .. "/train.csv"
local meta       = require(meta_dir .. "/meta")
local optargs    = require(meta_dir .. "/opt")
local goal       = "pass"
local num_iters  = 1000
-- STOP : modifications for different data sets
--=================================================
--[[
for i = 1, 100 do
  local betas = make_betas(train_file, meta, optargs, goal, num_iters)
  Q.print_csv(betas)
end
assert(nil, "PREMATURE")
--]]

local betas = Q.mk_col({ 1.5046, -4.0777}, "F8")

for i = 1, 1000 do 
  local predict1 = require 'Q/ML/LOGREG/lua/predict1'
  local x = Q.mk_col({ 2, 1 }, "F4")
  local prob = predict1(betas, x)
  print(i, prob)
end

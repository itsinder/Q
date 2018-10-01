local Q = require 'Q'
local Scalar = require 'libsclr'
local load_alpha = require 'load_alpha'
local extend = require 'extend'

local T = {}
local M = { 
   { name = "x", has_nulls = false, qtype = "I4", is_load = true }, 
   { name = "y", has_nulls = false, qtype = "I4", is_load = true }, 
 }
local datafile = "../data/2.csv"
tmp = Q.load_csv(datafile, M); 
x = tmp.x
y = tmp.y

null_val = Scalar.new(1000000000, "I4")

z1 = Q.concat(x, y)
w  = Q.const({val = null_val, len = x:length(), qtype = "I4"})
z2 = Q.concat(y, w)
z = Q.cat({z1, z2})
assert(z:length() == z1:length() + z2:length())
Q.sort(z, "ascending")
x, y = Q.split(z)
x:eval()
y:eval()
-- basic test on concat/split
local n1, n2 = Q.sum(Q.vseq(x, null_val)):eval()
assert(n1:to_num() == 0, n1)
n1, n2 = Q.sum(Q.vseq(y, null_val)):eval()
assert(n1:to_num() > 0)
assert(Q.is_next(x, "geq"):eval() == true)
Q.print_csv({x,y}, { opfile = "_1.csv"})
--=====
z = Q.is_prev(x, "neq", {default_val = 1}):eval()
local t1, t2 = Q.sum(z):eval()
print(t1, t2)
xlbl = Q.where(x, z):eval()
ylbl = Q.where(y, z):eval()
y = Q.get_idx_by_val(ylbl, xlbl)
local n0 = xlbl:length()
x = Q.seq( { start = 0, by = 1, qtype = "I4", len = n0})

-- Q.print_csv({x, y, xidx, yidx}, { opfile = "_2.csv"})
-- prepare T0
T0 = {}
T0.x = x
T0.y = y
T0.xlbl = xlbl
ylbl = nil
Q.print_csv({T0.x, T0.y}, { opfile = "_T0.csv"})
-- T0.y = y, we do not need this guy
--===================
-- prepare T1
c = Q.vsneq(T0.y, -1)
T0.d = Q.ifxthenyelsez(c, Scalar.new(1, "I4"),Scalar.new(0, "I4")):eval()
T0.r = Q.rand({ lb = 0, ub = 1000, seed = 1234, qtype = "F4", len = n0 }):eval()
T0.s = Q.const({ val = 0, qtype = "F4", len = n0 }):eval()
T = {}
T[#T+1] = {}
T[#T].x = Q.where(T0.x, c)
T[#T].y = Q.where(T0.y, c)
Q.print_csv({T[#T].x, T[#T].y}, { opfile = "_T1.csv"})

local max_d = 8
local alpha = load_alpha()
while true do 
  print("--------------")
  local a =  extend(T[#T], T0.y)
  if ( not a ) then break end 
  T[#T+1] = a
  Q.print_csv({T[#T].x, T[#T].y}, { opfile = "_T" .. #T .. ".csv"})
  Q.set_sclr_val_by_idx(T[#T].x, T0.d, {sclr_val = #T})
  print("#T = ",  #T )
  if ( #T >= max_d ) then break end 
  Q.print_csv(Q.numby(T0.d, #T+1):eval())
end
for k = 1, #T do
  print(" k = ", k)
  T[k].d = Q.get_val_by_idx(T[k].x, T0.d)
  T[k].r = Q.get_val_by_idx(T[k].x, T0.r)
  T[k].alpha = Q.get_val_by_idx(T[k].d, alpha[k])
  local s = Q.vvmul(T[k].r, T[k].alpha)
  Q.add_vec_val_by_idx(T[k].y, s, T0.s)
end
Q.print_csv({T0.x,T0.y, T0.d, T0.r, T0.s}, { opfile = "_final.csv"})

print("ALL DONE")

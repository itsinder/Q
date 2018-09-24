local Q = require 'Q'
local Scalar = require 'libsclr'

local function extend(inT, y0)
  assert(type(inT) == "table")
  local xk = inT.x
  local yk = inT.y
  assert(type(xk) == "lVector")
  assert(type(yk) == "lVector")
  assert(type(y0) == "lVector")
  local z = Q.get_val_by_idx(yk, y0)
  local w = Q.vsgeq(z, 0)
  local xnew = Q.where(xk, w)
  local ynew = Q.where(z, w)
  local T = {}
  T.x = xnew:eval()
  T.y = ynew:eval()
  return T
end

-- load data as (referee, referer)
-- T = Q.load_csv("../data/
-- we know that data is sorted on referee
-- since each person can be refered by at most one person
-- 1, 2
-- 1, 3
-- needs to become
-- 1, 2

local T = {}
local M = { 
   { name = "x", has_nulls = false, qtype = "I4", is_load = true }, 
   { name = "y", has_nulls = false, qtype = "I4", is_load = true }, 
 }
local datafile = "../data/1.csv"
tmp = Q.load_csv(datafile, M); 
x = tmp.x
y = tmp.y

-- w = Q.v_isnextneq(x)
-- x = Q.where(x, w)
-- y = Q.where(y, w)
-- TODO FIX Q.print_csv(tmp, {lb = 0, ub = 10})

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
-- Q.print_csv({x,y}, { opfile = "_1.csv"})
--=====
z = Q.is_prev(x, "neq", {default_val = 1})
xlbl = Q.where(x, z)
ylbl = Q.where(y, z)
y = Q.get_idx_by_val(ylbl, xlbl)
x = Q.seq( { start = 0, by = 1, qtype = "I4", len = xlbl:length()})

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
T0.d = Q.ifxthenyelsez(c, Scalar.new(1, "I4"),Scalar.new(0, "I4"))
T1 = {}
T1.x = Q.where(T0.x, c)
T1.y = Q.where(T0.y, c)
Q.print_csv({T1.x, T1.y}, { opfile = "_T1.csv"})

T2 = extend(T1, T0.y)
Q.print_csv({T2.x, T2.y}, { opfile = "_T2.csv"})
Q.set_sclr_val_by_idx(T2.x, T0.d, {sclr_val = 2})
local rslt = Q.numby(T0.d, 2+1)
print("===============")
Q.print_csv(rslt)
print("===============")

T3 = extend(T2, T0.y)
Q.print_csv({T3.x, T3.y}, { opfile = "_T3.csv"})
assert(nil, "PREMATURE")



len = T.referee:length()
x = Q.isnextgt(T.referee)
referee = Q.where(T.referee, x)
referer = Q.where(T.referer, x)
T0 = {}
T0.x = Q.seq({len = len, start = 0, by = 1, qtype = "I4"})
T0.id = T.referee
-- T0.y = TODO  T.referer
T0.r = Q.rand( { lb = 1, ub = 1000, seed = 1234, qtype = "F4", len = len})



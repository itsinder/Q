local Q = require 'Q'
local Scalar = require 'libsclr'
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
Q.print_csv({x,y}, { opfile = "_x.csv"})
--=====
z = Q.is_prev_eq(y, {default = 1})
z = Q.vvnot(z)
x = Q.where(x, z)
y = Q.where(y, z)
--===================

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



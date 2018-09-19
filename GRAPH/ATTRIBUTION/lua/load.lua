-- load data as (referee, referer)
-- T = Q.load_csv("../data/
-- we know that data is sorted on referee
-- since each person can be refered by at most one person
-- 1, 2
-- 1, 3
-- needs to become
-- 1, 2

local T = {}
local M = { { name = "x", has_nulls = false, qtype = "I4", is_load = true }, }
local tmp = Q.load_csv("from.csv" M); T.referee = tmp.x
      tmp = Q.load_csv("to.csv" M);   T.referer = tmp.x

-- START: Invariant 
y = Q.isnextlt(T.referee)
local n = Q.sum(y):eval()
assert(n == 0)
-- TODO get meta data for is_sorted
-- STOP : Invariant 
len = T.referee:length()
x = Q.isnextgt(T.referee)
referee = Q.where(T.referee, x)
referer = Q.where(T.referer, x)
T0 = {}
T0.x = Q.seq({len = len, start = 0, by = 1, qtype = "I4"})
T0.id = T.referee
-- T0.y = TODO  T.referer
T0.r = Q.rand( { lb = { 1, ub = 1000, seed = 1234, qtype = "F4", len = len})



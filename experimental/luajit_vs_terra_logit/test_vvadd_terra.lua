--require 'terra'
local qc = require 'Q/UTILS/lua/q_core'

local Q = require 'Q'
local col_1 = Q.const({ val = 1, qtype = "I1", len = 50000000} ):eval()
local start_timer = qc.RDTSC()
local res = Q.logit(col_1):eval()
local stop_timer = qc.RDTSC()
print("logit required time", stop_timer - start_timer)

local Q = require 'Q'
local ldnn = require 'Q/RUNTIME/DNN/lua/ldnn'
local qc = require 'Q/UTILS/lua/q_core'
require 'Q/UTILS/lua/strict'

local tests = {}
Xin = {}
Xout = {}
npl = {}
dpl = {}
afns = {}
tests.t1 = function(batch_size)
  local batch_size = batch_size or 4096
  local saved_file_path = "dnn_in.txt"
  local n_samples = 1024 * 1024
  print("batch size = ", batch_size)

--[[
  npl = { 128, 64, 32, 8, 4, 2, 1 }
  dpl = { 0, 0, 0, 0, 0, 0, 0 }
  afns = { '', 'relu', 'relu', 'relu', 'relu', 'relu', 'sigmoid' }
  for i = 1, npl[1] do
    Xin[i] = Q.rand( { lb = -2, ub = 2, seed = 1234, qtype = "F4", len = n_samples }):eval()
  end
  Xout[1] = Q.convert(Q.rand( { lb = 0, ub = 2, seed = 1234, qtype = "I1", len = n_samples }), "F4"):eval()
  Q.save(saved_file_path)
  os.exit()
--]]
  -- For the first time, enable the above code block and then onwards just restore it
  Q.restore(saved_file_path)

  print("Network structure")
  print("n_layers = " .. #npl)
  local npl_str = ''
  for i, v in pairs(npl) do
    npl_str = npl_str .. "-" .. tostring(v)
  end
  print("structure = " .. npl_str)
  local start_t = qc.RDTSC()
  local x = ldnn.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  local end_t = qc.RDTSC()
  print("dnn_new = " .. tostring(end_t - start_t))
  -- assert(x:check())

  start_t = qc.RDTSC()
  x:set_io(Xin, Xout)
  end_t = qc.RDTSC()
  print("set_io = " .. tostring(end_t - start_t))

  start_t = qc.RDTSC()
  x:set_batch_size(batch_size)
  end_t = qc.RDTSC()
  print("set_batch = " .. tostring(end_t - start_t))

  print("training started")
  start_t = qc.RDTSC()
  x:fit(1)
  end_t = qc.RDTSC()
  print("fit = " .. tostring(end_t - start_t))
  print("Test t4 succeeded")
end
return tests


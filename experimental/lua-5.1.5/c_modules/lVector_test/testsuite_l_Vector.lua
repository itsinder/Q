local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'
local dbg    = require 'Q/UTILS/lua/debugger'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))

--===================
function pr_meta(x, file_name)
  local T = x:meta()
  local temp = io.output() -- this is for debugger to work 
  io.output(file_name)
  io.write(" return { ")
  for k1, v1 in pairs(T) do 
    for k2, v2 in pairs(v1) do 
      io.write(k1 .. "_" ..  k2 .. " = \"" .. tostring(v2) .. "\",")
      io.write("\n")
    end
  end
  io.write(" } ")
  io.close()
  io.output(temp) -- this is for debugger to work 
  return T
end
--=========================
function compare(f1, f2)
  local s1 = plfile.read(f1)
  local s2 = plfile.read(f2)
  assert(s1 == s2, "mismatch in " .. f1 .. " and " .. f2)
end
--=========================

local assert_valid = function(index, num_elements, field_size)
  return function (x)
    -- TODO: checking part will be done in a separate check function
    -- generalized check function is yet to be implemented
    -- print(type(x))
    assert(x:check())
    pr_meta(x,script_dir.. "/_meta_TC_"..index.."before")
    x:eov()
    local md = pr_meta(x,script_dir.. "/_meta_TC_"..index.."after")
    -- assert(plpath.getsize(md.base.file_name) == num_elements * field_size) -- scalar and itr*10
    -- assert(plpath.getsize(T.base.file_name) == (num_chunks * chunk_size * 4)) -- gen function
    print("filesize "..plpath.getsize(md.base.file_name))
    -- checking if the file persist after eov
    -- assert(plpath.isfile(script_dir.."/"..md.base.file_name),"File does not exists even after eov") 
    return true
  end
end

local create_tests = function() 
  local tests = {}  
  
  local T = dofile(script_dir .."/map_lVector.lua")
  for i, v in ipairs(T) do
    local M = dofile(script_dir .."/meta_data/"..v.meta)
    -- print("--------------------------------------------")
    local test_name = v.name
    local num_elements = v.num_elements
    local field_size = qconsts.qtypes[M.qtype].width
    local gen_method
    if v.gen_method then gen_method = v.gen_method end
    -- print("Running testcase "..v.testcase_no.." : "..test_name)
    table.insert(tests, {
      input = { M, gen_method, num_elements, field_size},
      check = assert_valid(i, num_elements, field_size),
      name = test_name
    })                      
  end
  return tests
end 

local suite = {}
suite.tests = create_tests()
--require 'pl'
--pretty.dump(suite.tests)
-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end

suite.test_for = "lVector"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite
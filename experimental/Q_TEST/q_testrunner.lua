local run_tests = function(tests, name)
    if (name) then 
        local n = tonumber(name)
        if n then name = n end
        local test = tests[name]
        if test then test() else print("Test " .. name .. " not found!") end
    else
        local pass = {}
        local fail = {}
        for k,v in pairs(tests) do
            local status = pcall(v)
            if (status) then table.insert(pass, k) else table.insert(fail,k) end
        end
        return pass, fail
    end
end

local run_suite = function(suite_name, test_name)
    print ("Running suite " .. suite_name)
    if (test_name) then print ("Running only test in unsafe mode " .. test_name) end
    local tests = dofile(suite_name)
    if (test_name) then
        run_tests(tests, test_name)  -- one shot
    else
        return run_tests(tests)
    end
end

local plpath = require 'pl.path'
local plpretty = require "pl.pretty"
local q_root = assert(os.getenv("Q_ROOT"))
assert(plpath.isdir(q_root))
assert(plpath.isdir(q_root .. "/data/"))
os.execute("rm -r -f " .. q_root .. "/data/*")
require('Q/UTILS/lua/cleanup')()

local suite_name = arg[1]
local test_name = arg[2]

if (suite_name) then
    local pass,fail = run_suite(suite_name, test_name)
    if pass then
        print("PASS: " .. plpretty.write(pass, "") .. "; FAIL: " .. plpretty.write(fail, ""))
    end
else
    local files = (require "q_test_discovery")("/home/srinath/Ramesh/Q/experimental/Q_TEST/")
    local res = {}
    for _,f in pairs(files) do
        res[f] = {}
        res[f].pass, res[f].fail = run_suite(f)
    end
    print(plpretty.write(res))
    -- TODO?
    --utils["testcase_results"](test, suite.test_for, suite.test_type, result, "")
end
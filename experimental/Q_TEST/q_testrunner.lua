--[[
For the purposes of this tool, below are axiomatic defintions:
"Test"/"Test case": A lua function that takes no arguments, and returns nothing. It is typically 
expected that this function will test some behavior using assert's.

"Pass": A test is considered to pass if it returns successfully without any errors
"Fail": A test is considered to fail if it raises an error (typically due to a failed assert)

"Test suite": A .lua file that, when require'd, returns an table of test cases. For each entry of the
table, the key acts as the identifier/name of a test case, the value is the test case itself.
Note that the table can also be an array, in which case the index-into-array is the identifier for the
test cases in that suite.

Run luajit q_testrunner.lua to see its usage.
]]

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
    print ("Running suite " .. suite_name .. "...")
    if (test_name) then print ("Running only test " .. test_name .. " in unsafe mode..." ) end
    local tests = dofile(suite_name)
    if (test_name) then
        run_tests(tests, test_name)  -- one shot
    else
        return run_tests(tests)
    end
end

local usage = function() 
    print("USAGE:")
    print("luajit q_testrunner.lua <root_dir>")    
    print("luajit q_testrunner.lua <suite_file> [<test_case_id>]")
end

local plpath = require 'pl.path'
local plpretty = require "pl.pretty"
local q_root = assert(os.getenv("Q_ROOT"))
assert(plpath.isdir(q_root))
assert(plpath.isdir(q_root .. "/data/"))
os.execute("rm -r -f " .. q_root .. "/data/*")
require('Q/UTILS/lua/cleanup')()

local path = arg[1]
local test_name = arg[2]

if (path and plpath.isfile(path)) then
    local pass,fail = run_suite(path, test_name)
    if pass then
        print("PASS: " .. plpretty.write(pass, "") .. "; FAIL: " .. plpretty.write(fail, ""))
    end
else
    -- run all tests in a DIR, either custom or default Q_SRC_ROOT
    if not (path and plpath.isdir(path)) then 
        usage()
        os.exit()
    end
    print ("Discovering and running all test suites under " .. path)
    local files = (require "q_test_discovery")(path)
    local res = {}
    for _,f in pairs(files) do
        res[f] = {}
        res[f].pass, res[f].fail = run_suite(f)
    end
    print(plpretty.write(res))
    -- TODO?
    --utils["testcase_results"](test, suite.test_for, suite.test_type, result, "")
end
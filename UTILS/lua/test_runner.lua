local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end

return function (suite, fn, tests_to_run)
  local status, res
  local failures = ""
  if tests_to_run == nil then
    tests_to_run = {}
    for i=1,#suite.tests do 
      table.insert(tests_to_run, i)
    end
  end
  
  local function myassert(cond, i) 
    if not cond then failures = failures .. i .. "," end
  end
  
  local test
  call_if_exists(suite.setup)
  
  for k,test_num in pairs(tests_to_run) do
    print ("running test " .. test_num)
    test = suite.tests[test_num]
    call_if_exists(test.setup)
    status, res = pcall(fn, unpack(test.input))
    if test.fail then
      myassert (status == false, test_num)
      myassert (string.match(res, test.fail), test_num)
    else
      myassert (status, test_num)
      myassert (test.check(res), test_num)
    end
    call_if_exists(test.teardown)
  end
  call_if_exists(suite.teardown)
  return failures
end
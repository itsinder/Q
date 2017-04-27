return function (testdata, fn, tests_to_run)
  local status, res
  local failures = ""
  if tests_to_run == nil then
    tests_to_run = {}
    for i=1,#testdata do 
      table.insert(tests_to_run, i)
    end
  end
  local test
  local function myassert(cond, i) 
    if not cond then failures = failures .. i .. "," end
  end
  for k,test_num in pairs(tests_to_run) do
    print ("running test " .. k)
    test = testdata[test_num]
    status, res = pcall(fn, unpack(test.input))
    if test.fail then
      myassert (status == false, test_num)
      myassert (string.match(res, test.fail), test_num)
    else
      myassert (status, test_num)
      myassert (test.check(res), test_num)
    end
  end
  
  return failures
end
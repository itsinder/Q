return function (testdata, fn)
  local status, res
  for k,v in pairs(testdata) do
    print ("running test " .. k)
    status, res = pcall(fn, unpack(v.input))
    if v.fail then
      assert (status == false)
      assert (string.match(res, v.fail))
    else
      assert (status)
      v.check(res)
    end
  end
end
local fns = {}

fns.assert_qtype = function(expected)
  return function (ret)
    for k,v in ipairs(ret) do
      if ret[k] ~= expected[k] then return false end
    end
    return true
  end
end

fns.assert_bit = function(expected)
  return function (ret)
    return ret[1] == expected[1]
  end
end

return fns
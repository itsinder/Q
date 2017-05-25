
return function(expected)
  return function (ret)
    for k,v in ipairs(ret) do
      --print ( ret[k], expected[k])
      if ret[k] ~= expected[k] then return false end
    end
    return true
  end
end

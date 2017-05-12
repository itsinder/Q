return function(expected)
  return function (func_res)
    local actual = utils.col_as_str(func_res)
    -- print (actual)
    return actual == expected
    -- , "Expected" .. expected .. " but was " .. actual)
    -- print (func_res.vec.filename)
    -- TODO assert out_col file size  
  end
end

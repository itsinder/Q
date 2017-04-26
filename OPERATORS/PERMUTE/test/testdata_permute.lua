--local val_qtypes = {"I1", "I2", "I4", "I8", "F4", "F8"}
--local idx_qtypes = {"I1", "I2", "I4", "I8"}

-- mk_col faltering for I2/I8 ??!!
local val_qtypes = {"I4","I8"}
local idx_qtypes = {"I4","I8"}

local data = {}

local explode_types = function (val_tab, idx_tab, idx_in_src, expected)
  local expectedOut;
  for k1,vqt in pairs(val_qtypes) do
    for k2, iqt in pairs(idx_qtypes) do
      -- TODOexpectedOut = if/else expr did not work.. TERRA ISSUE?!
      if (vqt == 'I8') then 
        expectedOut = string.gsub(expected, ",", "LL,") 
      else         
        expectedOut = expected 
      end      
      table.insert(data, {
        input = {mk_col(val_tab, vqt), mk_col(idx_tab, iqt), idx_in_src},
        output = expectedOut
      })
    end
  end
end

explode_types({10, 20, 30, 40, 50, 60}, {0, 5, 1, 4, 2, 3}, true, "10,60,20,50,30,40,")
explode_types({10, 20, 30, 40, 50, 60}, {0, 5, 1, 4, 2, 3}, false, "10,30,50,60,40,20,")
--print (table.tostring(data))

return {
  -- add any special test cases here
  {
    input = {
            mk_col ({10, 20, 30, 40, 50, 60}, "I4"),
            mk_col({0, 5, 1, 4, 2, 3}, "F4"),
            false},
    fail = "idx column must be integer type"
  },
  -- unpack all the other test cases here
  unpack(data)
}
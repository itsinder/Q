local qtils = require 'Q/QTILS/lua/is_sorted'
local sort = require 'Q/OPERATORS/SORT/lua/sort'

local sort_vector = function(a)
  -- NOTE: For unique operator, input vector needs to be sorted(asc/dsc)  
  local sort_order = a:get_meta("sort_order")
  -- if sort_order field is nil then check the input vector for sort order
  if ( sort_order == nil ) then
    -- calling an utility called is_sorted(vec)
    local status, order = qtils.is_sorted(a)
    -- if input vector is not sorted, cloning and sorting that cloned vector
    if status == false and order == nil then
      local a_clone = a:clone()
      sort(a_clone, "asc")
      a = a_clone
    else
      assert( status == true, "is_sorted utility failed")
      assert( order, "input vector not sorted")
      a:set_meta( "sort_order", order)
    end
  end

  -- getting updated sort_order meta value if sort_order was nil
  sort_order = a:get_meta( "sort_order" )
  assert( (sort_order == "asc") or ( sort_order == "dsc" ),
      "input vector not sorted")
  return a 
end

return sort_vector
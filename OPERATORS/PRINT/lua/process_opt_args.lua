local utils	= require 'Q/UTILS/lua/utils'

local function process_opt_args(vec_list, opt_args)
  local opfile
  local filter
  local print_order
  local status, vector_list
  
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["opfile"] ~= nil then
      opfile = opt_args["opfile"]
    end
    if opt_args["filter"] ~= nil then
      filter = opt_args["filter"]
    end
    if opt_args["print_order"] ~= nil then
      assert(type(opt_args["print_order"]) == "table", 
      "type of print_order is not table")
      print_order = opt_args["print_order"]
      -- sort vec_list according to given print_order
      vector_list = utils.sort_table(vec_list, print_order)
    else
      vector_list = vec_list
    end
  else
    -- returning vec_list as it is
    vector_list = vec_list
  end
  
  return vector_list, opfile, filter
end

return  process_opt_args
local function process_opt_args(opt_args)
  -- opt_args default values
  -- use_accelerator is set to true
  -- is_hdr is set to false
  local use_accelerator = true
  local is_hdr = false
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["use_accelerator"] ~= nil then
      assert(type(opt_args["use_accelerator"]) == "boolean", 
      "type of use_accelerator is not boolean")
      use_accelerator = opt_args["use_accelerator"]
    end
    if opt_args["is_hdr"] ~= nil then
      assert(type(opt_args["is_hdr"]) == "boolean", 
      "type of is_hdr is not boolean")
      is_hdr = opt_args["is_hdr"]
    end
  end
  -- assert(M.qtype ~= "B1" and use_accelerator ~= false," qtype B1 not supported in load_csv lua")
  return use_accelerator, is_hdr
end
return  process_opt_args
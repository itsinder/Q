local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

local qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
-- TODO: add left operations in below table
local join_type = {"sum", "min", "max", "min_idx", "max_idx", "count", "and", "or"}

local num_produced = 0
local status
local sp_fn = assert(require("join_specialize"))

local function generate_files(src_lnk_qtype, src_fld_qtype, out_qtype, join_type, args)
  local status, subs, tmpl = pcall(sp_fn, src_lnk_qtype, src_fld_qtype, out_qtype, join_type, args)
  if ( status ) then
    assert(type(subs) == "table")
    gen_code.doth(subs,tmpl, incdir)
    gen_code.dotc(subs, tmpl, srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  else
    assert(nil, subs)
  end
  return true
end

for _, src_lnk_qtype in ipairs(qtypes) do 
  for _, src_fld_qtype in ipairs(qtypes) do
    for _, op in ipairs(join_type) do
      local out_qtype
      if op == "sum" then
        if ( ( src_fld_qtype == "I1" ) or ( src_fld_qtype == "I2" ) or 
          ( src_fld_qtype == "I4" ) or ( src_fld_qtype == "I8" ) ) then
          out_qtype = "I8" 
        elseif ( ( src_fld_qtype == "F4" ) or ( src_fld_qtype == "F8" ) ) then
          out_qtype = "F8" 
        end
      elseif op == "min" or op == "max" then
        out_qtype = src_fld_qtype
      elseif op == "min_idx" or op == "max_idx" or op == "count" or op == "and" or op == "or" then
        out_qtype = "I8"
      else
        -- TODO : for arbitary abd exists?
      end
      status = pcall(generate_files, src_lnk_qtype, src_fld_qtype, out_qtype, op )
      assert(status, 
     "Failed to generate files for safe mode" .. src_lnk_qtype .. src_fld_qtype .. out_qtype)
    end
  end
end
assert(num_produced > 0)

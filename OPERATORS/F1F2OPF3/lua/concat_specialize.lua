
return function (
  f1type, 
  f2type, 
  optargs
  )
    local plfile = require "pl.file"
    local out_qtype = optargs.out_qtype -- okay for out_qtype to be nil
    local ok_intypes = { I1 = true, I2 = true, I4 = true }
    local ok_out_qtypes = { I2 = true, I4 = true, I8 = true }

    assert(ok_intypes[f1type], "input type " .. f1type .. " not acceptable")
    assert(ok_intypes[f2type], "input type " .. f2type .. " not acceptable")

    local w1   = assert(g_qtypes[f1type].width)
    local w2   = assert(g_qtypes[f2type].width)

    local shift = w2 * 8 -- convert bytes to bits 
    local l_out_qtype = nil
    if ( f1type == "I4" ) then 
      l_out_qtype = "I8"
    elseif( f1type == "I2" ) then 
      if ( f2type == "I4" ) then
        l_out_qtype = "I8"
      elseif( f2type == "I2" ) then
        l_out_qtype = "I4"
      elseif( f2type == "I1" ) then
        l_out_qtype = "I4"
      end
    elseif( f1type == "I1" ) then 
      if ( f2type == "I4" ) then
        l_out_qtype = "I8"
      elseif( f2type == "I2" ) then
        l_out_qtype = "I4"
      elseif( f2type == "I1" ) then
        l_out_qtype = "I2"
      end
    end
    assert(l_out_qtype, "Control should never come here")
    assert(ok_out_qtypes[l_out_qtype], "output type " .. 
    l_out_qtype .. " not acceptable")
    if ( out_qtype ) then 
      assert(ok_out_qtypes[out_qtype], "output type " ..
      out_qtype .. " not acceptable")
      local width_l_out_qtype = assert(g_qtypes[l_out_qtype].width, "ERROR")
      local width_out_qtype   = assert(g_qtypes[out_qtype].width, "ERROR")
      assert( width_out_qtype >= width_l_out_qtype,
      "specfiied outputtype not big enough")
      l_out_qtype = out_qtype
    end
    local tmpl = plfile.read('base.tmpl')
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = "#include <math.h>\n#include <curl/curl.h>"
    subs.fn = 
    "concat_" .. f1type .. "_" .. f2type .. "_" .. l_out_qtype 
    subs.in1type = g_qtypes[f1type].ctype
    subs.in2type = g_qtypes[f2type].ctype
    subs.out_qtype = l_out_qtype
    subs.out_ctype = g_qtypes[l_out_qtype].ctype
    subs.c_code_for_operator = 
    " c = ( (" .. subs.out_ctype .. ")a << " .. shift .. " ) | b; "

    return subs, tmpl
end

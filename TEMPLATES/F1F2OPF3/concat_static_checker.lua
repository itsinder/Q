
function concat_static_checker(
  f1type, 
  f2type, 
  fouttype
  )

    local w1   = g_qtypes[f1type].width
    local w2   = g_qtypes[f2type].width
    local wout = g_qtypes[fouttype].width
    local shift = w2 * 8 -- convert bytes to bits 
    if not ( ( f1type == "I1" ) or 
      ( f1type == "I2" ) or 
      ( f1type == "I4" ) ) then
      print("concat requires fldtype of 1st argument to be I1/I2/I4")
      return nil
    end
    if not ( ( f2type == "I1" ) or 
      ( f2type == "I2" ) or 
      ( f2type == "I4" ) ) then
      print("concat requires fldtype of 1st argument to be I1/I2/I4")
      return nil
    end
    local l_outtype = nil
    if ( f1type == "I4" ) then 
      l_outtype = "I8"
    elseif( f1type == "I2" ) then 
      if ( f2type == "I4" ) then
        l_outtype = "I8"
      elseif( f2type == "I2" ) then
        l_outtype = "I4"
      elseif( f2type == "I1" ) then
        l_outtype = "I4"
      end
    elseif( f1type == "I1" ) then 
      if ( f2type == "I4" ) then
        l_outtype = "I8"
      elseif( f2type == "I2" ) then
        l_outtype = "I4"
      elseif( f2type == "I1" ) then
        l_outtype = "I2"
      end
    end
    if ( l_outtype == nil ) then 
      error("Control should never come here")
    end

    local l_wout = g_qtypes[l_outtype].width
    if ( fouttype ~= nil ) then 
      valid_outtype = { "I1", "I2", "I4", "I8" }
      if ( valid_outtype[fouttype] ) then 
        print("fouttype is not valid destination type for concat")
        return nil
      end
      if ( l_wout >= wout ) then 
        l_outtype = fouttype
      else
        print("specified output type is not big enough")
        return nil
      end
    end
    includes = {"math", "curl/curl" }
    substitutions = {}
    substitutions.fn = 
    "concat_" .. f1type .. "_" .. f2type .. "_" .. l_outtype 
    substitutions.in1type = g_qtypes[f1type].ctype
    substitutions.in2type = g_qtypes[f2type].ctype
    substitutions.returntype = g_qtypes[l_outtype].ctype
    substitutions.scalar_op = 
    " c = ( (" .. substitutions.returntype .. ")a << " .. shift .. " ) | b "

    return substitutions, includes

end

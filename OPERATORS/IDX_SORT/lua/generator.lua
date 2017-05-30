  require 'Q/UTILS/lua/globals'

  local tmpl = dofile 'idx_qsort.tmpl'

  ordrs = { 'asc', 'dsc' }
  val_types = { "I1", "I2", "I4", "I8", "F4", "F8" }
  idx_types = { "I1", "I2", "I4", "I8" }

  for i, ordr in ipairs(ordrs) do 
    for j, val_type in ipairs(val_types) do 
      for k, idx_type in ipairs(idx_types) do 
        tmpl.srt_ordr = ordr
        tmpl.val_type_displ = val_type
        tmpl.val_type = g_qtypes[val_type].ctype
        tmpl.idx_type_displ = idx_type
        tmpl.idx_type = g_qtypes[idx_type].ctype
        -- TODO Check below is correct order/comparator combo
        if ordr == "asc" then c = "<" end
        if ordr == "dsc" then c = ">" end
        tmpl.comparator = c
        --======================
        fn = "qsort_" .. ordr .. "_val_" .. val_type .. "_idx_" .. idx_type
        doth = tmpl 'declaration'
        fname = "../gen_inc/" .. "_" .. fn .. ".h" 
        local f = assert(io.open(fname, "w"))
        f:write(doth)
        f:close()
        --======================
        dotc = tmpl 'definition'
        fname = "../gen_src/" .. "_" .. fn .. ".c" 
        local f = assert(io.open(fname, "w"))
        f:write(dotc)
        f:close()
        --======================
      end
    end
  end

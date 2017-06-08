  require 'Q/UTILS/lua/globals'
  q = require 'Q/UTILS/lua/q'
  local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
  -- TODO doc pending: specializer must return a function and an out_qtype
  local function expander_f1f2opf3(a, f1 , f2, optargs )
    -- Get name of specializer function. By convention
    local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
    local spfn = require(sp_fn_name)
    assert(type(f1) == "Column", "f1 must be a column")
    assert(type(f2) == "Column", "f2 must be a column")
    if ( optargs ) then assert(type(optargs) == "table") end
    status, subs, tmpl = pcall(spfn, f1:fldtype(), f2:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local f3_qtype = assert(subs.out_qtype)
    local f3_width = g_qtypes[f3_qtype].width
    f3_width = math.ceil(f3_width/8) * 8
    local f1_coro = assert(f1:wrap(), "wrap failed for x")
    local f2_coro = assert(f2:wrap(), "wrap failed for y")
    local f3_coro = coroutine.create(function()
      local f1_chunk, f2_chunk, f1_status, f2_status
      local f1_chunk_size = f1:chunk_size()
      local f2_chunk_size = f2:chunk_size()
      assert(f1_chunk_size == f2_chunk_size)
      local buff = q.malloc(f1_chunk_size * z_width)
      local nn_buff = nil -- Will be created if nulls in input
      if f1:has_nulls() or f2:has_nulls() then
        local width = g_qtypes["B1"].width
        local size = math.ceil(width/8) * 8
        nn_buff = q.malloc(size)
      end
      f1_status = true
      while (f1_status) do
        f1_status, f1_len, f1_chunk, nn_f1_chunk = coroutine.resume(f1_coro)
        f2_status, f2_len, f2_chunk, nn_f2_chunk = coroutine.resume(f2_coro)
        assert(f1_status == f2_status)
        if f1_status then
          ssert(f1_len == f2_len)
          assert(f1_len > 0)
          q[func_name](f1_chunk, f2_chunk, f1_len, buff)
          coroutine.yield(f1_len, buff, nn_buff)
        end
      end
    end)
    return Column{gen=f3_coro, nn=(nn_buf ~= nil), field_type=z_qtype}
  end

  return expander_f1f2opf3

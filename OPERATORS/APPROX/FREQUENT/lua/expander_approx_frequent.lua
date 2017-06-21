local Q       = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local Scalar  = require 'Q/RUNTIME/SCALAR/lua/Scalar'
local qc      = require 'Q/UTILS/lua/q_core'

local qtypes  = require 'Q/OPERATORS/APPROX/FREQUENT/lua/qtypes'
local spfn    = require 'Q/OPERATORS/APPROX/FREQUENT/lua/specializer_approx_frequent'

local function approx_frequent(x, min_freq, err)
  assert(type(x) == "Column", "x must be a column")
  local subs = spfn(x:fldtype())
  local x_coro = assert(x:wrap(), "approx_frequent wrap failed for x")

  local data = ffi.cast(subs.data_ty..'*', ffi.malloc(ffi.sizeof(subs.data_ty)))
  local out_coro = coroutine.create(function()
      local data = ffi.cast(subs.data_ty..'*', ffi.malloc(ffi.sizeof(subs.data_ty)))
      qc[subs.alloc_fn](x:length(), min_freq, err, x:chunk_size(), data)
      local status = true
      while status do
        local new_status, len, chunk = coroutine.resume(x_coro)
        status = new_status
        if status and len ~= nil then
          qc[subs.chunk_fn](chunk, len, data)
          coroutine.yield(data)
        end
      end
  end)

  local function getter(data)
    assert(coroutine.status(out_coro) == 'dead',
           'attempt to access approx_frequent value before all data has been processed')

    local y_ty = subs.elem_ctype..'*'
    local y = ffi.cast(y_ty..'*', ffi.malloc(ffi.sizeof(y_ty)))
    local f_ty = subs.freq_ctype..'*'
    local f = ffi.cast(f_ty..'*', ffi.malloc(ffi.sizeof(f_ty)))
    local len_ty = subs.out_len_ctype
    local len = ffi.cast(len_ty..'*', ffi.malloc(ffi.sizeof(len_ty)))

    qc[subs.out_fn](data, y, f, len)

    local y_col = Q.Column({field_type = subs.elem_qtype, write_vector = true})
    y_col:put_chunk(len[0], y[0])
    y_col:eov()

    local f_col = Q.Column({field_type = subs.freq_qtype, write_vector = true})
    f_col:put_chunk(len[0], f[0])
    f_col:eov()

    qc[subs.free_fn](data)
    return y_col, f_col, len[0]
  end

  return Scalar({ coro = out_coro, func = getter })
end

return approx_frequent

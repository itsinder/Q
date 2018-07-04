local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qtils = require 'Q/QTILS/lua/is_sorted'
local sort = require 'Q/OPERATORS/SORT/lua/sort'

local function expander_unique(op, a)
  -- Verification
  assert(op == "unique")
  assert(type(a) == "lVector", "a must be a lVector ")
  
  local sp_fn_name = "Q/OPERATORS/UNIQUE/lua/unique_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local sz_out          = qconsts.chunk_size 
  local sz_out_in_bytes = sz_out * qconsts.qtypes[a:qtype()].width
  local out_buf = nil
  local cnt_buf = nil
  local first_call = true
  local cidx = nil
  local aidx  = nil
  local a_chunk_idx = 0
  local last_unq_element = 0
  local brk_n_write
  
  -- NOTE: For unique operator, input vector needs to be sorted(asc/dsc)  
  local sort_order = a:get_meta( "sort_order")
  -- if sort_order field is nil then check the input vector for sort order
  if ( sort_order == nil ) then
    -- calling an utility called is_sorted(vec)
    local status, order = qtils.is_sorted(a)
    -- if input vector is not sorted, cloning and sorting that cloned vector
    if status == false and order == nil then
      local a_clone = a:clone()
      a_clone = sort(a_clone, "asc")
      a = a_clone
    else
      assert( status == true, "is_sorted utility failed")
      assert( order, "input vector not sorted")
      a:set_meta( "sort_order", order)
    end
  else
    assert( (sort_order == "asc") or ( sort_order == "dsc" ),
      "input vector not sorted")
  end

  local unique_vec = lVector( { gen = true, has_nulls = false, qtype = a:qtype() } )
  local cnt_vec = lVector( { gen = true, has_nulls = false, qtype = "I8" } )

  local function unique_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    --assert(chunk_num == a_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))
      cnt_buf = assert(cmem.new(sz_out * ffi.sizeof("int64_t")))

      cidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      cidx = ffi.cast("uint64_t *", cidx)

      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      
      last_unq_element = assert(get_ptr(cmem.new(ffi.sizeof(subs.a_ctype))))
      last_unq_element = ffi.cast(subs.a_ctype .. " *", last_unq_element)

      brk_n_write = assert(get_ptr(cmem.new(ffi.sizeof("bool"))))
      brk_n_write = ffi.cast("bool *", brk_n_write)

      first_call = false
    end
    
    -- Initialize num in out_buf to zero
    cidx[0] = 0
    brk_n_write[0] = false
    cnt_buf:zero()

    repeat 
      local a_len, a_chunk, a_nn_chunk = a:chunk(a_chunk_idx)
      
      if a_len == 0 then
        if tonumber(cidx[0]) > 0 then
          unique_vec:put_chunk(out_buf, nil, tonumber(cidx[0]))
          cnt_vec:put_chunk(cnt_buf, nil, tonumber(cidx[0]))
        end
        if tonumber(cidx[0]) < qconsts.chunk_size then
          unique_vec:eov()
          cnt_vec:eov()
        end
        return tonumber(cidx[0])
        -- return tonumber(cidx[0]), out_buf, nil 
      end
      assert(a_nn_chunk == nil, "Unique vector cannot have nulls")
      
      local casted_a_chunk = ffi.cast( subs.a_ctype .. "*",  get_ptr(a_chunk))
      local casted_out_buf = ffi.cast( subs.a_ctype .. "*",  get_ptr(out_buf))
      local casted_cnt_buf = ffi.cast( "int64_t *",  get_ptr(cnt_buf))
      local status = qc[func_name](casted_a_chunk, a_len, aidx, casted_out_buf, sz_out, cidx,
        last_unq_element, a_chunk_idx, casted_cnt_buf, brk_n_write )
      assert(status == 0, "C error in UNIQUE")

      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
    until ( tonumber(cidx[0]) == sz_out and brk_n_write[0] == true)

    -- Write values to vector
    unique_vec:put_chunk(out_buf, nil, tonumber(cidx[0]))
    cnt_vec:put_chunk(cnt_buf, nil, tonumber(cidx[0]))
    if tonumber(cidx[0]) < qconsts.chunk_size then
      unique_vec:eov()
      cnt_vec:eov()
    end
    return tonumber(cidx[0])
    --return tonumber(cidx[0]), out_buf, nil
  end
  unique_vec:set_generator(unique_gen)
  return unique_vec, cnt_vec
  --return lVector( { gen = unique_gen, has_nulls = false, qtype = a:qtype() } )
end

return expander_unique

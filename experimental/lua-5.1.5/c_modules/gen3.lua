local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'
local lVector = require 'lVector'

local counter = 1
local chunk_size = qconsts.chunk_size
local field_size = 4
local base_data = cmem.new(chunk_size * field_size)
local function expander_my_custom(f1, f2, optargs)
   -- currently exapnds f1 with the number of times given in f2
   -- test for valid stuff
   local state = {}
   local function gen3(chunk_idx, col)
      local f1_len, f1_chunk
      local f2_len, f2_chunk
      local start_f1, start_f2, count
      local f1_chunk_num , f2_chunk_num = chunk_idx, chunk_idx
      local init_count = 0
      if state.prev == nil then
         start_f1 = 1
         start_f2 = 1
      else
         local f1_chunk_num = state.prev.f1_chunk
         local f2_chunk_num = state.prev.f2_chunk

         local start_f1 = state.prev.start_f1
         local start_f2 = state.prev.start_f2
         init_count = state.prev.count
      end
      local data_size = 0 -- signifying that the chunk is empty
      repeat
         f1_len, f1_chunk = f1:chunk(f1_chunk_num)
         f2_len, f2_chunk = f2:chunk(f2_chunk_num)
         if f1_len == 0 or f2_len == 0 then
            break
         end
         for f1_index=start_f1, f1_chunk do
            local f1_val = f1_chunk[f1_index]
            for f2_index=start_f2, f2_chunk do
               local f2_val = f2_chunk[f2_index]
               for iter=init_count, f2_val do
                  base_data[data_size] = f1_val
                  -- check if full
                  if data_size + 1 == chunk_size then
                     local prev = {}
                     prev.start_f1 = f1_index
                     prev.start_f2 = f2_index
                     -- TODO fix so that previous chunk is not asked for aka
                     -- boundary condition
                     prev.count = iter + 1
                     prev.curr_chunk = chunk_idx
                     state.prev = prev
                     return chunk_size, base_data, nil
                  end
               end
            end
         end
         f1_chunk_num  = f1_chunk_num + 1
         f2_chunk_num = f2_chunk_num + 1
      until false
      return data_size, base_data, nil
   end
   return Column{gen=gen3, nn=false, field_type="I4"}
end
return expander_my_custom


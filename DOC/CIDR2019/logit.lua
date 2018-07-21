local function logit(v)
  local qtype = v:fldtype()
  local n     = qconsts.chunk_size
  local w     = qconsts.qtypes[qtype].width
  local cd2   = get_ptr(cmem.new(n*w, qtype, "buffer"))
  local v2    = lVector({gen = true, qtype = qtype})
  local cidx = 0 -- chunk index
  while true do 
    local n1, d1 = v1:chunk(cidx)
    if ( n1 == 0 ) then break end -- quit when no more input
    local cd1 = get_ptr(d1) -- access data of input
    for i = 0, n1 do -- the core operation is as follows
      cd2[i] = 1.0 / (1.0 + math.exp(-1 * cd1[i]))
    end
    v2:put_chunk(cd2, nil, n1) -- pass buffer to output vector
    cidx = cidx + 1 -- start work on next chunk
  end
  v2:eov() -- no more data
  return v2
end
local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local col1 = Q.mk_col({1, 2, 3, 4}, "I4")
  local nX, X, nn_X = col1:start_write()
  local arg = {map_addr = X, num_elements = 3, qtype = "I4"}
  local virtual_vec = lVector.virtual_new(arg)

  -- set name
  virtual_vec:set_name("vir_vec")
  virtual_vec:check()

  -- set meta
  virtual_vec:set_meta("virtual_vec", true)
  virtual_vec:check()

  print("######## Metadata")
  -- get meta
  local vec_meta = virtual_vec:meta()
  for i, v in pairs(vec_meta.base) do
    print(i, v)
  end
  for i, v in pairs(vec_meta.aux) do
    print(i, v)
  end
  virtual_vec:check()

  -- get num_elements
  print("Num Elements", virtual_vec:num_elements())
  virtual_vec:check()

  -- get chunk_num
  print("Chunk num", virtual_vec:chunk_num())
  virtual_vec:check()

  -- get_all
  local len, base, nn = virtual_vec:get_all()
  base = ffi.cast("int32_t *", get_ptr(base))
  for i = 1, len do
    print(base[i-1])
  end
  virtual_vec:check()

  -- get_one
  for i = 1, virtual_vec:length() do
    print(virtual_vec:get_one(i-1))
  end
  virtual_vec:check()

  -- get_name
  print("Vector name", virtual_vec:get_name())
  virtual_vec:check()

  -- get fldtype
  print("Field type", virtual_vec:qtype())
  print("Field type", virtual_vec:fldtype())
  virtual_vec:check()

  -- get field size
  print("field size", virtual_vec:field_width())
  virtual_vec:check()

  --[[
  -- check is_nascent (not supported at lVector)
  print("is_nascent", virtual_vec:is_nascent())
  virtual_vec:check()
  ]]

  -- check is_eov
  print("is_eov", virtual_vec:is_eov())
  virtual_vec:check()

  --[[
  -- check is_virtual
  print("is_virtual", virtual_vec:is_virtual()
  virtual_vec:check()
  ]]

  -- check is_memo
  print("is_memo", virtual_vec:is_memo())
  virtual_vec:check()

  -- get chunk
  local len, base, nn = virtual_vec:chunk(0)
  base = ffi.cast("int32_t *", get_ptr(base))
  for i = 1, len do
    print(base[i-1])
  end
  virtual_vec:check()

  col1:end_write()
end

tests.t2 = function()
  -- Test virtual vector from virtual vector
end

tests.t3 = function()
  -- Test modification in virtual vector, it should affect parent vector
end

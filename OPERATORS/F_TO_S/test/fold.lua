-- TODO: P1 Need to clean this up and make it a QTILS function
local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
function fold( fns, vec)
local  gens = {}
  for i, v in ipairs(fns) do
    gens[i] = Q[v](vec)
    -- print(type(gens[i]))
  end
  local status = true
  repeat
    for i, v in ipairs(fns) do
      status = gens[i]:next() 
    end
  until not status
  local rvals = {}
  for i, v in ipairs(gens) do
    rvals[i] = gens[i]:value() 
  end
  for i, v in ipairs(rvals) do 
    print(rvals[i])
  end
  return unpack(rvals)
end
x, y, z = fold({ "sum", "min", "max" }, c1)
print (x, y, z)
print("SUCCESS for " .. arg[0])
require 'Q/UTILS/lua/strict'
os.exit()

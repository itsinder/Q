-- put more ecomments in sem.lua explaninign what you just told me  - 

ldnn = {}

ldnn.__index = ldnn

mt = {}

mt.__call = function (cls, ...)
  print(cls)
  print(...)
end

setmetatable(ldnn, mt)

-- explain the code walkthrough when below statement get executed
ldnn("abc")

-- below statement is same as 
-- dnn= {}
-- setmetatabale(dnn, ldnn)

dnn = setmetatable({}, ldnn)

-- below will not work, specify the reason
dnn("hellow world")

http://lua-users.org/wiki/LuaClassesWithMetatable

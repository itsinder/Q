local function extract_goal(
  T, 
  goal
  )
  assert(type(T) == "table")
  assert(type(goal) == "string")
  local t = {}
  local g
  local qtype 
  for k, v in pairs(T) do 
    if ( not qtype ) then
      qtype = v:fldtype()
    else
      assert(qtype == v:fldtype())
      assert((qtype == "F4" ) or ( qtype == "F8"))
    end
    if ( k == goal ) then 
      g = v
    else
      t[#t+1] = v
    end
  end
  return t, g
end
return extract_goal

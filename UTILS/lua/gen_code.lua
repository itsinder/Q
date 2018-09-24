local plpath = require 'pl.path'

local section = { c = 'definition', h = 'declaration' }

local q_tmpl_dir = os.getenv("Q_TMPL_DIR") .. "/"
assert(plpath.isdir(q_tmpl_dir))
local function do_replacements(tmpl, subs)
  local T
  if ( plpath.isfile(tmpl) ) then 
    T = assert(dofile(tmpl))
  else 
    local filename = q_tmpl_dir .. tmpl
    assert(plpath.isfile(filename), "File not found " .. filename)
    T = dofile(filename)
  end
   for k,v in pairs(subs) do
      T[k] = v
   end
   return T
end


local _dotfile = function(subs, tmpl, opdir, ext)
  local T = do_replacements(tmpl, subs)
  local dotfile = T(section[ext])

  if ( ( not opdir ) or ( opdir == "" ) ) then
    return dotfile
  end
  assert(plpath.isdir(opdir), "Unable to find opdir " .. opdir)
  local fname = opdir .. "_" .. subs.fn .. "." .. ext, "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotfile)
  f:close()
  return true
end

local fns = {}

fns.dotc = function (subs, tmpl, opdir)
  return _dotfile(subs, tmpl, opdir, 'c')
end

fns.doth = function (subs, tmpl, opdir)
  return _dotfile(subs, tmpl, opdir, 'h')
end

return fns

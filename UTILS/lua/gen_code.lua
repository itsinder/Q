local plpath = require 'pl.path'

local section = { c = 'selection', h = 'definition' }

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

end

local fns = {}
local function do_replacements(tmpl, subs)
   local T = dofile(tmpl)
   for k,v in pairs(subs) do
      T[k] = v
   end
   return T
end


fns.dotc = function (subs, tmpl, opdir)
  _dotfile(subs, tmpl, opdir, 'c')
end

fns.doth = function (subs, tmpl, opdir)
  _dotfile(subs, tmpl, opdir, 'h')
end

return fns

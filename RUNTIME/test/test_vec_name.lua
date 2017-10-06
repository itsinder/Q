local Vector = require 'libvec' ; 
x = Vector.new('I4')
--=========================
-- Set and get should match
vname = "abc"
x:set_name(vname)
assert(x:get_name() == vname)
--=========================
-- cannot set more than 31 characters in name 
vname = "01234567890123456789012345678901"
status = pcall(x.set_name, vname)
assert(not status)
--=========================
print("Completed ", arg[0])
os.execute("rm -f _*.bin")
os.exit()

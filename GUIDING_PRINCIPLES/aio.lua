local LUA_DEBUG = 0

local switch = {
	h = function()	-- for case 1
		print "Case 1."
    -- nothing to do
	end,
	d = function()	-- for case 2
		print "Case 2."
    local QC_FLAGS = os.getenv("QC_FLAGS")
    print(QC_FLAGS)
    -- TODO: check whether export works 
    os.execute("export QC_FLAGS=\"" .. QC_FLAGS .. " -g\"; echo $QC_FLAGS")
    --os.execute("echo $QC_FLAGS")
    LUA_DEBUG = 1
	end
}

os.execute("echo \"Stating the all in one script\"")
os.execute(". ../setup.sh -f")

print(arg[1])
if arg[1] ~= nil then
  local opt = arg[1]
  local f = switch[opt]
  if(f) then
    f()
  else	-- for case default
    print "Case default."
  end
else
  -- nothing to do
end

-- install_apt_get_dependencies
os.execute("bash apt_get_dependencies.sh install_apt_get_dependencies")

-- #lua_installation.from_apt_get()
if  LUA_DEBUG == 1 then
  os.execute("bash debug_installation.sh install_debug_lua_from_source")
else
  os.execute("bash lua_installation.sh install_lua_from_source")
  os.execute("bash luajit_installation.sh install_luajit_from_source")
end

-- -- # ######## Luarocks #########
-- -- os.execute("which luarocks &> /dev/null")
local ret_val = os.execute("which luarocks")
if ret_val ~= 0 then
  os.execute("bash luarocks_installation.sh install_luarocks_from_source")
  os.execute("bash luarocks_installation.sh install_luarocks_dependencies")
else
  os.execute("echo \"luarocks is already installed\"")
end

-- # ######## Install LAPACK stuff #######
assert(os.execute("sudo apt-get install liblapacke-dev liblapack-dev -y") == 0, "Installation of liblapack failed")

-- #  ######## Build Q #########
os.execute("echo \"Building Q\"")
-- -- TODO
-- -- cleanup ../ #cleaning up all files
os.execute("bash q_build_func.sh clean_q")
if LUA_DEBUG == 1 then 
  os.execute("bash luaffi_installation.sh install_luaffi")
end
os.execute("bash q_build_func.sh build_q")
-- --TODO
-- --run_q_tests

os.execute("echo \"Successfully completed aio.lua in TODO\"")
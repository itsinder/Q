local run_q_tests = require "Q/GUIDING_PRINCIPLES/run_q_tests"
local LUA_DEBUG = 0

-- aio.sh modes can be entered as index
local switch = {
	h = function()	-- for case 1
		-- print "Case 1."
    -- nothing to do
	end,
	d = function()	-- for case 2: debug mode
		-- print "Case 2."
    local QC_FLAGS = os.getenv("QC_FLAGS")
    print(QC_FLAGS)
    -- TODO: check whether export works in same shell instance
    -- HACK: once LUA_DEBUG is used we can set this QC_FLAGS witg -g once called the corresponding .sh
    -- -- os.execute("export QC_FLAGS=\"" .. QC_FLAGS .. " -g\"; echo $QC_FLAGS")
    -- os.execute("echo $QC_FLAGS")
    LUA_DEBUG = 1
	end
}

-- function to check required gcc version
local verify_system_packages = function()
  local status = os.execute("bash system_requirements.sh")
  if status and status ~= 0 then
    -- TODO: Error msg color red
    os.execute("bash aio_utils.sh my_print \"GCC Version Inappropriate\"")
    os.exit()
  else
    return 0
  end
end

-- function to install apt-get dependencies
local install_apt_get_dependencies = function()
  local status = os.execute("bash apt_get_dependencies.sh install_apt_get_dependencies")
  return status
end

-- function to install lua with debug mode(set -g flag)
local install_lua_from_source_debug = function()
  local status = os.execute("bash lua_installation.sh install_lua_from_source LUA_DEBUG")
  return status
end

-- function to install lua from source
local install_lua_from_source = function()
  local status = os.execute("bash lua_installation.sh install_lua_from_source")
  return status
end

-- function to install luajit from source
local install_luajit_from_source = function()
  local status = os.execute("bash luajit_installation.sh install_luajit_from_source")
  return status
end

-- function which captures whoami
local whoami = function()
  local status_1 = os.execute("echo \"`whoami` hard nofile 102400\" | sudo tee --append /etc/security/limits.conf")
  local status_2 = os.execute("echo \"`whoami` soft nofile 102400\" | sudo tee --append /etc/security/limits.conf")
  return status_1 + status_2
end

-- function to install luarocks and dependencies using luarocks
local install_luarocks_and_dependencies = function()
  local status = 0
  local ret_val = os.execute("which luarocks")
  if ret_val ~= 0 then
    local status_1 = os.execute("bash luarocks_installation.sh install_luarocks_from_source")
    local status_2 = os.execute("bash luarocks_installation.sh install_luarocks_dependencies")
    status = status_1 + status_2
  else
    os.execute("bash aio_utils.sh my_print \"luarocks is already installed\"")
  end
  return status
end

-- function to cleanup Q directory ( files --> *.o" )
local cleanup = function()
  local status = os.execute("bash clean_up.sh cleanup ../")
  return status
end

-- UTILS/lua/Makefile make clean
local clean_q = function()
  local status = os.execute("bash q_build_func.sh clean_q")
  return status
end

-- UTILS/lua/Makefile make
local build_q = function()
  local status = os.execute("bash q_build_func.sh build_q")
  return status
end

-- function to install luaffi with debug mode
local install_luaffi = function()
  local status = os.execute("bash luaffi_installation.sh install_luaffi")
  return status
end

---------- Main program starts ----------
--first checking system package version required for Q
assert(verify_system_packages() == 0, "system package checking for gcc failed")

-- setting Q source env variables
-- TODO: absolute path can be supported 
os.execute(". ../setup.sh -f")

-- checking  for aio.lua for -d(debug) mode
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

-- installing apt get dependencies
assert(install_apt_get_dependencies() == 0, "apt-get install installations failed")

if LUA_DEBUG == 1 then
  -- installing lua with debug mode(set -g flag) if debug mode
  assert(install_lua_from_source_debug() == 0, "lua from source with debug flag failed")
else
  -- installing lua and luajit normal mode
  assert(install_lua_from_source() == 0,    "lua from source installation failed")
  assert(install_luajit_from_source() == 0, "luajit from source installation failed")
end

-- TODO: what's this for?
assert(whoami() == 0, "capturing of whoami failed")

-- installing Luarocks
assert(install_luarocks_and_dependencies() == 0, "luarocks and dependencies installation failed")

-- Build Q
os.execute("bash aio_utils.sh my_print \"Building Q\"")
-- cleaning up all files
assert(cleanup() == 0, "cleanup failed")
-- make clean
assert(clean_q() == 0, "make clean failed")
-- installing luaffi in case of debug mode
if LUA_DEBUG == 1 then 
  assert(install_luaffi() == 0, "luaffi installation failed")
end
-- make
os.execute("bash q_build_func.sh build_q")
--execute run_q_tests to check whether Q is properly build
run_q_tests()

os.execute("bash aio_utils.sh my_print \"Successfully completed aio.lua\"")


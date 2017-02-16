DC_TOP		= ../../../dyncall
CC		= gcc
LUA_INCDIR	= ../../../lua-5.3.3/src
LUA_LIBDIR	= ../../../lua-5.3.3/src
CFLAGS	= -fPIC -I$(LUA_INCDIR) -I$(DC_TOP)/include
LIBS = -L$(LUA_LIBDIR) $(LUA_LIBDIR)/liblua.a -L$(DC_TOP)/lib -ldynload_s -ldyncall_s

all: luadc.dll

luadc.dll: luadc.o
	gcc --shared $^ $(LIBS) $(OUTPUT_OPTION)


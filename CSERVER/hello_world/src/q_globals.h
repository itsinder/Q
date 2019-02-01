// Global State that persists across invocations
#include "q_incs.h"
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <pthread.h>

bool g_halt; // For multi-threading
//-----------------------------------------------------------------
char g_err[Q_ERR_MSG_LEN+1]; 
char g_buf[Q_ERR_MSG_LEN+1]; 
char g_rslt[Q_MAX_LEN_RESULT+1]; 

char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1];
char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1];

char g_body[Q_MAX_LEN_BODY+1];
int g_sz_body;

char g_valid_chars_in_url[256]; 

//------------------------ For Lua
lua_State *g_L_Q; 


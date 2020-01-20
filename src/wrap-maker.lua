
--[[
/*-----------------------------------------------------------------------------------------------------------------------|
| MIT License (MIT);                                                                                                     |
| Copyright (C); 2020      by Michel Braz de Morais  <michel.braz.morais@gmail.com>                                      |
|                                                                                                                        |
| Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated           |
| documentation files (the "Software");, to deal in the Software without restriction, including without limitation       |
| the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and       |
| to permit persons to whom the Software is furnished to do so, subject to the following conditions:                     |
|                                                                                                                        |
| The above copyright notice and this permission notice shall be included in all copies or substantial portions of       |
| the Software.                                                                                                          |
|                                                                                                                        |
| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE   |
| WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR  |
| COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       |
| OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.       |
|                                                                                                                        |
|-----------------------------------------------------------------------------------------------------------------------*/

The parser is intended to facilitate the work, but after the 'parse' it might be necessary to check if everything it was okay.

The purpose is to parse an header file and based on functions create interface to be able to call the library from LUA.

The version of LUA tested is 5.2

]]--

tParser = { bEnableDebugToFile = false,  -- bEnableDebugToFile on will force to save parse in file
            iIncrementalNumber              = 1,
            tPrimitiveType                  = {},
            tMethodLuaPopName               = {},
            tMethodLuaPopPointerName        = {},
            tMethodLuaPushName              = {},
            tMethodLuaPushPointerName       = {},
            tPush                           = {},
            tPop                            = {},
            tPushStructClass                = {},
            tPopStructClass                 = {},
            tTypeDef                        = {},
            tTypeDefPopPointer              = {},
            tTypeDefPushPointer             = {},
            tUsedPopArray                   = {},
            tUsedPushArray                  = {},
            tPrimitiveTypePop                = {
                ['void']                = ''                                      ,
                ['bool']                = 'lua_toboolean(lua,index_input++)'      ,
                ['char']                = 'luaL_checkinteger(lua,index_input++)'  ,
                ['long']                = 'luaL_checkinteger(lua,index_input++)'  ,
                ['va_list']             = 'luaL_checkstring(lua,index_input++)'   ,
                ['double']              = 'luaL_checknumber(lua,index_input++)'   ,
                ['float']               = 'luaL_checknumber(lua,index_input++)'   ,
                ['int']                 = 'luaL_checkinteger(lua,index_input++)'  ,
                ['signed']              = 'luaL_checkinteger(lua,index_input++)'  ,
                ['short']               = 'luaL_checkinteger(lua,index_input++)'  ,
                ['unsigned']            = 'luaL_checkunsigned(lua,index_input++)' ,
                ['size_t']              = 'luaL_checkunsigned(lua,index_input++)' ,
                ['ptrdiff_t']           = 'luaL_checkinteger(lua,index_input++)'  ,
            
                ['int8_t']              = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int16_t']             = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int32_t']             = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int64_t']             = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_fast8_t']         = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_fast16_t']        = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_fast32_t']        = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_fast64_t']        = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_least8_t']        = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_least16_t']       = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_least32_t']       = 'luaL_checkinteger(lua,index_input++)'  ,
                ['int_least64_t']       = 'luaL_checkinteger(lua,index_input++)'  ,
                ['intmax_t']            = 'luaL_checkinteger(lua,index_input++)'  ,
                ['intptr_t']            = 'luaL_checkinteger(lua,index_input++)'  ,
                ['uint8_t']             = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint16_t']            = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint32_t']            = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint64_t']            = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_fast8_t']        = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_fast16_t']       = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_fast32_t']       = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_fast64_t']       = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_least8_t']       = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_least16_t']      = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_least32_t']      = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uint_least64_t']      = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uintmax_t']           = 'luaL_checkunsigned(lua,index_input++)' ,
                ['uintptr_t']           = 'luaL_checkunsigned(lua,index_input++)' , },

                tPrimitiveTypePush          = {
                    ['void']                = ''                         ,
                    ['bool']                = 'lua_pushboolean(lua,%s)'  ,
                    ['char']                = 'lua_pushinteger(lua,%s)'   ,
                    ['long']                = 'lua_pushinteger(lua,%s)'   ,
                    ['double']              = 'lua_pushnumber(lua,%s)'   ,
                    ['float']               = 'lua_pushnumber(lua,%s)'   ,
                    ['int']                 = 'lua_pushinteger(lua,%s)'  ,
                    ['short']               = 'lua_pushinteger(lua,%s)'  ,
                    ['signed']              = 'lua_pushinteger(lua,%s)'  ,
                    ['unsigned']            = 'lua_pushunsigned(lua,%s)' ,
                    ['size_t']              = 'lua_pushunsigned(lua,%s)' ,
                    ['ptrdiff_t']           = 'lua_pushinteger(lua,%s)'  ,
                
                    ['int8_t']              = 'lua_pushinteger(lua,%s)'  ,
                    ['int16_t']             = 'lua_pushinteger(lua,%s)'  ,
                    ['int32_t']             = 'lua_pushinteger(lua,%s)'  ,
                    ['int64_t']             = 'lua_pushinteger(lua,%s)'  ,
                    ['int_fast8_t']         = 'lua_pushinteger(lua,%s)'  ,
                    ['int_fast16_t']        = 'lua_pushinteger(lua,%s)'  ,
                    ['int_fast32_t']        = 'lua_pushinteger(lua,%s)'  ,
                    ['int_fast64_t']        = 'lua_pushinteger(lua,%s)'  ,
                    ['int_least8_t']        = 'lua_pushinteger(lua,%s)'  ,
                    ['int_least16_t']       = 'lua_pushinteger(lua,%s)'  ,
                    ['int_least32_t']       = 'lua_pushinteger(lua,%s)'  ,
                    ['int_least64_t']       = 'lua_pushinteger(lua,%s)'  ,
                    ['intmax_t']            = 'lua_pushinteger(lua,%s)'  ,
                    ['intptr_t']            = 'lua_pushinteger(lua,%s)'  ,
                    ['uint8_t']             = 'lua_pushinteger(lua,%s)'  ,
                    ['uint16_t']            = 'lua_pushinteger(lua,%s)'  ,
                    ['uint32_t']            = 'lua_pushinteger(lua,%s)'  ,
                    ['uint64_t']            = 'lua_pushinteger(lua,%s)'  ,
                    ['uint_fast8_t']        = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_fast16_t']       = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_fast32_t']       = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_fast64_t']       = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_least8_t']       = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_least16_t']      = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_least32_t']      = 'lua_pushunsigned(lua,%s)' ,
                    ['uint_least64_t']      = 'lua_pushunsigned(lua,%s)' ,
                    ['uintmax_t']           = 'lua_pushunsigned(lua,%s)' ,
                    ['uintptr_t']           = 'lua_pushunsigned(lua,%s)' ,
                },
                tPrimitiveTypePopPointer = 
                {
                    ['char']                = 'luaL_checkstring(lua,index_input++)',
                },
                
                tPrimitiveTypePushPointer = 
                {
                    ['char']                = 'lua_pushstring(lua,%s)',
                },
            } 

tParser.sAlign     = '    '
tParser.sEndLine   = '\n' .. tParser.sAlign

tParser.tMethodsCreatedAndUsed = {}

tParser.generate_hpp = function(self)
    local sHeader = [[
/*-----------------------------------------------------------------------------------------------------------------------|
| MIT License (MIT);                                                                                                     |
| Copyright (C); YYYY      by Your Name Here  <your.e.mail@provider.com>                                                 |
|                                                                                                                        |
| Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated           |
| documentation files (the "Software");, to deal in the Software without restriction, including without limitation       |
| the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and       |
| to permit persons to whom the Software is furnished to do so, subject to the following conditions:                     |
|                                                                                                                        |
| The above copyright notice and this permission notice shall be included in all copies or substantial portions of       |
| the Software.                                                                                                          |
|                                                                                                                        |
| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE   |
| WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR  |
| COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       |
| OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.       |
|                                                                                                                        |
|-----------------------------------------------------------------------------------------------------------------------*/

#ifndef KEY_UPPER_IMPORTER_H

#define KEY_UPPER_IMPORTER_H

#if defined (__GNUC__) 
  #define KEY_UPPER_IMP_API  __attribute__ ((__visibility__("default")))
#elif defined (WIN32)
    //assuming that we are using the version of LUA 5.2
    #pragma comment(lib, "lua5.2.lib") 
    // To build the DLL on Windows define this KEY_UPPER_IMP_BUILD_DLL, to use the DLL do not define
  #ifdef KEY_UPPER_IMP_BUILD_DLL
    #define KEY_UPPER_IMP_API  __declspec(dllexport)
  #else
    #define KEY_UPPER_IMP_API   __declspec(dllimport)
  #endif
#endif


#ifdef __cplusplus
extern "C" 
{
#endif

    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>

#ifdef __cplusplus
}
#endif

// To make your module reachable from any path export the variable 'LUA_CPATH' 'LD_LIBRARY_PATH' and  like this:
//       export LUA_CPATH="?;?.so;${PATH_TO_BIN}/?.so"
//       export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:path/to/your/lib"
//
// Note that the name of this function is not flexible
extern "C" KEY_UPPER_IMP_API int luaopen_KEY_PROJECTlua (lua_State * lua); // require "KEY_PROJECTlua"
//sometimes it is followed by "lib" -> "libKEY_PROJECTlua, 
extern "C" KEY_UPPER_IMP_API int luaopen_libKEY_PROJECTlua (lua_State *lua);// require "libKEY_PROJECTlua"


#endif // ! KEY_UPPER_IMPORTER_H

]]

    sHeader = sHeader:gsub('YYYY',                   os.date('%Y'))
    sHeader = sHeader:gsub('KEY_PROJECT',            self.sProjectName)
    sHeader = sHeader:gsub('KEY_UPPER',              self.sProjectName:upper())
    sHeader = sHeader:gsub('KEY_LOWER',              self.sProjectName:lower())

    return sHeader
end

tParser.generate_cpp = function(self,sReg_methods_key,tMethods,tMethodsDeclaration,tMethodsBuiltIn)
    local sHeader = [[
/*-----------------------------------------------------------------------------------------------------------------------|
| MIT License (MIT);                                                                                                     |
| Copyright (C); YYYY      by Your Name Here  <your.e.mail@provider.com>                                                 |
|                                                                                                                        |
| Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated           |
| documentation files (the "Software");, to deal in the Software without restriction, including without limitation       |
| the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and       |
| to permit persons to whom the Software is furnished to do so, subject to the following conditions:                     |
|                                                                                                                        |
| The above copyright notice and this permission notice shall be included in all copies or substantial portions of       |
| the Software.                                                                                                          |
|                                                                                                                        |
| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE   |
| WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR  |
| COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       |
| OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.       |
|                                                                                                                        |
|-----------------------------------------------------------------------------------------------------------------------*/

SINCLUDES

#include "KEY_PROJECTlua.h"

#ifdef __cplusplus
extern "C" 
{
#endif

    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>

#ifdef __cplusplus
}
#endif

#include <string>   // std::string
#include <string.h> // memset

class KEY_LUA_UPPER;

KEY_USING

KEY_FREE_CODE

KEY_BUILT_DECLARATION

#ifdef  PLUGIN_CALLBACK
    class KEY_LUA_UPPER : public PLUGIN // class that represent the plugin in the engine
#else
    class KEY_LUA_UPPER
#endif
{
    public:
    KEY_LUA_UPPER()
    {
        v = 0;
    }
    int v; //example some field to this wrapper
};

//this method is able to (securely) obtain the class (user data) of any arguments passed by lua indicating by indexTable. rawi normally is set to 1 (first element in the metatable)
KEY_LUA_UPPER *getKEY_PROJECTFromRawTable(lua_State *lua, const int rawi, const int indexTable)
{
    const int typeObj = lua_type(lua, indexTable);
    if (typeObj != LUA_TTABLE)
    {
        if(typeObj == LUA_TNONE)
            lua_log_error(lua, "expected: [plugin]. got [nil]");
        else
        {
            char message[255] = "";
            snprintf(message,sizeof(message),"expected: [plugin]. got [%s]",lua_typename(lua, typeObj));
            lua_log_error(lua, message);
        }
        return nullptr;
    }
    lua_rawgeti(lua, indexTable, rawi);
    void *p = lua_touserdata(lua, -1);
    if (p != nullptr) 
    {  /* value is a userdata? */
        if (lua_getmetatable(lua, -1))
        {  /* does it have a metatable? */
            lua_rawgeti(lua,-1, 1);
            const int L_USER_PLUGIN  = lua_tointeger(lua,-1);
            lua_pop(lua, 3);
            if(L_USER_PLUGIN == PLUGIN_IDENTIFIER)//Is it really a plugin table?
            {
                KEY_LUA_UPPER **ud = static_cast<KEY_LUA_UPPER **>(p);
                if(ud && *ud)
                    return *ud;
            }
        }
        else
        {
            lua_pop(lua, 2);
        }
    }
    else
    {
        lua_pop(lua, 1);
    }
    return nullptr;
}

KEY_METHODS_BUILT

KEY_POP_ARRAY_METHOD
KEY_PUSH_ARRAY_METHOD

int onDestroyKEY_NO_LUALua(lua_State *lua)
{
    KEY_LUA_UPPER * that = getKEY_PROJECTFromRawTable(lua,1,1);
#if _DEBUG
    static int v = 1;
    printf("destroying KEY_LUA_UPPER %d \n", v++);
#endif
    delete that;
    return 0;
}

void lua_create_metatable_identifier(lua_State *lua,const char* _metatable_plugin,const int value)
{
    luaL_newmetatable(lua, _metatable_plugin);
    lua_pushinteger(lua,value);
    lua_rawseti(lua,-2,1);
}

ALL_METHODS_KEY

int onTestKEY_NO_LUA(lua_State *lua)
{
    const int top = lua_gettop(lua);
    KEY_LUA_UPPER * that = getKEY_PROJECTFromRawTable(lua,1,1); //safely retrieve the plug-in class

    // we are expecting call like this: 
    //       t_dummycalc                    = require "dummycalc" or   -- t_dummycalc = dummycalc.new()
    //       t_dummycalc:onTestdummycalc()          -- pass itself as first arg
    //       t_dummycalc:onTestdummycalc(99) -- pass itself as first arg plus others args
    // it is safe to use the class:

    printf("old value %d\n",that->v);
    that->v                                 = (top > 1 && lua_type(lua,2) == LUA_TNUMBER) ? lua_tonumber(lua,2) : 0;
    printf("new value %d\n",that->v);
    lua_pushinteger(lua,that->v); //return the new value
    return 1;
}

int onNewKEY_NO_LUALua(lua_State *lua)
{
    const int  top = lua_gettop(lua);
    lua_settop(lua, 0);
    luaL_Reg regKEY_NO_LUAMethods[] = {  
REG_METHODS_KEY
        {"test",  onTestKEY_NO_LUA},//this method demonstrates how to get the class of a lua call
        {nullptr, nullptr}};

    luaL_newlib(lua, regKEY_NO_LUAMethods);
    luaL_getmetatable(lua, "_mbmKEY_LUA");
    lua_setmetatable(lua, -2);
    KEY_LUA_UPPER **udata     = static_cast<KEY_LUA_UPPER **>(lua_newuserdata(lua, sizeof(KEY_LUA_UPPER *)));
    KEY_LUA_UPPER * that         = new KEY_LUA_UPPER();
    *udata                    = that;
    
    /* trick to ensure that we will receive a expected metatable type. */
    luaL_getmetatable(lua,"_mbm_plugin");//are we using the module in the mbm engine?
    if(lua_type(lua,-1) == LUA_TTABLE) //Yes
    {
        lua_rawgeti(lua,-1, 1);
        PLUGIN_IDENTIFIER  = lua_tointeger(lua,-1);//update the identifier of plugin.
        lua_pop(lua,1);
    }
    else
    {
        lua_pop(lua, 1);
        lua_create_metatable_identifier(lua,"_mbm_plugin",PLUGIN_IDENTIFIER);//No, we just have to create a metatable to identify the module
    }
    lua_setmetatable(lua,-2);
    /* end trick */

    lua_rawseti(lua, -2, 1);
    return 1;
}

void registerClassKEY_NO_LUA(lua_State *lua)
{
    luaL_Reg regKEY_NO_LUAMethods[] = {{"new", onNewKEY_NO_LUALua}, {"__gc", onDestroyKEY_NO_LUALua}, {nullptr, nullptr}};
    luaL_newmetatable(lua, "_mbmKEY_LUA");
    luaL_setfuncs(lua, regKEY_NO_LUAMethods, 0);
    // this is your table registered on lua. use: t_KEY_NO_LUA = KEY_NO_LUA.new()
    lua_setglobal(lua, "KEY_NO_LUA"); 
    lua_settop(lua,0);
}

//The name of this C function is the string "luaopen_" concatenated with
//   a copy of the module name where each dot is replaced by an underscore.
//Moreover, if the module name has a hyphen, its prefix up to (and including) the
//   first hyphen is removed. For instance, if the module name is a.v1-b.c, the function name will be luaopen_b_c.
//
// To make your module reachable from any path export the variable 'LUA_CPATH' like this:
//       export LUA_CPATH="?;?.so;${PATH_TO_BIN}/?.so\"
// Note that the name of this function is not flexible
int luaopen_KEY_PROJECTlua (lua_State *lua) // require "KEY_PROJECTlua"
{
    registerClassKEY_NO_LUA(lua);
    return onNewKEY_NO_LUALua(lua);
}
//sometimes it is followed by "lib" -> "libKEY_PROJECTlua
int luaopen_libKEY_PROJECTlua (lua_State *lua) // require "libKEY_PROJECTlua"
{
    return luaopen_KEY_PROJECTlua(lua);
}

// also do not forget to adde the lib to the path (linux):
//       export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:path/to/your/lib"

]]

local sKeyFreeCode =
[[
/*
    This class is intended to be used as interface to mbm engine.
    If there is no intent to use this module in the engine there is no problem. It can be used as normal module in lua.
*/

#ifdef  PLUGIN_CALLBACK
    #include <plugin-callback.h>
#endif

static int PLUGIN_IDENTIFIER = -1; //Identifier of table plugin. It is se automatically in the metatable to make sure that we can convert the userdata to ** KEY_LUA_UPPER

KEY_LUA_UPPER *getKEY_PROJECTFromRawTable(lua_State *lua, const int rawi, const int indexTable);

void printStack(lua_State *lua, const char *fileName, const unsigned int numLine)
{
    std::string stack("\n**********************************"
                        "\nState of Stack\n");
    int top = lua_gettop(lua);
    for (int i = 1, k = top; i <= top; i++, --k)
    {
        char str[255];
        int  type = lua_type(lua, i);
        snprintf(str, sizeof(str), "\t%d| %8s |%d\n", -k, lua_typename(lua, type), i);
        stack += str;
    }
    stack += "**********************************\n\n";
    printf("%d:%s,%s", numLine, fileName, stack.c_str());
}

void lua_log_error(lua_State *lua,const char * message)
{
    lua_Debug ar;
	memset(&ar, 0, sizeof(lua_Debug));
	if (lua_getstack(lua, 1, &ar))
	{
		if (lua_getinfo(lua, "nSl", &ar))
		{
            printStack(lua,ar.short_src,ar.currentline);
			luaL_error(lua,"File[%s] line [%d] \n    %s",ar.short_src,ar.currentline,message);
		}
		else
		{
			luaL_error(lua,"File[unknown] line [?] \n    %s",message);
		}
	}
	else
	{
		luaL_error(lua,"File[unknown] line [?] \n    %s",message);
    }
}

void lua_check_is_table(lua_State *lua, const int index,const char * table_name)
{
    if (lua_type(lua,index) != LUA_TTABLE)
    {
        std::string message("Expected table [");
        message.append(table_name ? table_name : "No_name");
        message.append("]");
        lua_log_error(lua,message.c_str());
    }
}

KEY_POP_ARRAY_DECLARATION

KEY_PUSH_ARRAY_DECLARATION

lua_Number get_number_from_field(lua_State* lua,const int index,lua_Number in_out,const char* field_name)
{
    lua_getfield(lua, index, field_name);
    if(lua_type(lua,-1) == LUA_TNUMBER)
        in_out = lua_tonumber(lua,-1);
    lua_pop(lua, 1);
    return in_out;
}

const char * get_string_from_field(lua_State* lua,const int index,const char* field_name)
{
    static std::string out_string;
    out_string.clear();
    lua_getfield(lua, index, field_name);
    if(lua_type(lua,-1) == LUA_TSTRING)
        out_string = lua_tostring(lua,-1);
    lua_pop(lua, 1);
    return out_string.c_str();
}

]]
    
    if #tMethodsDeclaration > 0 then
        sHeader = sHeader:gsub('KEY_BUILT_DECLARATION',      table.concat(tMethodsDeclaration,'\n'))
    else
        sHeader = sHeader:gsub('KEY_BUILT_DECLARATION',          '')
    end
    sHeader = sHeader:gsub('YYYY',                          os.date('%Y'))
    sHeader = sHeader:gsub('KEY_USING',                     table.concat(self.tNamespace,'\n'))
    sHeader = sHeader:gsub('KEY_NO_LUA_UPPER',              self.sProjectName:upper())
    sHeader = sHeader:gsub('KEY_NO_LUA',                    self.sProjectName:lower())
    sHeader = sHeader:gsub('KEY_LUA_UPPER',                 self.sProjectName:upper() .. '_LUA')
    sHeader = sHeader:gsub('KEY_LUA',                       self.sProjectName .. '_LUA')
    sHeader = sHeader:gsub('SINCLUDES',                     (self.sExtraIncludes or '') .. '\n#include "' .. self.sInclude .. '"' )
    sHeader = sHeader:gsub('KEY_LOWER',                     self.sProjectName:lower())
    sHeader = sHeader:gsub('KEY_PROJECT',                   self.sProjectName)
    sHeader = self:self_align(sHeader,'=')

    local sKEY_TYPE_POP =
[[
/* use 'key' in the index -2 and value index -1 */
        lsArrayOut[i] = static_cast<MYTYPE>(lua_tonumber(lua, -1));
        /*remove 'value' and keep 'key' to the next iteration*/
        lua_pop(lua, 1);
]]

    local tPopArrayDeclaration  = 'void pop_MYTYPE_arrayFromTable(lua_State *lua, const int index, MYTYPE *lsArrayOut, const unsigned int sizeBuffer,const char* table_name);'
    local tPushArrayDeclaration = 'void push_MYTYPE_arrayFromTable(lua_State *lua, const MYTYPE *lsArrayIn, const unsigned int sizeBuffer);'

    local tPopArray = 
[[
void pop_MYTYPE_arrayFromTable(lua_State *lua, const int index, MYTYPE *lsArrayOut, const unsigned int sizeBuffer,const char* table_name)
{
    unsigned int i = 0;
    lua_check_is_table(lua,index,table_name);
    lua_pushnil(lua); /* first key */
    while (lua_next(lua, index) != 0)
    {
        KEY_TYPE
        
        i++;
        if (i >= sizeBuffer)
        {
            if (lua_next(lua, index) != 0)
            {
                std::string message("warning table major then expected:[");
                message.append(std::to_string(sizeBuffer));
                message.append("]!");
                lua_log_error(lua,message.c_str());
            }
            break;
        }
    }
}
]]

    local tPushArray = 
[[
void push_MYTYPE_arrayFromTable(lua_State *lua, const MYTYPE * lsArrayIn, const unsigned int sizeBuffer)
{
    lua_newtable(lua);
    for(unsigned int i=0; i < sizeBuffer; ++i )
    {
        KEY_TYPE
        lua_rawseti(lua, -2, i+1);
    }
}
]]

    local bHasPopArray = false
    for k,v in pairs(self.tUsedPopArray) do
        bHasPopArray = true
        break
    end

    if bHasPopArray then
        local tMethodArray = {}
        local tDeclarMethodPopArray = {}
        for k,v in pairs(self.tUsedPopArray) do
            local sDeclarationArray = tPopArrayDeclaration:gsub('MYTYPE',k)
            table.insert(tDeclarMethodPopArray,sDeclarationArray)
            if v then --basic type
                local sBasicType     = sKEY_TYPE_POP:gsub('MYTYPE',k)
                local sMethodArray   = tPopArray:gsub('KEY_TYPE',sBasicType)
                sMethodArray         = sMethodArray:gsub('MYTYPE',k)
                table.insert(tMethodArray,sMethodArray)
            else
                local sPop           = self.tPop[k]
                local sCode          = sPop:gsub('%%s','lsArrayOut[i]'):gsub('index_input%+%+','index') .. ';'
                local sMethodArray   = tPopArray:gsub('KEY_TYPE',sCode)
                sMethodArray         = sMethodArray:gsub('MYTYPE',k)
                table.insert(tMethodArray,sMethodArray)
            end
        end
        sKeyFreeCode = sKeyFreeCode:gsub('KEY_POP_ARRAY_DECLARATION',table.concat(tDeclarMethodPopArray,'\n'))
        sHeader = sHeader:gsub('KEY_POP_ARRAY_METHOD',             table.concat(tMethodArray,'\n'))
        
    else
        sKeyFreeCode = sKeyFreeCode:gsub('KEY_POP_ARRAY_DECLARATION','')
        sHeader = sHeader:gsub('KEY_POP_ARRAY_METHOD','')
    end

    local bHasPushArray = false
    for k,v in pairs(self.tUsedPushArray) do
        bHasPushArray = true
        break
    end

    if bHasPushArray then
        local tMethodArray = {}
        local tDeclarMethodPushArray = {}
        for k,v in pairs(self.tUsedPushArray) do
            local sDeclarationArray = tPushArrayDeclaration:gsub('MYTYPE',k)
            table.insert(tDeclarMethodPushArray,sDeclarationArray)
            if v then --basic type
                local sBasicType     = string.format(self.tPrimitiveTypePush[k],'lsArrayIn[i]') .. ';'
                local sMethodArray   = tPushArray:gsub('KEY_TYPE',sBasicType)
                sMethodArray         = sMethodArray:gsub('MYTYPE',k)
                table.insert(tMethodArray,sMethodArray)
            else
                local sPush          = self.tPushStructClass[k] 
                local sCode          = sPush:gsub('%%s','lsArrayIn[i]'):gsub('index_input%+%+','index') .. ';' --TODO
                local sMethodArray   = tPushArray:gsub('KEY_TYPE',sCode)
                sMethodArray         = sMethodArray:gsub('MYTYPE',k)
                table.insert(tMethodArray,sMethodArray)
            end
        end
        sKeyFreeCode = sKeyFreeCode:gsub('KEY_PUSH_ARRAY_DECLARATION',table.concat(tDeclarMethodPushArray,'\n'))
        sHeader = sHeader:gsub('KEY_PUSH_ARRAY_METHOD',                 table.concat(tMethodArray,'\n'))
        
    else
        sKeyFreeCode = sKeyFreeCode:gsub('KEY_PUSH_ARRAY_DECLARATION','')
        sHeader = sHeader:gsub('KEY_PUSH_ARRAY_METHOD','')
    end
    sKeyFreeCode = sKeyFreeCode:gsub('%%',                 '#@') -- protect the parser
    sKeyFreeCode = sKeyFreeCode:gsub('KEY_LUA_UPPER',       self.sProjectName:upper() .. '_LUA')
    sKeyFreeCode = sKeyFreeCode:gsub('KEY_PROJECT',         self.sProjectName)
    sHeader = sHeader:gsub('KEY_FREE_CODE',                 sKeyFreeCode)
    sHeader = sHeader:gsub('#@', '%%')
    
    sHeader = sHeader:gsub('KEY_METHODS_BUILT',             table.concat(tMethodsBuiltIn,'\n'))
    
    local s,e = sHeader:match('()REG_METHODS_KEY()')
    local sHeader1 = sHeader:sub(1,s-1) .. (sReg_methods_key or '')
    local sHeader2 = sHeader:sub(e)

    sHeader = sHeader1 .. sHeader2

    s,e = sHeader:match('()ALL_METHODS_KEY()')
    sHeader1 = sHeader:sub(1,s-1)
    local sAllMethods = ''
    for i=1, #tMethods do
        sAllMethods = sAllMethods .. tMethods[i].sMethodDefinition
    end
    sHeader1 = sHeader1 .. sAllMethods
    sHeader2 = sHeader:sub(e)

    sHeader = sHeader1 .. sHeader2
    
    return sHeader
end

tParser.release = function(self)
    if self.fpIn then
        self.fpIn:close()
        self.fpIn = nil
    end
    if self.fpOut then
        self.fpOut:close()
        self.fpOut = nil
    end
end

tParser.failed = function(self,msg)
    print('error',msg)
    self:release()
    return false
end


string.split = function(self, inSplitPattern, outResults )
    if not outResults then
        outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end

string.trim = function(self)
    return self:match'^%s*(.*%S)' or '' --trim
 end

tParser.extract_method_name_return_type_and_raw_args = function(self,sLine)
    local sLookFor       = sLine:match('(%g*)%(')
    if sLookFor then
        
        local sMethodName         = sLookFor:trim()
        local pStart              = sLine:match('()' .. sMethodName)--means where the method begin, return a number on left '()'
        local pEnd                = sLine:match(sMethodName .. '()')--means where the method end, return a number on right '()'
        local sReturnType         = sLine:sub(1,pStart-1):trim()
        local sArguments          = sLine:sub(pEnd):trim() -- (size_t* out_ini_size = NULL);               // return a zero-terminate
        local bSemicolon          = sArguments:match('();') --look for the end of signature, left position on ';'
        local sOriginalReturnType = sReturnType
        if bSemicolon == nil then
            print("Failed to parse line:\n\"" .. sLine .. '\"')
            return nil
        end
        local sRawArgs  = sArguments:sub(1,bSemicolon):trim() -- (size_t* out_ini_size = NULL);
        sReturnType     = sReturnType:gsub('static','')
        sReturnType     = sReturnType:gsub('inline','')
        sReturnType     = sReturnType:gsub('const','')
        sReturnType     = sReturnType:gsub('signed','')
        

        sReturnType     = sReturnType:gsub('&','')
        sReturnType     = sReturnType:gsub('%*','')
        
        local sRetType = ''
        for sWord in sReturnType:gmatch('%g+') do
            if self.tPop[sWord] then
                sRetType = sRetType .. ' ' .. sWord
            end
        end
        sReturnType = sRetType:trim() -- typedef unsigned int        ImU32;  // 32-bit unsigned integer (often used to store packed colors)
        if sReturnType:len() == 0 then
            print('error','Not found type of return for line:\n',sLine)
            if sOriginalReturnType:trim():len() > 0 then
                
                if select(2,sLine:gsub('=','')) > 1 then
                    return nil
                end
                sOriginalReturnType = sOriginalReturnType:gsub('%*','')
                print('Using:',sOriginalReturnType)

                sReturnType = sOriginalReturnType

            else
                sReturnType = 'undefined'
            end
        end

        local is_pointer = sLine:find('%*%s*' .. sMethodName)

        return sMethodName, sReturnType, sRawArgs, is_pointer
    end
    
    return nil
end


tParser.extract_arguments_from_raw_args = function(self,sRawArgs) -- expected only args: (size_t* out_ini_size = NULL);
    
    if sRawArgs == nil or sRawArgs:match('%(%s*%)%s*;') then --empty arg
        return {}
    else
        local s,e = sRawArgs:match('%(().*()%)') -- really only args: 'size_t* out_ini_size = NULL'
        if e == nil then
            print('warn','line', 'sRawArgs',sRawArgs)
        end
        sRawArgs = sRawArgs:trim():sub(s,e-1)

        -- Sometimes, some argument are like this: Vec2(0,0), then we eliminate the comma
        local iComma = sRawArgs:match('%(.*(),.*%)')
        while iComma do
            sRawArgs = sRawArgs:sub(1,iComma-1) .. self.sWildCardComma .. sRawArgs:sub(iComma+1)
            iComma = sRawArgs:match('%(.*(),.*%)')
        end

        local tPart = sRawArgs:split(',')
        local tParameters = {}
        --print('sRawArgs',sRawArgs)
        for i = 1, #tPart do
            local sPart = tPart[i]:gsub(self.sWildCardComma,',')
            local tVariable = self:extract_name_from_arg(sPart)
            table.insert(tParameters,tVariable)
        end
        return tParameters --tParameters = {tVariable = {[1] = var_1, [2] = var_2, ...}}
    end
end

tParser.self_align = function(self,tBlock,char)

    local iMaxCountChar = 0
    local tReturn = ''
    local tAllLines = tBlock:split('\n')

    for i=1, #tAllLines do
        local sLine = tAllLines[i]
        local p = sLine:match('%s()' .. char .. '%s')

        if p and p > iMaxCountChar  then
            if not sLine:match('^%s*//') then
                iMaxCountChar = p
            end
        end
    end

    for i=1, #tAllLines do
        local sLine = tAllLines[i]
        local p = sLine:match('%s()' .. char .. '%s')
        if p then
            local t = iMaxCountChar - p + 1
            local sSpace = string.rep(' ',t)
            sLine = sLine:sub(1,p-1) .. sSpace .. sLine:sub(p)
            tReturn = tReturn ..  sLine .. '\n'
        else
            tReturn = tReturn ..  sLine .. '\n'
        end
    end

    return tReturn

end

tParser.get_variables_for_struct_or_class = function(self,key,tStructs_or_classes)
    if self.tIgnore[key] then
        return nil
    end
    for i=1, #tStructs_or_classes do
        local tStructs_or_class = tStructs_or_classes[i]
        if tStructs_or_class.sBlockName == key then
            return tStructs_or_class.tVariables
        end
    end
    return nil
end

tParser.get_variables_for_this_key_in_this_methods = function(self,key,tStructs,tClasses,tEnum)
    if self.tIgnore[key] then
        return nil
    end
    for i=1, #tStructs do
        local tStruct = tStructs[i]
        if tStruct.sBlockName == key then
            return tStruct.tVariables
        end
    end

    for i=1, #tClasses do
        local tClass = tClasses[i]
        if tClass.sBlockName == key then
            return tClass.tVariables
        end
    end

    --for i=1, #tEnum do
    --    local tE = tEnum[i]
    --    if tE.sBlockName == key then
    --        --local tVariables = {}
    --        --print('Found in enum:',key)
    --        --print(#tE)
    --        --for j=1, #tE do
    --        --    print(tE[j])
    --        --end
    --        --for k,v in pairs(tE) do
    --        --    print(k,v)
    --        --end
    --        return { {type = key, tNames = {key}}}
    --    end
    --end

    
    return nil
end

tParser.make_pop_methods = function(self,tNewListPop,tMethodsBuiltIn,tStructs,tClasses,tEnum)

    for k,v in pairs(tNewListPop) do
        --ImVec4 lua_pop_ImVec4(lua_State *lua, const int index);
        local sVarOutName   = string.format('%s_out',k)
        local sMethod       = string.format('%s %s(lua_State *lua,const int index)\n{\n%s%s %s;%s',k,v,self.sAlign,k,sVarOutName,self.sEndLine)
        sMethod             = sMethod .. string.format('lua_check_is_table(lua, index, "%s");%s',k,self.sEndLine)
        local tVariables    = self:get_variables_for_this_key_in_this_methods(k,tStructs,tClasses,tEnum)
        if tVariables and self.tMethodLuaPopName[k] then
            for i=1, #tVariables do
                local tVariable = tVariables[i]
                local sPop = self.tPop[tVariable.sType]
                if sPop then
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        if tVariable.iSizeOfArray then
                            local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'pop')
                            sMethod = sMethod .. string.format('pop_%s_arrayFromTable(lua,index,%s->%s ,sizeof(%s->%s) / sizeof(%s),"%s");//TODO: 1 check if the type is right%s',sTypeOfArray,sVarOutName,sVarName,sVarOutName,sVarName,sTypeOfArray,sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('#error "0 - (make_pop_methods) do not know what to do! it was NOT supposed be here: %s%s"%s',tVariable.sType,sVarName,self.sEndLine)
                        else
                            local sPopFromLast      = sPop:gsub('index_input%+%+','-1')
                            sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('%s.%s = %s;%s',sVarOutName,sVarName,sPopFromLast,self.sEndLine)
                            sMethod = sMethod .. 'lua_pop(lua, 1);' .. self.sEndLine
                        end
                    end
                elseif self.tTypeDefPopPointer[tVariable.sType] then
                    sPop = self.tTypeDefPopPointer[tVariable.sType]
                    local def = self.tTypeDef[tVariable.sType]
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        local sNameStaticVar = self:generate_name(tVariable.sType)
                        if self.tPrimitiveTypePopPointer[tVariable.sType] then --special for char
                            local sPopFromLast   = sPop:gsub('index_input%+%+','-1')
                            sMethod = sMethod .. string.format('static std::string %s;//TODO: 2 check here, apparently, "%s.%s" is a pointer%s',sNameStaticVar,k,sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('%s = %s;%s',sNameStaticVar,sPopFromLast,self.sEndLine)
                            sMethod = sMethod .. string.format('%s.%s = const_cast<char*>(%s.data());%s',sVarOutName,sVarName,sNameStaticVar,self.sEndLine)
                            sMethod = sMethod .. 'lua_pop(lua, 1);' .. self.sEndLine
                        else
                            local sPopFromTop   = sPop:gsub('index_input%+%+','lua_gettop(lua)')
                            sPopFromTop         = string.format(sPopFromTop,'&' .. sNameStaticVar)
                            sMethod = sMethod .. string.format('static %s %s;//TODO: 3 check here, apparently, "%s.%s" is a pointer%s',def,sNameStaticVar,k,sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('%s.%s = %s;%s',sVarOutName,sVarName,sPopFromTop,self.sEndLine)
                            sMethod = sMethod .. 'lua_pop(lua, 1);' .. self.sEndLine
                        end
                    end
                else
                    sMethod = sMethod .. string.format('#error "1 - (make_pop_methods) Not found %s, do not know what to do for variables: ',tVariable.sType)
                    for j=1, #tVariable.tNames do
                        sMethod = sMethod .. tVariable.tNames[j] .. ', '
                    end
                    sMethod = sMethod .. '"' .. self.sEndLine
                end
            end
        end
        sMethod = sMethod .. string.format('\n    return %s;\n}\n',sVarOutName)
        sMethod = self:self_align(sMethod,'=')
        table.insert(tMethodsBuiltIn,sMethod)
    end
end

tParser.make_push_methods  = function(self,tNewListPush,tMethodsBuiltIn,tStructs,tClasses,tEnum,tMethodsCreatedOut)
    for k,v in pairs(tNewListPush) do
        local sMethod       = string.format('void %s(lua_State *lua, const %s & in)\n{\n%s',v,k,self.sAlign)
        local tVariables    = self:get_variables_for_this_key_in_this_methods(k,tStructs,tClasses,tEnum)
        if tVariables and self.tMethodLuaPushName[k] then
            sMethod         = sMethod .. 'lua_newtable(lua);' .. self.sEndLine
            for i=1, #tVariables do
                local tVariable = tVariables[i]
                local sPush     = self.tPush[tVariable.sType]
                if sPush then
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        if self:is_primitive_type(tVariable.sType) then
                            if tVariable.isPointer then
                                if tVariable.sType == 'char' then --special for char
                                    sMethod = sMethod .. string.format('lua_pushstring(lua,in.' ..sVarName) .. ');' .. self.sEndLine
                                else
                                    sMethod = sMethod .. string.format('const %s %s = in.%s != nullptr ? (*in.%s) : 0;//TODO: 4 check here, apparently, "%s.%s" is a pointer%s',tVariable.sType,sVarName,sVarName,sVarName,k,sVarName,self.sEndLine)
                                    sMethod = sMethod .. string.format(sPush,sVarName) .. ';' .. self.sEndLine
                                end
                            elseif tVariable.iSizeOfArray then
                                local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'push')
                                sMethod = sMethod .. string.format('push_%s_arrayFromTable(lua,in.%s ,sizeof(in.%s) / sizeof(%s));//TODO: 5 check if the type is right%s',sTypeOfArray,sVarName,sVarName,sTypeOfArray,self.sEndLine)
                            else
                                sMethod = sMethod .. string.format(sPush,'in.' ..sVarName) .. ';' .. self.sEndLine
                            end
                        elseif tVariable.isPointer then
                            local sPush_pointer = sPush:gsub('%(.*$','_pointer')
                            tMethodsCreatedOut[tVariable.sType] = sPush_pointer
                            sPush_pointer       = string.format('%s(lua, in.%s);//TODO: 6 check here, apparently, "%s.%s" is a pointer and might be nullptr %s',sPush_pointer,sVarName,k,sVarName,self.sEndLine)
                            sMethod             = sMethod .. sPush_pointer
                        elseif tVariable.iSizeOfArray then
                            local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'push')
                            sMethod = sMethod .. string.format('push_%s_arrayFromTable(lua,in.%s ,sizeof(in.%s) / sizeof(%s));//TODO: 7 check if the type is right%s',sTypeOfArray,sVarName,sVarName,sTypeOfArray,self.sEndLine)
                        elseif sPush then
                            sMethod = sMethod .. string.format(sPush,'in.' ..sVarName) .. ';' .. self.sEndLine
                        else
                            sMethod = sMethod .. string.format('#error "2 - (make_push_methods) Not found %s.%s, do not know what to do!"\n%s',k,sVarName,self.sAlign)
                        end
                        sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");', sVarName) .. self.sEndLine
                    end
                elseif self.tTypeDefPushPointer[tVariable.sType] then --pointer to typedef
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        sPush = self.tTypeDefPushPointer[tVariable.sType]
                        local sPushCall = string.format(sPush,string.format('*in.%s',sVarName)) .. ';'
                        if self.tPrimitiveTypePushPointer[tVariable.sType] then --special for char
                            sPushCall = sPushCall:gsub('%*','')
                        end
                        sMethod = sMethod .. string.format('if(in.%s)%s{%s%s',sVarName,self.sEndLine,self.sEndLine,self.sAlign)
                        sMethod = sMethod .. string.format('%s%s%s',sPushCall,self.sEndLine,self.sAlign,self.sAlign)
                        sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s}%s',sVarName,self.sEndLine,self.sEndLine)
                    end
                else
                    sMethod = sMethod .. string.format('#error "3 - (make_push_methods) Not found %s, do not know what to do!"\n',k) 
                end
            end
        else
            sMethod = sMethod .. string.format('#error "4 - (make_push_methods) Not found %s, do not know what to do!"\n',k)
        end
        sMethod = sMethod .. '\n}\n'
        sMethod = self:self_align(sMethod,'=')
        table.insert(tMethodsBuiltIn,sMethod)
    end
end

tParser.make_push_for_struct_methods  = function(self,tNewListPushStructClass,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)
    for k,v in pairs(tNewListPushStructClass) do
        local sVarInName    = string.format('p_in_%s',k)
        local sMethod       = string.format('void %s(lua_State *lua, const %s * %s)\n{%s',v,k,sVarInName,self.sEndLine)
        sMethod             = sMethod .. string.format('if (%s == nullptr)%s{\n%s%s',sVarInName,self.sEndLine,self.sAlign,self.sAlign)
        sMethod             = sMethod .. string.format('lua_log_error(lua,"%s can not be null");%s}\n%s',k,self.sEndLine,self.sAlign)
        sMethod             = sMethod .. string.format('else%s{\n%s%slua_newtable(lua);%s',self.sEndLine,self.sAlign,self.sAlign,self.sEndLine)
        local tVariables    = self:get_variables_for_this_key_in_this_methods(k,tStructs,tClasses,tEnum)
        if tVariables and self.tMethodLuaPushPointerName[k] then
            for i=1, #tVariables do -- {sPush = 'push', tNames = {[1]= 'y', [2] = 'x'}, tPop = 'pop', type = 'char', const = 5, }
                local tVariable     = tVariables[i]
                local sPush         = self.tPush[tVariable.sType] 
                local sDefaultValue = nil
                if tVariable.sDefaultValue then
                    sDefaultValue   = tostring(tVariable.sDefaultValue)
                end
                if sPush then
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        if tVariable.isPointer and tVariable.sType == 'char' then --special case for char string
                            local sPushCall = string.format('lua_pushstring(lua, %s->%s);' ,sVarInName,sVarName)
                            sMethod = sMethod .. string.format('%sif(%s->%s)%s%s{%s%s%s',self.sAlign,sVarInName,sVarName,self.sEndLine,self.sAlign,self.sEndLine,self.sAlign,self.sAlign)
                            sMethod = sMethod .. string.format('%s%s%s%s',sPushCall,self.sEndLine,self.sAlign,self.sAlign,self.sAlign)
                            sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s%s}%s',sVarName,self.sEndLine,self.sAlign,self.sEndLine)
                        elseif tVariable.isPointer then
                            local sPushCall = string.format(sPush,string.format('*%s->%s',sVarInName,sVarName)) .. ';'
                            sMethod = sMethod .. string.format('%sif(%s->%s)%s%s{%s%s%s',self.sAlign,sVarInName,sVarName,self.sEndLine,self.sAlign,self.sEndLine,self.sAlign,self.sAlign)
                            sMethod = sMethod .. string.format('%s%s%s%s',sPushCall,self.sEndLine,self.sAlign,self.sAlign,self.sAlign)
                            sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s%s}%s',sVarName,self.sEndLine,self.sAlign,self.sEndLine)
                        elseif tVariable.iSizeOfArray then
                            local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'push')
                            sMethod = sMethod .. string.format('%spush_%s_arrayFromTable(lua,%s->%s ,sizeof(%s->%s) / sizeof(%s));//TODO: 8 check if the type is right%s%s',self.sAlign,sTypeOfArray,sVarInName,sVarName,sVarInName,sVarName,sTypeOfArray,self.sEndLine,self.sAlign)
                            sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s',sVarName,self.sEndLine)
                        else
                            local sPushCall = string.format(sPush,string.format('%s->%s',sVarInName,sVarName))
                            sMethod = sMethod .. string.format('%s%s;%s%s',self.sAlign,sPushCall,self.sEndLine,self.sAlign)
                            sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s',sVarName,self.sEndLine)
                        end
                    end
                elseif self.tTypeDefPushPointer[tVariable.sType] then --pointer to typedef
                    for j=1, #tVariable.tNames do
                        
                        local sVarName = tVariable.tNames[j]
                        sPush = self.tTypeDefPushPointer[tVariable.sType]
                        local sPushCall = string.format(sPush,string.format('*%s->%s',sVarInName,sVarName)) .. ';'
                        if self.tPrimitiveTypePushPointer[tVariable.sType] then --special for char
                            sPushCall = sPushCall:gsub('%*','')
                        end
                        sMethod = sMethod .. string.format('%sif(%s->%s)%s%s{%s%s%s',self.sAlign,sVarInName,sVarName,self.sEndLine,self.sAlign,self.sEndLine,self.sAlign,self.sAlign)
                        sMethod = sMethod .. string.format('%s%s%s%s',sPushCall,self.sEndLine,self.sAlign,self.sAlign,self.sAlign)
                        sMethod = sMethod .. string.format('lua_setfield(lua, -2, "%s");%s%s}%s',sVarName,self.sEndLine,self.sAlign,self.sEndLine)
                    end
                else
                    sMethod = sMethod .. '\n' .. string.format('%s%s #error "5 - Not found %s->%s, do not know what to do for the variables: ',self.sAlign,self.sAlign,k,tVariable.sType)
                    for j=1, #tVariable.tNames do
                        sMethod = sMethod .. tVariable.tNames[j] .. ', '
                    end
                    sMethod = sMethod .. '"' .. self.sEndLine
                end
            end
            sMethod = sMethod .. string.format('\n%s}\n}\n',self.sAlign)
            sMethod = self:self_align(sMethod,'=')
            table.insert(tMethodsBuiltIn,sMethod)
        end
    end
end

tParser.make_pop_for_struct_methods  = function(self,tNewListPopStructClass,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)
    for k,v in pairs(tNewListPopStructClass) do
        local sVarOutName    = string.format('in_out_%s',k)
        local sMethod       = string.format('%s * %s(lua_State *lua, const int index, %s * %s)\n{%s',k,v,k,sVarOutName,self.sEndLine)
        sMethod             = sMethod .. string.format('if (%s == nullptr)%s{\n%s%s',sVarOutName,self.sEndLine,self.sAlign,self.sAlign)
        sMethod             = sMethod .. string.format('lua_log_error(lua,"%s can not be null");%s%sreturn nullptr;\n%s}\n%s',k,self.sEndLine,self.sAlign,self.sAlign,self.sAlign)
        sMethod             = sMethod .. string.format('lua_check_is_table(lua, index, "%s");%s',k,self.sEndLine)
        local tVariables    = self:get_variables_for_this_key_in_this_methods(k,tStructs,tClasses,tEnum)
        if tVariables and self.tMethodLuaPopPointerName[k] then
            for i=1, #tVariables do -- {sPush = 'push', tNames = {[1]= 'y', [2] = 'x'}, tPop = 'pop', type = 'char', const = 5, }
                local tVariable     = tVariables[i]
                local sPop          = self.tPop[tVariable.sType] 
                local sDefaultValue = nil
                if tVariable.sDefaultValue then
                    sDefaultValue   = tostring(tVariable.sDefaultValue)
                end
                if self:is_primitive_type(tVariable.sType) then
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        if tVariable.isPointer then
                            local sNameStaticVar = self:generate_name(tVariable.sType)
                            if tVariable.sType == 'char' then --special for char
                                sMethod = sMethod .. string.format('%s->%s = get_string_from_field(lua, index, "%s");%s',sVarOutName,sVarName,sVarName,self.sEndLine)
                            else
                                sMethod = sMethod .. string.format('static %s %s = 0;//TODO: 9 check here, apparently, "%s->%s" is a pointer%s',tVariable.sType,sNameStaticVar,k,sVarName,self.sEndLine)
                                sMethod = sMethod .. string.format('%s->%s = &%s;%s',sVarOutName,sVarName,sNameStaticVar,self.sEndLine)
                                sMethod = sMethod .. string.format('%s = static_cast<%s>(get_number_from_field(lua,index,static_cast<lua_Number>(%s),"%s"));%s',sNameStaticVar,tVariable.sType,sNameStaticVar,sVarName,self.sEndLine)
                            end
                        elseif tVariable.iSizeOfArray then
                            local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'pop')
                            sMethod = sMethod .. string.format('pop_%s_arrayFromTable(lua,index,%s->%s ,sizeof(%s->%s) / sizeof(%s),"%s");//TODO: 10 check if the type is right%s',sTypeOfArray,sVarOutName,sVarName,sVarOutName,sVarName,sTypeOfArray,sVarName,self.sEndLine)
                        else
                            if sDefaultValue then
                                sMethod = sMethod .. string.format('%s->%s = static_cast<%s>(get_number_from_field(lua,index,static_cast<lua_Number>(%s),"%s"));%s',sVarOutName,sVarName,tVariable.sType,sDefaultValue,sVarName,self.sEndLine)
                            else
                                sMethod = sMethod .. string.format('%s->%s = static_cast<%s>(get_number_from_field(lua,index,static_cast<lua_Number>(%s->%s),"%s"));%s',sVarOutName,sVarName,tVariable.sType,sVarOutName,sVarName,sVarName,self.sEndLine)
                            end
                        end
                    end
                elseif sPop then
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        if tVariable.isPointer then
                            if tVariable.sType == 'char' then
                                sMethod = sMethod .. string.format('%s->%s = get_string_from_field(lua, index, "%s");%s',sVarOutName,sVarName,sVarName,self.sEndLine)
                            else
                                local sNameStaticVar    = self:generate_name(tVariable.sType)
                                local sPopPointerStruct = self.tMethodLuaPopPointerName[k]
                                local sPopPointerStatic = string.format('%s(lua, index, &%s)',sPopPointerStruct,sNameStaticVar)
                                sMethod = sMethod .. string.format('static %s %s;//TODO: 11 check here, apparently, "%s->%s" is a pointer%s',tVariable.sType,sNameStaticVar,k,sVarName,self.sEndLine)
                                sMethod = sMethod .. string.format('%s->%s = %s;%s',sVarOutName,sVarName,sPopPointerStatic,self.sEndLine)
                                sNeededMethod = sPopPointerStatic:sub(1,sPopPointerStatic:find('%(')-1):trim()
                                tMethodsCreatedOut[tVariable.sType] = sNeededMethod
                                tMethodsCreatedOutDeclaration[tVariable.sType] = string.format('%s * %s(lua_State *lua, const int index, %s * in_out_%s);',tVariable.sType,sNeededMethod,tVariable.sType,tVariable.sType )
                            end
                        elseif tVariable.iSizeOfArray then
                            local sTypeOfArray = self:get_best_type_of_pop_push_arrayFromTable(tVariable.sType,'pop')
                            sMethod = sMethod .. string.format('pop_%s_arrayFromTable(lua,index,%s->%s ,sizeof(%s->%s) / sizeof(%s),"%s");//TODO: 12 check if the type is right%s',sTypeOfArray,sVarOutName,sVarName,sVarOutName,sVarName,sTypeOfArray,sVarName,self.sEndLine)
                        else
                            local sPopStruct     = self.tPop[tVariable.sType]:gsub('index_input%+%+','index')
                            sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('%s->%s = %s;%s',sVarOutName,sVarName,sPopStruct,self.sEndLine)
                        end
                    end
                elseif self.tTypeDefPopPointer[tVariable.sType] then
                    sPop = self.tTypeDefPopPointer[tVariable.sType]
                    local def = self.tTypeDef[tVariable.sType]
                    for j=1, #tVariable.tNames do
                        local sVarName = tVariable.tNames[j]
                        local sNameStaticVar = self:generate_name(tVariable.sType)
                        local sPopFromLast   = sPop:gsub('index_input%+%+','-1')
                        if self.tPrimitiveTypePopPointer[tVariable.sType] then --special for char
                            sMethod = sMethod .. string.format('static std::string %s;//TODO: 13 check here, apparently, "%s->%s" is a pointer%s',sNameStaticVar,k,sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            sMethod = sMethod .. string.format('%s = %s;%s',sNameStaticVar,sPopFromLast,self.sEndLine)
                            sMethod = sMethod .. 'lua_pop(lua, 1);' .. self.sEndLine
                        else
                            --sMethod = sMethod .. string.format('static %s %s;//TODO: 14 check here, apparently, "%s->%s" is a pointer%s',def,sNameStaticVar,k,sVarName,self.sEndLine)
                            --sMethod = sMethod .. string.format('lua_getfield(lua, index, "%s");%s',sVarName,self.sEndLine)
                            --sMethod = sMethod .. string.format('%s->%s = &%s;%s',sVarOutName,sVarName,sNameStaticVar,self.sEndLine)
                            --sMethod = sMethod .. string.format('%s = %s;%s',sNameStaticVar,sPopFromLast,self.sEndLine)
                            sMethod = sMethod .. 'lua_pop(lua, 1);' .. self.sEndLine
                        end
                    end
                else
                    sMethod = sMethod .. '\n' .. string.format('%s #error "6 - Not found %s->%s, do not know what to do for the variables: ',self.sAlign,k,tVariable.sType)
                    for j=1, #tVariable.tNames do
                        sMethod = sMethod .. tVariable.tNames[j] .. ', '
                    end
                    sMethod = sMethod .. '"' .. self.sEndLine
                end
            end
        end
        sMethod = sMethod .. string.format('\n    return %s;\n}\n',sVarOutName)
        sMethod = self:self_align(sMethod,'=')
        table.insert(tMethodsBuiltIn,sMethod)
    end
end

tParser.make_methods_needed = function(self,tStructs,tClasses,tEnum)
    --remove methods not used
    local tNewListPush              = {}
    local tNewListPop               = {}
    local tNewListPopStructClass    = {}
    local tNewListPushStructClass   = {}

    for k,v in pairs(self.tMethodLuaPushName) do
        if self.tMethodsCreatedAndUsed[v] then
            tNewListPush[k] = v
        end
    end

    for k,v in pairs(self.tMethodLuaPopName) do
        if self.tMethodsCreatedAndUsed[v] then
            tNewListPop[k] = v
        end
    end

    for k,v in pairs(self.tMethodLuaPopPointerName) do
        if self.tMethodsCreatedAndUsed[v] then
            tNewListPopStructClass[k] = v
        end
    end

    for k,v in pairs(self.tMethodLuaPushPointerName) do
        if self.tMethodsCreatedAndUsed[v] then
            tNewListPushStructClass[k] = v
        end
    end

    for i=1, #tStructs do
        local tStruct = tStructs[i]
        for j=1, #tStruct.tVariables do
            --[[
                print(tStruct.sBlockName) -- ImFontAtlasCustomRect
                print(i, tStruct[j]) -- example of output for j=24
                24	struct ImFontAtlasCustomRect
                24	{
                24	    unsigned int    ID;
                24	    unsigned short  Width, Height;
                24	    unsigned short  X, Y;
                24	    float           GlyphAdvanceX;
            ]] --
            
            local tVariable = tStruct.tVariables[j]
            if self.tMethodLuaPushName[tVariable.sType] and tNewListPush[tVariable.sType] == nil then
                tNewListPush[tVariable.sType] = self.tMethodLuaPushName[tVariable.sType]
            end

            if self.tMethodLuaPopName[tVariable.sType] and tNewListPop[tVariable.sType] == nil then
                tNewListPop[tVariable.sType]  = self.tMethodLuaPopName[tVariable.sType]
            end

            if self.tMethodLuaPopPointerName[tVariable.sType] and tNewListPop[tVariable.sType] == nil then
                tNewListPopStructClass[tVariable.sType]  = self.tMethodLuaPopPointerName[tVariable.sType]
            end

            if self.tMethodLuaPushPointerName[tVariable.sType] and tNewListPush[tVariable.sType] == nil then
                tNewListPushStructClass[tVariable.sType]  = self.tMethodLuaPushPointerName[tVariable.sType]
            end

            
        end
    end

    for i=1, #tClasses do
        local tClass = tClasses[i]
        for j=1, #tClass.tVariables do
            local tVariable = tClass.tVariables[j]
            if self.tMethodLuaPushName[tVariable.sType] and tNewListPush[tVariable.sType] == nil then
                tNewListPush[tVariable.sType] = self.tMethodLuaPushName[tVariable.sType]
            end

            if self.tMethodLuaPopName[tVariable.sType] and tNewListPop[tVariable.sType] == nil then
                tNewListPop[tVariable.sType]  = self.tMethodLuaPopName[tVariable.sType]
            end
        end
    end

    --now, make them

    local tMethodsBuiltIn = {}

    local tMethodsCreatedOut = {}
    self:make_push_methods(tNewListPush,tMethodsBuiltIn,tStructs,tClasses,tEnum,tMethodsCreatedOut)
    self:make_pop_methods(tNewListPop,tMethodsBuiltIn,tStructs,tClasses,tEnum)

    local tMethodsCreatedOutDeclaration = {}
    self:make_pop_for_struct_methods(tNewListPopStructClass,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)
    self:make_push_for_struct_methods(tNewListPushStructClass,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)

    --check if inside struct/class would be missing
    local tMissingMethods = {}
    for k,v in pairs(tMethodsCreatedOut) do
        if not self.tMethodsCreatedAndUsed[k] then
            tMissingMethods[k] = v
        end
    end
    self:make_pop_for_struct_methods(tMissingMethods,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)
    self:make_push_for_struct_methods(tMissingMethods,tMethodsBuiltIn,tMethodsCreatedOut,tMethodsCreatedOutDeclaration,tStructs,tClasses,tEnum)
    --end treatment missing struct/class

    
    --replace them
    self.tMethodLuaPushName         = tNewListPush
    self.tMethodLuaPopName          = tNewListPop
    self.tMethodLuaPopPointerName   = tNewListPopStructClass
    self.tMethodLuaPushPointerName  = tNewListPushStructClass

    local tMethodsDeclaration = {}
    for k,v in pairs(self.tMethodLuaPushName) do
        table.insert(tMethodsDeclaration,string.format('void %s(lua_State *lua, const %s & in);',v,k))
    end
    for k,v in pairs(self.tMethodLuaPopName) do
        table.insert(tMethodsDeclaration,string.format('%s %s(lua_State *lua, const int index);',k,v))
    end
    for k,v in pairs(self.tMethodLuaPopPointerName) do
        table.insert(tMethodsDeclaration,string.format('%s * %s(lua_State *lua, const int index,%s * p_%s);',k,v,k,k))
    end
    for k,v in pairs(self.tMethodLuaPushPointerName) do
        table.insert(tMethodsDeclaration,string.format('void %s(lua_State *lua,const %s * p_%s);',v,k,k))
    end

    local function compare( a, b )
        return a:upper() < b:upper()
    end

    for k,v in pairs(tMissingMethods) do
        if tMethodsCreatedOutDeclaration[k] == nil then
            print('You forgot to add tMissingMethods to tMethodsCreatedOutDeclaration',k,v)
        else
            table.insert(tMethodsDeclaration,tMethodsCreatedOutDeclaration[k])
        end
    end

    if #tMethodsDeclaration > 0 then

        table.sort( tMethodsDeclaration, compare )
        local n = 1
        for i = 1, #tMethodsDeclaration do
            if tMethodsDeclaration[n] == tMethodsDeclaration[n + 1] then
                table.remove(tMethodsDeclaration, n)
                n = n - 1
            end
            n = n + 1
        end
    end
    return tMethodsDeclaration, tMethodsBuiltIn
end



tParser.generate_reg_methods = function(self,tMethods)

    local function reg_method(tMethod,iMaxLen)
        local sMethodName       = tMethod.sMethodName
        local method_name_upper = sMethodName:sub(1,1):upper() .. sMethodName:sub(2)
        local method_name_lower = sMethodName:sub(1,1):lower() .. sMethodName:sub(2)
        local str = string.format('{\"%s\",|%s },',method_name_lower,tMethod.method_name_lua)
        if str:len() < iMaxLen then
            local t = iMaxLen - str:len()
            local sSpace = string.rep(' ',t)
            str = str:gsub('|',sSpace)
        else
            str = str:gsub('|',' ')
        end
        return str
    end
    
    local iMaxLen = 0
    for i = 1, #tMethods do
        local tMethod = tMethods[i]
        
        local sReg = reg_method(tMethod,0)
        if sReg:len() > iMaxLen then
            iMaxLen = sReg:len()
        end
    end

    iMaxLen = iMaxLen +1

    local tAllRegFunction = {}

    local tRet = {}
    
    for i = 1, #tMethods do
        local tMethod    = tMethods[i]
        local sReg       = reg_method(tMethod,iMaxLen)
        if not tAllRegFunction[sReg] then
            tAllRegFunction[sReg] = true
            table.insert(tRet,'        ' .. sReg)
        end
    end
    table.sort(tRet)
    return table.concat(tRet,'\n')
end
 
function deep_copy_table(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy_table(orig_key)] = deep_copy_table(orig_value)
        end
        setmetatable(copy, deep_copy_table(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

tParser.sWildCardComma = '#'
tParser.set_wild_card_comma = function(self,sWildCardComma)
    self.sWildCardComma = sWildCardComma
end

tParser.tIgnore = {}
tParser.add_ignore = function(self,sIgnoreStruct)
    self.tIgnore[sIgnoreStruct] = true
end

tParser.sProjectName = nil
tParser.set_project_name = function(self,sProjectName)
    self.sProjectName = sProjectName
end

tParser.sExtraIncludes = ''
tParser.set_extra_includes = function(self,sExtraIncludes)
    self.sExtraIncludes = sExtraIncludes
end


tParser.get_best_type_of_pop_push_arrayFromTable = function(self,sType,sMode)
    local tTypes = {
        ['void']                = 'int'   ,
        ['bool']                = 'int'   ,
        ['char']                = 'char'  ,
        ['short']               = 'short' ,
        ['int']                 = 'int'   ,
        ['long']                = 'long'  ,
        ['unsigned char']       = 'unsigned_char'  ,
        ['unsigned short']      = 'unsigned_short' ,
        ['unsigned int']        = 'unsigned_int'   ,
        ['unsigned long']       = 'unsigned_long'  ,
        ['float']               = 'float' ,
        ['double']              = 'double',
    }
    local sTypeTemp         = sType:trim()
    local bIsBasicType  = false
    if tTypes[sTypeTemp] then
        bIsBasicType = true
    else
        bIsBasicType = false
    end
    if sMode == 'pop' then
        self.tUsedPopArray[sTypeTemp] = bIsBasicType
    else
        self.tUsedPushArray[sTypeTemp] = bIsBasicType
    end
    local sMyType      = (tTypes[sTypeTemp] or sTypeTemp)
    return sMyType
end


tParser.is_primitive_type = function(self,what_type)
    return self.tPrimitiveType[what_type]
end


tParser.initial_setup = function(self)
    
    if self.sProjectName == nil then
        return self:failed("Project name can not be nil!")
    end

    --set our known type 
    for k,v in pairs(self.tPrimitiveTypePush) do
        if self.tPush[k] == nil then
            self.tPush[k] = v
        end
        self.tPrimitiveType[k] = v
    end

    for k,v in pairs(self.tPrimitiveTypePop) do
        if self.tPop[k] == nil then
            self.tPop[k] = v
        end
        self.tPrimitiveType[k] = v
    end

    for k,v in pairs(self.tPrimitiveTypePopPointer) do
        if self.tPopStructClass[k] == nil then
            self.tPopStructClass[k] = v
        end
    end

    for k,v in pairs(self.tPrimitiveTypePushPointer) do
        if self.tPushStructClass[k] == nil then
            self.tPushStructClass[k] = v
        end
    end

    if self.sRetrieveInstance == nil then
        self.sRetrieveInstance = 'KEY_LUA_UPPER * KEY_NO_LUA = getKEY_NO_LUAFromRawTable(lua, 1, 1);'
        self.sRetrieveInstance = self.sRetrieveInstance:gsub('KEY_NO_LUA', self.sProjectName)
        self.sRetrieveInstance = self.sRetrieveInstance:gsub('KEY_LUA_UPPER', self.sProjectName:upper() .. '_LUA')
    end
   
    return true
end

tParser.parse = function(self,sFilenameIn)
    
    if type(sFilenameIn) ~= 'string' then
        print('error','expected sFilenameIn as string')
        return false
    end

    if self:initial_setup() == false then
        return false
    end

    local sFile     = sFilenameIn:gsub('\\','/')
    local tFileName = sFile:split('/')
    if #tFileName > 0 then
        self.sInclude = tFileName[#tFileName]
    end

    print('Parsing:',sFilenameIn)
    local tBlockOutNoComment = {}
    
    local sFileNameOutNoComments = sFilenameIn .. '.no_coment.h'
    if self:remove_cpp_comment(sFilenameIn,sFileNameOutNoComments,true,tBlockOutNoComment) == false then
        return self:failed("Failed to remove comment CPP from file:" .. sFilenameIn)
    end

    self.sFileNameOutNoComments = sFileNameOutNoComments
    if self.bEnableDebugToFile then
        print('Successfully parsed:')
        print(sFileNameOutNoComments)
    end

    local tTypedefs = {}
    local file_name_out_typedef = sFilenameIn .. '.typedef.h'
    if self:extract_typedef(sFileNameOutNoComments,file_name_out_typedef,tTypedefs,tBlockOutNoComment) == false then
        return self:failed("Failed to extract typedef from from file:" .. sFileNameOutNoComments)
    end

    local tForward = {}
    local file_name_out_forward = sFilenameIn .. '.forward.h'
    if self:extract_forward_declaration(sFileNameOutNoComments,file_name_out_forward,tForward,tBlockOutNoComment) == false then
        return self:failed("Failed to extract typedef from from file:" .. sFileNameOutNoComments)
    end

    local tEnum = {}
    local file_name_out_enum = sFilenameIn .. '.enum.h'
    if self:extract_block('enum',file_name_out_enum,tEnum,tBlockOutNoComment) == false then
        return self:failed("Failed to extract enum from from file:" .. sFileNameOutNoComments)
    end
    
    local tStructs = {}
    local sFileNameOutStruct = sFilenameIn .. '.struct.h'
    if self:extract_block('struct',sFileNameOutStruct,tStructs,tBlockOutNoComment) == false then
        return self:failed("Failed to extract struct from from file:" .. sFileNameOutNoComments)
    end
    if self.bEnableDebugToFile then
        print('Successfully parsed:')
        print(sFileNameOutStruct)
    end

    if self:extract_variables_from_blocks(tStructs) == false then
        return self:failed("Failed to extract variables...")
    end

    local tClasses = {}
    local sFileNameOutClass = sFilenameIn .. '.class.h'
    if self:extract_block('class',sFileNameOutClass,tClasses,tBlockOutNoComment) == false then
        return self:failed("Failed to extract classes from from file:" .. sFileNameOutNoComments)
    end
    if self.bEnableDebugToFile then
        print('Successfully parsed:')
        print(sFileNameOutClass)
    end

    if self:extract_variables_from_blocks(tClasses) == false then
        return self:failed("Failed to extract variables...")
    end
    print('Extracted variables successfully...')
    

    local sFileNameOutMethods = sFilenameIn .. '.methods.h'
    local tMethods = {}
    if self:extract_methods(sFileNameOutMethods,tMethods,tBlockOutNoComment) == false then
        return self:failed("Failed to extract methods from from file:" .. sFileNameOutNoComments)
    end
    if self.bEnableDebugToFile then
        print('Successfully extracted methods to:')
        print(sFileNameOutMethods)
    end

    local function getCommentFromOriginalLine(sOriginalLine)
        if sOriginalLine then
            sOriginalLine = sOriginalLine:trim()
            if sOriginalLine:len() > 0 then
                local s,e = sOriginalLine:match('/%*().*()%*/')
                if s and e then
                    local sComment = sOriginalLine:sub(s,s+1):upper() .. sOriginalLine:sub(s+2,e-1):trim()
                    return true, sComment
                end
                s = sOriginalLine:match('//()')
                if s then
                    local sComment = sOriginalLine:sub(s,s+1):upper() .. sOriginalLine:sub(s+2):trim()
                    return true, sComment
                end
            end
        end

        return false, ''
    end

    local tStructClassEnumNeeded = {}
    local tDocument = {}
    local tDocumentCommonMethods = {} -- must be {_3letters = 'setXXX', sRst = 'XXX'}
    
    table.insert(tDocument,'.. contents:: Table of Contents\n')
    local sHeaderRST = 'Module ' .. self.sProjectName .. '\n'
    sHeaderRST = sHeaderRST .. string.rep('=',sHeaderRST:len()) .. '\n\n'
    sHeaderRST = sHeaderRST .. 'This page of document was generated automatically based on code of **' ..self.sProjectName .. '** and might need some adjusts.\n\n'
    table.insert(tDocument,sHeaderRST)

    
    for i =1 , #tMethods do
        local tMethod    = tMethods[i]
        if tMethod.sMethodName and tMethod.sReturnType and tMethod.tParameters then
            local method_name_upper   = tMethod.sMethodName:sub(1,1):upper() .. tMethod.sMethodName:sub(2)
            local method_name_lower   = tMethod.sMethodName:sub(1,1):lower() .. tMethod.sMethodName:sub(2)
            tMethod.method_name_lua   = string.format('on%s%sLua',method_name_upper,(self.sProjectName or ''))
            tMethod.sLuaSignature     = string.format('int %s(lua_State *lua)',tMethod.method_name_lua)
            --start of method

            local sDocument = string.format('%s\n%s\n\n',method_name_lower:trim(),string.rep('^',method_name_lower:trim():len()))

            if #tMethod.tParameters > 0 then
                sDocument = sDocument .. '\n\n.. data:: ' .. method_name_lower .. '('
                for j=1, #tMethod.tParameters do
                    local tVariable = tMethod.tParameters[j]
                    tVariable.sName  = tVariable.sName or self:generate_name(tVariable.sType)
                    if (j+1) <= #tMethod.tParameters then
                        sDocument = sDocument .. tVariable.sName .. ', '
                    else
                        sDocument = sDocument .. tVariable.sName .. ')\n\n'
                    end
                end
            else
                sDocument = sDocument .. '\n\n.. data:: ' .. method_name_lower .. '()\n\n'
            end
            
            
            local bCommentFromLine , sComment  = getCommentFromOriginalLine(tMethod.sOriginalLine)
            if bCommentFromLine then
                sDocument = sDocument .. sComment:gsub('::',':'):gsub('%*',' * ') .. '\n'
                tMethod.sMethodDefinition = tMethod.sLuaSignature .. '\n{\n' .. self.sAlign .. '// ' .. sComment .. '\n' .. self.sAlign ..  'int index_input = 1;' .. self.sEndLine
            else
                tMethod.sMethodDefinition = tMethod.sLuaSignature .. '\n{\n' .. self.sAlign .. 'int index_input = 1;' .. self.sEndLine
            end
            local sInstanceLuaExampleName = string.format('t%s',self.sProjectName)
            sDocument = sDocument .. '\n*Example:*\n\n.. code-block:: lua\n\n' 
            local sDocumentCallMethod = sInstanceLuaExampleName .. '.' .. method_name_lower .. '('
            local sVarDocument = self.sAlign .. sInstanceLuaExampleName .. ' = ' .. ' require "' .. self.sProjectName .. '"\n'

            
            --check if it has default parameter and do the docs
            local bHasDefaultParameter = false
            for j=1, #tMethod.tParameters do
                local tVariable = tMethod.tParameters[j]
                if tVariable.sDefaultValue then
                    bHasDefaultParameter = true
                    local sDefaultValue = tVariable.sDefaultValue:gsub('NULL','nil')
                    sDefaultValue       = sDefaultValue:gsub('nullptr','nil')
                    local sVarName = tVariable.sName
                    sVarDocument = sVarDocument .. self.sAlign .. 'local ' .. sVarName .. ' = ' .. sDefaultValue .. '\n'
                    sDocumentCallMethod = sDocumentCallMethod .. sVarName
                    if (j + 1) > #tMethod.tParameters then
                        sDocumentCallMethod = sDocumentCallMethod .. ')'
                    else
                        sDocumentCallMethod =  sDocumentCallMethod .. ', '
                    end
                else
                    local sDefaultValue = 'nil'
                    if self:is_primitive_type(tVariable.type) then
                        if tVariable.isPointer and tVariable.type == 'char' then
                            sDefaultValue = 'Hello'
                        elseif tVariable.type == 'bool' then
                            sDefaultValue = 'true'
                        else
                            sDefaultValue = '0'
                        end
                    else
                        sDefaultValue = '{}'
                    end
                    local sVarName = tVariable.sName or self:generate_name(tVariable.sType)
                    sVarDocument = sVarDocument .. self.sAlign .. 'local ' .. sVarName .. ' = ' .. sDefaultValue .. '\n'
                    sDocumentCallMethod = sDocumentCallMethod .. sVarName
                    if (j + 1) > #tMethod.tParameters then
                        sDocumentCallMethod = sDocumentCallMethod .. ')'
                    else
                        sDocumentCallMethod =  sDocumentCallMethod .. ', '
                    end
                end
            end
            if #tMethod.tParameters == 0 then
                sDocumentCallMethod = sDocumentCallMethod .. ')'
            end

            sDocument = sDocument .. self:self_align(sVarDocument,'=') ..self.sAlign .. sDocumentCallMethod
            
            table.insert(tDocumentCommonMethods,{_3letters = method_name_lower:sub(1,3), method_name_lower = method_name_lower , sRst = sDocument .. '\n'})
            
            if bHasDefaultParameter then
                tMethod.sMethodDefinition = tMethod.sMethodDefinition .. 'const int top = lua_gettop(lua);' .. self.sEndLine
            end

            --lua get args (tPop)
            for j=1, #tMethod.tParameters do
                --tVariable.name, tVariable.type, tVariable.isPointer, tVariable.sDefaultValue, tVariable.tPush = self.tPush[sWord], tVariable.tPop = self.tPop[sWord]
                local tVariable      = tMethod.tParameters[j]
                local sGetValue = ''
                if tVariable.sType then
                    local sPop           = self.tPop[tVariable.sType]
                    if self:is_primitive_type(tVariable.sType) then
                        if tVariable.isPointer then
                            if tVariable.sType == 'char' then --special case, skip for char because is a string, ok, const char * p_new_c  = top >= index_input ? lua_tostring(lua,index_input++) :  "HELLO" ;
                                if tVariable.sDefaultValue then
                                    sGetValue = sGetValue .. string.format('const char * p_%s = top >= index_input ? lua_tostring(lua,index_input++) : %s;',tVariable.sName, tVariable.sDefaultValue)
                                else
                                    sGetValue = sGetValue .. string.format('const char * p_%s = luaL_checkstring(lua,index_input++);',tVariable.sName)
                                end
                            else
                                --[[
                                static int var_int_2  = 0;
                                int * p_new_i         =  NULL;
                                if(top >= index_input)
                                {
                                    var_int_2         = luaL_checkinteger(lua,index_input++);
                                    p_new_i           = &var_int_2;
                                }
                                SetInt(p_new_i);
                                ]]
                                local sNameStaticVar = self:generate_name(tVariable.sType)
                                sGetValue = sGetValue .. string.format('static %s %s = 0;%s',tVariable.sType,sNameStaticVar,self.sEndLine)
                                if tVariable.sDefaultValue then
                                    sGetValue = sGetValue .. string.format('%s * p_%s = %s;%s',tVariable.sType,tVariable.sName,tVariable.sDefaultValue,self.sEndLine)
                                else
                                    sGetValue = sGetValue .. string.format('%s * p_%s = nullptr;%s',tVariable.sType,tVariable.sName,self.sEndLine)
                                end
                                sGetValue = sGetValue .. 'if(top >= index_input)' .. self.sEndLine .. '{' .. self.sEndLine
                                sGetValue = sGetValue .. string.format('%s%s = %s;%s',   self.sAlign, sNameStaticVar,sPop,self.sEndLine)
                                sGetValue = sGetValue .. string.format('%sp_%s = &%s;%s}',self.sAlign, tVariable.sName,sNameStaticVar,self.sEndLine)
                            end
                        elseif tVariable.iSizeOfArray then
                            sGetValue = sGetValue .. string.format('#error "7 - %s * %s = %s;"',tVariable.sType,pointer_var_name, tVariable.tPop)
                        else--  const long var_long_1  = luaL_checkinteger(lua,index_input++);
                            if tVariable.sDefaultValue then
                                sGetValue = sGetValue .. string.format('const %s %s = top >= index_input ? %s : %s;',tVariable.sType,tVariable.sName, sPop, tVariable.sDefaultValue)
                            else
                                sGetValue = sGetValue .. string.format('const %s %s = %s;',tVariable.sType,tVariable.sName, sPop)
                            end
                        end
                    else --struct
                        sGetValue           = string.format('%s %s;%s',tVariable.sType,tVariable.sName,self.sEndLine) -- declaration of variable to use in the pop
                        local sPop_pointer  = sPop:gsub('%(.*$','_pointer')
                        sPop_pointer        = string.format('%s(lua, index_input++, &%s)',sPop_pointer,tVariable.sName)
                        if tVariable.sDefaultValue then
                            sGetValue = sGetValue .. string.format('%s * p_%s = top >= index_input ? %s : %s;',tVariable.sType,tVariable.sName, sPop_pointer, tVariable.sDefaultValue)
                        else
                            sGetValue = sGetValue .. string.format('%s * p_%s = %s;',tVariable.sType,tVariable.sName, sPop_pointer)
                        end
                    end
                    if self.tPopStructClass[tVariable.sType] then
                        local sPopPointer = self.tPopStructClass[tVariable.sType]:match('(%g+)%(')
                        if sPopPointer then
                            self.tMethodsCreatedAndUsed[sPopPointer] = true -- lua_pop_ImDrawList_pointer
                        end
                        tStructClassEnumNeeded[tVariable.sType] = {bNeed = true,bChecked = false}
                    end
                else
                    sGetValue = string.format('#error "8 - do not know what to do for this: type:%s variable:%s = %s"',tVariable.sType,tVariable.sName, tVariable.tPop)
                end
                tMethod.sMethodDefinition = tMethod.sMethodDefinition .. sGetValue .. self.sEndLine
            end

            --lua set args (tPush), call the native function
            local sReturnVariableName = string.format('ret_%s',tMethod.sReturnType)
            if #tMethod.tParameters > 0 then
                local sCallWrapper = ''
                if tMethod.sReturnType:find('void') then
                    sCallWrapper = string.format('%s(',tMethod.sMethodName)
                else
                    sCallWrapper = string.format('const %s %s = %s(',tMethod.sReturnType,sReturnVariableName,tMethod.sMethodName)
                end

                for j=1, #tMethod.tParameters do
                    local tVariable      = tMethod.tParameters[j]
                    if tVariable.isPointer then
                        sCallWrapper    = sCallWrapper .. 'p_' .. tostring(tVariable.sName or 'nullptr')
                    else
                        sCallWrapper    = sCallWrapper .. tostring(tVariable.sName or 'nullptr')
                    end
                    if j + 1 > #tMethod.tParameters then
                        sCallWrapper = sCallWrapper .. ');'
                    else
                        sCallWrapper = sCallWrapper .. ','
                    end

                    if self.tPushStructClass[tVariable.sType] then
                        local sPushPointer = self.tPushStructClass[tVariable.sType]:match('(%g+)%(')
                        if sPushPointer then
                            self.tMethodsCreatedAndUsed[sPushPointer] = true -- lua_push_ImDrawList_pointer
                        end
                        tStructClassEnumNeeded[tVariable.sType] = {bNeed = true,bChecked = false}
                    end
                end
                
                tMethod.sMethodDefinition = tMethod.sMethodDefinition .. sCallWrapper .. self.sEndLine
            else
                local sCallWrapper = ''
                if tMethod.sReturnType:find('void') then
                    sCallWrapper = string.format('%s();',tMethod.sMethodName)
                else
                    sCallWrapper = string.format('const %s %s = %s();',tMethod.sReturnType,sReturnVariableName,tMethod.sMethodName)
                end
                tMethod.sMethodDefinition = tMethod.sMethodDefinition .. sCallWrapper .. self.sEndLine
            end

            --return type
            if tMethod.sReturnType:find('void') then
                tMethod.sMethodDefinition = tMethod.sMethodDefinition .. 'return 0;\n}' .. self.sEndLine
            else
                if self.tPush[tMethod.sReturnType] then
                    self.tMethodsCreatedAndUsed[self.tPush[tMethod.sReturnType]:match('(%g+)%(')] = true -- lua_push_ImDrawList
                    local sMethodPush = self.tPush[tMethod.sReturnType]
                    sMethodPush = string.format(sMethodPush,sReturnVariableName) .. ';'
                    tMethod.sMethodDefinition = tMethod.sMethodDefinition .. sMethodPush .. self.sEndLine
                    tMethod.sMethodDefinition = tMethod.sMethodDefinition .. 'return 1;\n}' .. self.sEndLine
                else
                    tMethod.sMethodDefinition = tMethod.sMethodDefinition .. '//return type not found' .. self.sEndLine
                    tMethod.sMethodDefinition = tMethod.sMethodDefinition .. 'return 0;\n}' .. self.sEndLine
                end
            end

            --alignment
            tMethod.sMethodDefinition = self:self_align(tMethod.sMethodDefinition,'=')
        else
            print('error','skiped method number ' .. tostring(i), tostring(tMethod.sLine))
        end

    end

    for k,v in pairs (tStructClassEnumNeeded) do
        if self:is_primitive_type(k) then
            tStructClassEnumNeeded[k] = {bNeed = false,bChecked = true}
        end
    end

    self:search_for_dependencies(tStructClassEnumNeeded,tStructs,tClasses,tEnum)
    for k,v in pairs (tStructClassEnumNeeded) do
        if not self:is_primitive_type(k) then
            
        end
    end

    local function compare_letters( a, b )
        return a._3letters:upper() < b._3letters:upper()
    end
 
    table.sort( tDocumentCommonMethods, compare_letters )

    sHeaderRST = self.sProjectName .. ' general methods\n'
    sHeaderRST = sHeaderRST .. string.rep('-',sHeaderRST:len()) .. '\n\n'
    local tGeneralMethods = {}
    local tSpecificMethods = {}
    table.insert(tGeneralMethods,sHeaderRST)

    local function get_longest_name(tCompareName)
        local iMinLen = 9999999999
        for i=0, #tCompareName do
            iMinLen = math.min(iMinLen,tCompareName[i]:len())
        end

        for i=0, #tCompareName do
            local sWord = tCompareName[i]
            
        end
    end
    
    local sLast3letters = ''
    local tPreviouslly = {}
    for i=1, #tDocumentCommonMethods do
        local tCompareName = {}
        local tCurrent = tDocumentCommonMethods[i]
        if tCurrent.iCount == nil then
            table.insert(tCompareName,tCurrent.method_name_lower)
            tCurrent.iCount = 1
            local sCurrent3Ltters = tCurrent._3letters
            for j=i+1, #tDocumentCommonMethods do
                local tNext = tDocumentCommonMethods[j]
                local sNextLtters = tNext._3letters
                if sNextLtters == sCurrent3Ltters then
                    tCurrent.iCount = tCurrent.iCount + 1
                    table.insert(tCompareName,tNext.method_name_lower)
                    for k=i+1, j do
                        local tInner = tDocumentCommonMethods[i]
                        tInner.iCount = tCurrent.iCount
                    end
                else
                    break
                end
            end
        end
    end
    for i=1, #tDocumentCommonMethods do
        local tCurrent = tDocumentCommonMethods[i]
        local sCurrent3Ltters = tCurrent._3letters
        if sCurrent3Ltters ~= sLast3letters then
            sLast3letters = sCurrent3Ltters
            if #tSpecificMethods > 0 then
                table.insert(tDocument,table.concat(tSpecificMethods,'\n'))
                tSpecificMethods = {}
            end
            if tCurrent.iCount > 1 then
                local sXXX = sLast3letters .. ' methods'
                sXXX = string.format('\n\n%s\n%s\n\n',sXXX,string.rep('-',sXXX:len()))
                table.insert(tSpecificMethods,sXXX)
                table.insert(tSpecificMethods,tDocumentCommonMethods[i].sRst)
            else
                table.insert(tGeneralMethods,tDocumentCommonMethods[i].sRst)
            end
        else
            table.insert(tSpecificMethods,tDocumentCommonMethods[i].sRst)
        end
    end

    if #tSpecificMethods > 0 then
        table.insert(tDocument,table.concat(tSpecificMethods,'\n'))
        tSpecificMethods = {}
    end

    table.insert(tDocument,table.concat(tGeneralMethods,'\n'))

    local tMethodsDeclaration,tMethodsBuiltIn   = self:make_methods_needed(tStructs,tClasses,tEnum)
    local sReg_methods_key                      = self:generate_reg_methods(tMethods)
    local sCpp                                  = self:generate_cpp(sReg_methods_key,tMethods,tMethodsDeclaration,tMethodsBuiltIn)
    local sHpp                                  = self:generate_hpp()
    return true, sHpp, sCpp, table.concat(tDocument,'\n\n')
end

--need to look what struct/ class are inside to mark them as needed (recursively )
tParser.search_for_dependencies = function(self,tStructClassEnumNeeded,tStructs,tClasses,tEnum)
    for k, v in pairs(tStructs) do
        local sBlockName = v.sBlockName
        local tBlockCheck = tStructClassEnumNeeded[sBlockName]
        if tBlockCheck and tBlockCheck.bNeed == true and tBlockCheck.bChecked == false then
            tBlockCheck.bChecked = true
            local tChildrenVariables    = self:get_variables_for_struct_or_class(sBlockName,tStructs)
            if tChildrenVariables then
                for i=1, #tChildrenVariables do
                    local tVariable = tChildrenVariables[i]
                    if not self:is_primitive_type(tVariable.sType) then
                        if tStructClassEnumNeeded[tVariable.sType] == nil then
                            tStructClassEnumNeeded[tVariable.sType] = {bNeed = true, bChecked = false}
                        end
                        tStructClassEnumNeeded[tVariable.sType].bNeed    = true
                        local sPopPointer = self.tPopStructClass[tVariable.sType]
                        if sPopPointer then
                            sPopPointer = sPopPointer:match('(%g+)%(')
                            self.tMethodsCreatedAndUsed[sPopPointer] = true -- lua_pop_ImDrawList_pointer
                        end
                        local sPushPointer = self.tPushStructClass[tVariable.sType]
                        if sPushPointer then
                            sPushPointer = sPushPointer:match('(%g+)%(')
                            self.tMethodsCreatedAndUsed[sPushPointer] = true -- lua_push_ImDrawList_pointer
                        end
                        self:search_for_dependencies(tStructClassEnumNeeded,tStructs,tClasses,tEnum)
                    end
                end
            end
        end
    end
    for k, v in pairs(tClasses) do
        local sBlockName = v.sBlockName
        local tBlockCheck = tStructClassEnumNeeded[sBlockName]
        if tBlockCheck and tBlockCheck.bNeed == true and tBlockCheck.bChecked == false then
            tBlockCheck.bChecked = true
            local tChildrenVariables    = self:get_variables_for_struct_or_class(sBlockName,tClasses)
            if tChildrenVariables then
                for i=1, #tChildrenVariables do
                    local tVariable = tChildrenVariables[i]
                    if not self:is_primitive_type(tVariable.sType) then
                        if tStructClassEnumNeeded[tVariable.sType] == nil then
                            tStructClassEnumNeeded[tVariable.sType] = {bNeed = true, bChecked = false}
                        end
                        tStructClassEnumNeeded[tVariable.sType].bNeed    = true
                        local sPopPointer = self.tPopStructClass[tVariable.sType]:match('(%g+)%(')
                        if sPopPointer then
                            self.tMethodsCreatedAndUsed[sPopPointer] = true -- lua_pop_ImDrawList_pointer
                        end
                        local sPushPointer = self.tPushStructClass[tVariable.sType]:match('(%g+)%(')
                        if sPushPointer then
                            self.tMethodsCreatedAndUsed[sPushPointer] = true -- lua_push_ImDrawList_pointer
                        end
                        self:search_for_dependencies(tStructClassEnumNeeded,tStructs,tClasses,tEnum)
                    end
                end
            end
        end
    end
end

tParser.print_block = function(self,tBlockOut)
    for i=1, #tBlockOut do
        tBlock = tBlockOut[i]
        for j =1, #tBlock do
            print(i,tBlock[j])
        end
    end
end

tParser.generate_name = function(self,sType)
    local sName = string.format('var_%s_%d',sType,self.iIncrementalNumber)
    self.iIncrementalNumber = self.iIncrementalNumber + 1
    return sName
end

--type of args expected, example: void SetInt(int new_i);
--arg: 'int new_i'
--type of args expected, example: void SetFloat(float new_x = 1.5f,char c = 'A');
--arg: 'float new_x = 1.5f'
--arg: 'char c = 'A''
tParser.extract_name_from_arg = function(self,arg)
    
    local tVariable = {isPointer = false}
    for sWord in arg:gmatch('%g+') do
        local sWordTemp, isPointer = sWord:gsub('%*','')
        sWordTemp = sWordTemp:gsub('&','')
        if self.tPush[sWordTemp] then
            tVariable.sType              = sWordTemp
            tVariable.tPush              = self.tPush[sWordTemp]
            tVariable.tPop               = self.tPop[sWordTemp]
        end
        if isPointer == 1 then
            tVariable.isPointer = true
        end
    end
    local sDefaultValue = arg:match('=(.*)')
    if sDefaultValue then
        tVariable.sDefaultValue = sDefaultValue
    end
    if tVariable.sType then
        local iSizeOfArray  = 0
        local sWord         = arg:gsub('%*','')
        sWord               = sWord:gsub('&','')
        sWord               = sWord:gsub('=.*$','')
        sWord,iSizeOfArray  = sWord:gsub('%[%d*%]','')
        if tonumber(iSizeOfArray) == 1 then
            tVariable.isPointer = true
            tVariable.iSizeOfArray = tonumber(iSizeOfArray)
        end
        local sName = sWord:match(tVariable.sType .. '%s+(%g+)%s*$' )
        if sName then
            tVariable.sName = sName
        else
            tVariable.sName = self:generate_name(tVariable.sType)
        end
    end
    return tVariable
end

tParser.extract_properties_from_block = function (self,sLine)
    
    local tBasicMath = {
        '^%s*const%s*unsigned%s+(%g+)',
        '^%s*unsigned%s*const%s+(%g+)',
        '^%s*unsigned%s+(%g+)',
        '^%s*const%s*signed%s+(%g+)',
        '^%s*signed%s+(%g+)',
        '^%s*signed%s*const%s+(%g+)',
        '^%s*const%s+(%g+)',
        '^%s*struct%s+(%g+)',
        '^%s*class%s+(%g+)',
        '^%s*mutable%s+(%g+)',
        '^%s*(%g+)' -- look at is_not_g
    }

    local function is_not_g(sLine)
        return sLine:gsub('{',''):gsub('%]',''):gsub('%[',''):gsub('}',''):gsub(';',''):trim():len() > 0
    end

    for i = 1, #tBasicMath do
        local sMath = tBasicMath[i]
        local s     = sLine:match(sMath)--float b; float Framerate; MouseClickedTime[5]; const char* BackendRendererName;
        if s and sLine:find(';') and not sLine:match('%(.*%)') and is_not_g(sLine) then
            --print(sLine) -- float X0, Y0, X1, Y1;    ImVec2 GlyphExtraSpacing;   bool FontDataOwnedByAtlas;
            local tVariables = {const    = sMath:find('const'), 
                    unsigned    = sMath:find('unsigned'),
                    tNames      = {}, --float X0, Y0, X1, Y1;
                    sType       = s:trim():gsub('%*',''):gsub('&',''),
                    }
            tVariables.isPointer = sLine:find(tVariables.sType .. '%s*%*')
            if tVariables.isPointer then 
                tVariables.isPointer = true
            end
            local iDefaultValue = 0
            local sTempVar          = sLine:gsub('%*',''):gsub(';',''):gsub('&','')
            sTempVar                = sTempVar:gsub(tVariables.sType .. '%s+' ,' ')-- TODO: variable like this: nothing_float becomes nothing_
            sTempVar, iDefaultValue = sTempVar:gsub('=.*$','')
            sTempVar                = sTempVar:gsub('unsigned','')
            sTempVar                = sTempVar:gsub('const ','')
            sTempVar                = sTempVar:gsub('signed ',''):trim()

            if sLine:match('%[%d+%]') then
                tVariables.iSizeOfArray = tonumber(sLine:match('%[(%d+)%]'))
            end

            if iDefaultValue > 0 then
                local sDefault = sLine:gsub('%*',''):gsub(';',''):gsub('&',''):gsub('^.*=',''):trim()
                tVariables.sDefault = sDefault
            end
            local tVars = sTempVar:split(',')
            for j=1, #tVars do
                local sTempVar = tVars[j]:trim()
                if not sTempVar:find('<.*>') then
                    if tVariables.iSizeOfArray then
                        sTempVar = sTempVar:gsub('%[%d+%]','')
                    end
                    table.insert(tVariables.tNames,sTempVar)
                --else TODO
                --    print('Parser is not prepared for template,',sTempVar)
                end
            end
            return tVariables
        end
    end

    return nil
end


tParser.extract_name_from_block = function(self,sBlock,tBlockOIn)-- expected a block like enum XXX {YYY}, struct XXX {YYY} or class XXX {YYY}
    
    for i = 1, #tBlockOIn do
        local tBlock = tBlockOIn[i]
        for j = 1, #tBlock do
            local sLine = tBlock[j]
            if sLine:match(sBlock) then
                local bFakeBlock  = sLine:find('%g' .. sBlock) or sLine:find(sBlock.. '%g')
                if not bFakeBlock then
                    local e = sLine:match(sBlock .. '()')
                    sLine = sLine:sub(e)
                    tBlock.sBlockName = sLine:match('(%g+)')
                    if tBlock.sBlockName then
                        break
                    end
                end
            end
            tBlock.sBlockName = sLine:match('(%g+)')
            if tBlock.sBlockName then
                break
            end
        end
    end
    for i = 1, #tBlockOIn do
        local tBlock = tBlockOIn[i]
        
        if tBlock.sBlockName and not self.tIgnore[tBlock.sBlockName] and tBlock.sBlockName:trim() ~= 'const' then
            if self.tPush[tBlock.sBlockName] == nil then
                self.tPush[tBlock.sBlockName] = string.format('lua_push_%s(lua,%%s)',tBlock.sBlockName)
            end

            if self.tPop[tBlock.sBlockName] == nil  then
                self.tPop[tBlock.sBlockName] = string.format('lua_pop_%s(lua,index_input++)',tBlock.sBlockName)
            end

            if self.tPopStructClass[tBlock.sBlockName] == nil then
                if self.tPrimitiveTypePop[tBlock.sBlockName] then
                    self.tPopStructClass[tBlock.sBlockName] = self.tPrimitiveTypePop[tBlock.sBlockName]
                else
                    self.tPopStructClass[tBlock.sBlockName] = string.format('lua_pop_%s_pointer(lua,index_input++,&%%s)',tBlock.sBlockName)
                end
            end

            if self.tPushStructClass[tBlock.sBlockName] == nil then
                if self.tPrimitiveTypePush[tBlock.sBlockName] then
                    self.tPushStructClass[tBlock.sBlockName] = self.tPrimitiveTypePush[tBlock.sBlockName]
                else
                    self.tPushStructClass[tBlock.sBlockName] = string.format('lua_push_%s_pointer(lua,&%%s)',tBlock.sBlockName)
                end
            end

            if self.tMethodLuaPushName[tBlock.sBlockName] == nil then
                self.tMethodLuaPushName[tBlock.sBlockName] = string.format('lua_push_%s',tBlock.sBlockName)
            end

            if self.tMethodLuaPopName[tBlock.sBlockName] == nil then
                self.tMethodLuaPopName[tBlock.sBlockName] = string.format('lua_pop_%s',tBlock.sBlockName)
            end

            if self.tMethodLuaPopPointerName[tBlock.sBlockName] == nil then
                self.tMethodLuaPopPointerName[tBlock.sBlockName] = string.format('lua_pop_%s_pointer',tBlock.sBlockName)
            end

            if self.tMethodLuaPushPointerName[tBlock.sBlockName] == nil then
                self.tMethodLuaPushPointerName[tBlock.sBlockName] = string.format('lua_push_%s_pointer',tBlock.sBlockName)
            end
        end
    end
    return true
end

tParser.extract_variables_from_blocks = function(self,tBlockInOut)
    
    for i = 1, #tBlockInOut do
        local tBlock = tBlockInOut[i]
        tBlock.tVariables = {}
        for j = 1, #tBlock do
            local sLine  = tBlock[j]
            local tVariables = self:extract_properties_from_block(sLine)
            if tVariables then
                table.insert(tBlock.tVariables,tVariables)
            end
        end
    end
    return true
end

tParser.extract_block_from_line = function(self,tBlockOut,sBlock,sLine,tControl)
    
    local function is_inline_block(sBlock,sLine)
        local bInlineBlock = sLine:find('^%s*' .. sBlock .. '%s+%g+%s*{.+}%s*;')
        if bInlineBlock then
            local iLeftBracket  = select(2,sLine:gsub('{',''))
            local iRightBracket = select(2,sLine:gsub('}',''))
            if iLeftBracket > 0 and iLeftBracket == iRightBracket then
                return true
            end
        end
        return false
    end
    local bInserted           = false
    local bFakeBlock          = sLine:find('%g' .. sBlock) or sLine:find(sBlock.. '%g')
    local bInlineBlock        = is_inline_block(sBlock,sLine)
    local bIsDeclaration      = sLine:find('^%s*' .. sBlock .. '%s+%g+;')
    local bIsThereBlockInside = true
    

    if not bFakeBlock and sLine:find(sBlock) then
        tControl.bInsideBlock = true
    end

    if sLine:find('{') and tControl.bInsideBlock then
        local iTotabracket_open  = select(2,sLine:gsub('{',''))
        local iTotabracket_close = select(2,sLine:gsub('}',''))
        if iTotabracket_open == iTotabracket_close and tControl.iCount_block == 0 then
            local s,p            = sLine:match('{().*()}')
            local what_is_inside = sLine:sub(s,p -1)
            if what_is_inside:trim():len() == 0 then
                bIsThereBlockInside = false
            end
        end
        tControl.iCount_block = tControl.iCount_block + iTotabracket_open
    end

    if bInlineBlock then
        tControl.bInsideBlock = false
    end

    if not bIsDeclaration               and
        (bInlineBlock or tControl.bInsideBlock)   and
        bIsThereBlockInside           and
        sLine:trim():len() > 0 then
            
            bInserted = true
            table.insert(tControl.tBlock,sLine)
    end

    local bEndedBlock = false
    if sLine:find('}') and tControl.bInsideBlock then
        local iTotabracket  = select(2,sLine:gsub('}',''))
        tControl.iCount_block = tControl.iCount_block - iTotabracket
        if tControl.iCount_block <= 0 then
            tControl.bInsideBlock = false
            tControl.iCount_block = 0
            bEndedBlock  = true
        end
    end
    if bInlineBlock or bIsDeclaration then
        tControl.iCount_block = 0
        tControl.bInsideBlock = false
        bEndedBlock  = true
    end
    if bEndedBlock and #tControl.tBlock > 0 then
        table.insert(tBlockOut,tControl.tBlock)
        tControl.tBlock = {}
    end
    return {  bEndedBlock           = bEndedBlock, 
              bIsDeclaration        = bIsDeclaration,
              bFakeBlock            = bFakeBlock,
              bInlineBlock          = bInlineBlock,
              bIsThereBlockInside   = bIsThereBlockInside,
              bInserted             = bInserted
            }
end

tParser.extract_methods = function(self,out_file,tBlockOut,tBlockIn) --discard struct, class, enum
    if self.bEnableDebugToFile then
        self.fpOut = io.open(out_file,"w")
        if (self.fpOut == nil) then
            return self:failed("Could not open the out file:" .. out_file)
        end
    end

    self.tNamespace          = {}
    local tControlStruct     = {iCount_block = 0, bInsideBlock = false, tBlock = {}}
    local tControlClass      = {iCount_block = 0, bInsideBlock = false, tBlock = {}}
    local tControlEnum       = {iCount_block = 0, bInsideBlock = false, tBlock = {}}
    local tControlNamespace  = {iCount_block = 0, bInsideBlock = false, tBlock = {}}
    local tBlockOutStruct    = {}
    local tBlockOutClass     = {}
    local tBlockOutEnum      = {}
    local tBlockOutNamespace = {}

    local sPrevLine          = ''
    for l=1, #tBlockIn do
        local sLine         = tBlockIn[l].sLine
        local sOriginalLine = tBlockIn[l].sOriginalLine
        
        local tResultStruct = self:extract_block_from_line(tBlockOutStruct,
                                                    'struct',
                                                    sLine,
                                                    tControlStruct)

        local tResultClass = self:extract_block_from_line(tBlockOutClass,
                                                    'class',
                                                    sLine,
                                                    tControlClass)

        local tResultEnum = self:extract_block_from_line(tBlockOutEnum,
                                                    'enum',
                                                    sLine,
                                                    tControlEnum)
    
        local tResultNamespace = self:extract_block_from_line(tBlockOutNamespace,
                                                    'namespace',
                                                    sLine,
                                                    tControlNamespace)
        if tResultStruct.bInserted     == false and
            tResultEnum.bInserted      == false and
            tResultClass.bInserted     == false then
            local tChars = {'{','}',';','%s'}

            local sLineTemp = sLine
            for i = 1, #tChars do
                sLineTemp = sLineTemp:gsub(tChars[i],'')
            end

            
            local function multi_line_method(sLine,sPrevLine)
                local bIsMethod  = sLine:match('%(.*%)%s*%{.*%;%s*}%s*')
                if bIsMethod then
                    local p = sLine:match('%(.*()%)%s*%{')
                    sLine = sLine:sub(1,p) .. ';'
                    return true, sLine, ''
                else
                    local bIsMethod  = sLine:match('%(.*%).*;%s*$')
                    if bIsMethod then
                        return bIsMethod, sLine, ''
                        
                    else
                        sPrevLine = sPrevLine .. sLine
                        sPrevLine = sPrevLine:gsub('\n',' ')
                        bIsMethod  = sPrevLine:match('%(.*%).*;%s*$')
                        if bIsMethod then
                            return bIsMethod, sPrevLine, ''
                        else
                            return false, sLine, sPrevLine
                        end
                    end
                end
            end

            if sLineTemp:len() > 0 then

                local bPreprocessors      = sLine:match('^%s*#%s*.*')
                local bTypedef            = sLine:match('^%s*typedef%s+.+')
                local bOperator           = sLine:match('%soperator%s.+%(.*%)') or sLine:match('%soperator%[%s*%].+%(.*%)')
                local isAttrDeclaration   = sLine:match('^%s*%g+%s+%g+%s*=+%s*%g%s*;')
                local isDeclarStruct      = sLine:match('^%s*struct%s+%g+%s*;')
                local isDeclarClass       = sLine:match('^%s*class%s+%g+%s*;')
                local isDeclarNamespace   = sLine:match('^%s*namespace%s+%g+')
                local isTemplate          = sLine:match('^%s*template%s*<')
                
                if  not bPreprocessors      and
                    not bTypedef            and
                    not bOperator           and
                    not isAttrDeclaration   and
                    not isDeclarStruct      and
                    not isDeclarClass       and
                    not isDeclarNamespace   and
                    not isTemplate
                    then

                    local bIsMethod
                    bIsMethod, sLine, sPrevLine = multi_line_method(sLine,sPrevLine)
                    if bIsMethod then
                        local sMethodName, sReturnType, sRawArgs, is_pointer = self:extract_method_name_return_type_and_raw_args(sLine)
                        if sMethodName then 
                            local tParameters    = self:extract_arguments_from_raw_args(sRawArgs) -- expected only args: (size_t* out_ini_size = NULL);
                            if tParameters then
                                local tMethod = {sMethodName    = sMethodName,
                                                sReturnType     = sReturnType,
                                                return_pointer  = is_pointer,
                                                sLine           = sLine,
                                                sOriginalLine   = sOriginalLine,
                                                tParameters     = tParameters}
                                table.insert(tBlockOut,tMethod)
                            end
                        end
                    end
                end

                if isDeclarNamespace and tResultNamespace.bInserted then
                    sNamespace = sLine:match('^%s*namespace%s+(%g+)')
                    if sNamespace:trim():len() > 0 then
                        table.insert(self.tNamespace,'using namespace ' .. sNamespace .. ';')
                    end
                end
            end
        end
    end

    if self.bEnableDebugToFile then
        for i= 1, #tBlockOut do
            sLine = tBlockOut[i].sLine
            self.fpOut:write(sLine .. '\n')
        end
    end

    local function compare( a, b )
        return a:upper() < b:upper()
    end
 
    table.sort( self.tNamespace, compare )
    local n = 1
    for i = 1, #self.tNamespace do
        if self.tNamespace[n] == self.tNamespace[n + 1] then
            table.remove(self.tNamespace, n)
            n = n - 1
        end
        n = n + 1
    end
   
    self:release()

    return true
end

tParser.extract_block = function(self,sBlock,out_file,tBlockOut,tBlockIn)

    if self.bEnableDebugToFile then
        self.fpOut = io.open(out_file,"w")
        if (self.fpOut == nil) then
            return self:failed("Could not open the out file:" .. out_file)
        end
    end

    local tControl = {iCount_block = 0, bInsideBlock = false, tBlock = {}}
    for l=1, #tBlockIn do
        local sLine = tBlockIn[l].sLine
        local tResult = self:extract_block_from_line(tBlockOut,
                                                    sBlock,
                                                    sLine,
                                                    tControl)
    end

    if self.bEnableDebugToFile then
        for i= 1, #tBlockOut do
            tBlock = tBlockOut[i]
            for j =1, #tBlock do
                local sLine = tBlock[j]
                self.fpOut:write(sLine .. '\n')
            end
        end
    end

    self:release()

    return self:extract_name_from_block(sBlock,tBlockOut)
end

tParser.add_typedef = function(self,what_type,def,bIsPointer)
    --print(what_type,def,bIsPointer) -- int    my_uint32       false, char   pPointerDA      true
    if what_type:trim() ~= 'const' and what_type:trim() ~= 'T' and not self.tIgnore[what_type:trim()] then

        if bIsPointer then
            local need_create_method_push_pointer_typedef   = false
            local need_create_method_pop_pointer_typedef    = false
            if self.tTypeDefPushPointer[what_type] == nil then
                if self:is_primitive_type(what_type) then
                    if self.tPrimitiveTypePushPointer[what_type] then -- type char *
                        self.tTypeDefPushPointer[what_type] = self.tPrimitiveTypePushPointer[what_type]
                        self.tPrimitiveTypePushPointer[def] = self.tPrimitiveTypePushPointer[what_type]
                    else
                        self.tTypeDefPushPointer[what_type] = self.tPrimitiveTypePush[what_type] -- type char, int, float, etc
                    end
                else
                    self.tTypeDefPushPointer[what_type] = string.format('lua_push_%s_pointer(lua,&%%s)',what_type)
                    need_create_method_push_pointer_typedef = true
                end
            end
            self.tTypeDefPushPointer[def] = self.tTypeDefPushPointer[what_type]
            
            if self.tTypeDefPopPointer[what_type] == nil  then
                if self:is_primitive_type(what_type) then
                    if self.tPrimitiveTypePopPointer[what_type] then
                        self.tTypeDefPopPointer[what_type] = self.tPrimitiveTypePopPointer[what_type]
                        self.tPrimitiveTypePopPointer[def] = self.tPrimitiveTypePopPointer[what_type]
                    else
                        self.tTypeDefPopPointer[what_type] = self.tPrimitiveTypePop[what_type]-- type char, int, float, etc
                    end
                else
                    self.tTypeDefPopPointer[what_type] = string.format('lua_pop_%s_pointer(lua,index_input++,%%s)',what_type)
                    need_create_method_pop_pointer_typedef = true
                end
            end
            self.tTypeDefPopPointer[def] = self.tTypeDefPopPointer[what_type]

            if need_create_method_pop_pointer_typedef then
                if self.tMethodLuaPopPointerName[what_type] == nil then
                    self.tMethodLuaPopPointerName[what_type] = string.format('lua_pop_%s_pointer',what_type)
                end
            end
    
            if need_create_method_push_pointer_typedef then
                if self.tMethodLuaPushPointerName[what_type] == nil then
                    self.tMethodLuaPushPointerName[what_type] = string.format('lua_push_%s_pointer',what_type)
                end
            end

            self.tTypeDef[def] = what_type
        else
            local need_create_method_push           = false
            local need_create_method_pop            = false
            local need_create_method_pop_pointer    = false
            local need_create_method_push_pointer   = false

            if self.tPush[what_type] == nil then
                self.tPush[what_type] = string.format('lua_push_%s(lua,%%s)',what_type)
                need_create_method_push = true
            end
            self.tPush[def] = self.tPush[what_type]
            
            if self.tPop[what_type] == nil  then
                self.tPop[what_type] = string.format('lua_pop_%s(lua,index_input++)',what_type)
                need_create_method_pop = true
            end
            self.tPop[def] = self.tPop[what_type]

            if self.tPopStructClass[what_type] == nil  then
                if self.tPrimitiveTypePop[what_type] then
                    self.tPopStructClass[what_type] = self.tPrimitiveTypePop[what_type]
                else
                    self.tPopStructClass[what_type] = string.format('lua_pop_%s_pointer(lua,index_input++,&%%s)',what_type)
                    need_create_method_pop_pointer = true
                end
            end
            self.tPopStructClass[def] = self.tPopStructClass[what_type]

            if self.tPushStructClass[what_type] == nil  then
                if self.tPrimitiveTypePush[what_type] then
                    self.tPushStructClass[what_type] = self.tPrimitiveTypePush[what_type]
                else
                    self.tPushStructClass[what_type] = string.format('lua_push_%s_pointer(lua,&%%s)',what_type)
                    need_create_method_push_pointer = true
                end
            end
            self.tPushStructClass[def] = self.tPushStructClass[what_type]

            if need_create_method_push then
                if self.tMethodLuaPushName[what_type] == nil then
                    self.tMethodLuaPushName[what_type] = string.format('lua_push_%s',what_type)
                end
                self.tMethodLuaPushName[def] = self.tMethodLuaPushName[what_type]
            end
    
            if need_create_method_pop then
                if self.tMethodLuaPopName[what_type] == nil then
                    self.tMethodLuaPopName[what_type] = string.format('lua_pop_%s',what_type)
                end
            end
            
            if need_create_method_pop_pointer then
                if self.tMethodLuaPopPointerName[what_type] == nil then
                    self.tMethodLuaPopPointerName[what_type] = string.format('lua_pop_%s_pointer',what_type)
                end
            end
    
            if need_create_method_push_pointer then
                if self.tMethodLuaPushPointerName[what_type] == nil then
                    self.tMethodLuaPushPointerName[what_type] = string.format('lua_push_%s_pointer',what_type)
                end
            end
        end

    end
end

tParser.add_forward_declaration = function(self,what_type)
    if not self.tIgnore[what_type:trim()] then
        if self.tPush[what_type] == nil then
            self.tPush[what_type] = string.format('lua_push_%s(lua,%%s)',what_type)
        end
        
        if self.tPop[what_type] == nil  then
            self.tPop[what_type] = string.format('lua_pop_%s(lua,index_input++)',what_type)
        end

        if self.tPopStructClass[what_type] == nil  then
            if self.tPrimitiveTypePop[what_type] then
                self.tPopStructClass[what_type] = self.tPrimitiveTypePop[what_type]
            else
                self.tPopStructClass[what_type] = string.format('lua_pop_%s_pointer(lua,index_input++,&%%s)',what_type)
            end
        end
        
        if self.tMethodLuaPushName[what_type] == nil then
            self.tMethodLuaPushName[what_type] = string.format('lua_push_%s',what_type)
        end
        
        if self.tMethodLuaPopName[what_type] == nil then
            self.tMethodLuaPopName[what_type] = string.format('lua_pop_%s',what_type)
        end

        if self.tMethodLuaPopPointerName[what_type] == nil then
            self.tMethodLuaPopPointerName[what_type] = string.format('lua_pop_%s_pointer',what_type)
        end

        if self.tMethodLuaPushPointerName[what_type] == nil then
            self.tMethodLuaPushPointerName[what_type] = string.format('lua_push_%s_pointer',what_type)
        end
    end
end

tParser.extract_typedef = function(self,in_file,out_file,tBlockOut,tBlockIn)

    if self.bEnableDebugToFile then
        self.fpIn = io.open(in_file,"r")
        if (self.fpIn == nil) then
            return self:failed("Could not open the in file:" .. in_file)
        end

        self.fpOut = io.open(out_file,"w")
        if (self.fpOut == nil) then
            return self:failed("Could not open the out file:" .. out_file)
        end
    end
    
    for l=1, #tBlockIn do
        local sLine = tBlockIn[l].sLine
        if not sLine:find('%(.*%)') then
            if sLine:find('%s*typedef%s+%g+%s*%**%s+%g+%s*;') then --simple typedef int
                local what_type,def = sLine:match('%s*typedef%s+(%g+)%s*%**%s+(%g+)%s*;')
                what_type = what_type:gsub('%*','')
                what_type = what_type:trim()
                def       = def:trim()
                if sLine:match(what_type .. '%s*%*') then 
                    self:add_typedef(what_type,def,true)
                else
                    self:add_typedef(what_type,def,false)
                end
                table.insert(tBlockOut,sLine)
            elseif sLine:find('%s*typedef%s+%g+%s+%g+%s*%**%s+%g+%s*;') then --double typedef unsigned int
                local what_type_1,what_type_2 ,def = sLine:match('%s*typedef%s+(%g+)%s+(%g+)%s*%**%s+(%g+)%s*;')
                what_type_1 = what_type_1:gsub('%*','')
                what_type_1 = what_type_1:trim()
                what_type_2 = what_type_2:gsub('%*','')
                what_type_2 = what_type_2:trim()
                def         = def:trim()
                if what_type_1 == 'signed' or what_type_1 == 'unsigned' then
                    if sLine:match(what_type_2 .. '%s*%*') then 
                        self:add_typedef(what_type_2,def,true)
                    else
                        self:add_typedef(what_type_2,def,false)
                    end
                else
                    if sLine:match(what_type_1 .. '%s*%*') then 
                        self:add_typedef(what_type_1,def,true)
                    else
                        self:add_typedef(what_type_1,def,false)
                    end
                    if sLine:match(what_type_2 .. '%s*%*') then 
                        self:add_typedef(what_type_2,def,true)
                    else
                        self:add_typedef(what_type_2,def,false)
                    end
                end
                table.insert(tBlockOut,sLine)
            end
        end
    end

    if self.bEnableDebugToFile then
        for i= 1, #tBlockOut do
            tBlock = tBlockOut[i]
            for j =1, #tBlock do
                local sLine = tBlock[j]
                self.fpOut:write(sLine .. '\n')
            end
        end
    end

    self:release()
    return true
end

tParser.extract_forward_declaration = function(self,in_file,out_file,tBlockOut,tBlockIn)

    if self.bEnableDebugToFile then
        self.fpIn = io.open(in_file,"r")
        if (self.fpIn == nil) then
            return self:failed("Could not open the in file:" .. in_file)
        end

        self.fpOut = io.open(out_file,"w")
        if (self.fpOut == nil) then
            return self:failed("Could not open the out file:" .. out_file)
        end
    end
    
    for l=1, #tBlockIn do
        local sLine = tBlockIn[l].sLine
        if not sLine:find('%(.*%)') then
            if sLine:find('%s*struct%s+%g+%s*;') then --simple forward declaration for struct
                local struct = sLine:match('%s*struct%s+(%g+)%s*;')
                struct = struct:gsub('%*','')
                struct = struct:trim()
                self:add_forward_declaration(struct)
                table.insert(tBlockOut,struct)
            elseif sLine:find('%s*class%s+%g+%s*;') then --simple forward declaration for class
                local class = sLine:match('%s*class%s+(%g+)%s*;')
                class = class:gsub('%*','')
                class = class:trim()
                self:add_forward_declaration(class)
                table.insert(tBlockOut,class)
            end
        end
    end

    if self.bEnableDebugToFile then
        for i= 1, #tBlockOut do
            tBlock = tBlockOut[i]
            for j =1, #tBlock do
                local sLine = tBlock[j]
                self.fpOut:write(sLine .. '\n')
            end
        end
    end

    self:release()
    return true
end

tParser.remove_cpp_comment = function(self,in_file,out_file,bEndOfLine,tBlockOut,tBlockIn)

    self.fpIn = io.open(in_file,"r")
    if (self.fpIn == nil) then
        return self:failed("Could not open the in file:" .. in_file)
    end

    if self.bEnableDebugToFile then
        self.fpOut = io.open(out_file,"w")
        if (self.fpOut == nil) then
            return self:failed("Could not open the out file:" .. out_file)
        end
    end

    local bSkipComment = false
    
    for sLine in self.fpIn:lines() do
    
        sLine = sLine:gsub('\r','')
        local sOriginalLine = sLine
        if sLine:trim():len() > 0 then
            if not sLine:find('^%s*//') and not sLine:find('^%s+$') then --skip comment, empty line
                
                if sLine:find('^%s*/%*.*$') then
                    bSkipComment = true
                end

                if sLine:find('^%s*%*/.*$') then
                    bSkipComment = false
                    local p = sLine:match('^%s*()%*/.*$')
                    local sLineTemp = sLine:sub(p+2)
                    if sLineTemp then
                        sLine = sLineTemp
                    else
                        sLine = ''
                    end
                end

                
                if sLine:find('/%*') then
                    bSkipComment = true
                    local p = sLine:match('()/%*')
                    local sLineTemp = sLine:sub(1,p-1)
                    if sLineTemp then
                        sLine = sLineTemp
                    else
                        sLine = ''
                    end

                    if sLine:trim():len() > 0 then
                        table.insert(tBlockOut,{sLine = sLine, sOriginalLine = sOriginalLine})
                        if self.bEnableDebugToFile then
                            self.fpOut:write(sLine .. '\n')
                        end
                    end
                end

                if sLine:find('%*/') then
                    bSkipComment = false
                    local p = sLine:match('%*/()')
                    local sLineTemp = sLine:sub(p+1)
                    if sLineTemp then
                        sLine = sLineTemp
                    else
                        sLine = ''
                    end
                end

                if bEndOfLine and sLine:find('//') then
                    local p = sLine:match('()//')
                    local sLineTemp = sLine:sub(1,p-1)
                    if sLineTemp then
                        sLine = sLineTemp
                    else
                        sLine = ''
                    end
                end

                if bSkipComment == false then
                    if sLine:trim():len() > 0 then
                        table.insert(tBlockOut,{sLine = sLine, sOriginalLine = sOriginalLine})
                        if self.bEnableDebugToFile then
                            self.fpOut:write(sLine .. '\n')
                        end
                    end
                end
            end
        end
    end
    self:release()
    return true
end

tParser.bEnableDebugToFile = false

if #_G.arg <= 0 then
    print('usage:',_G.arg[0],'<file.h>')
else
    local sFilenameIn=_G.arg[1]
    local sProjectName = sFilenameIn:gsub("\\",'/')
    local tProjectName = sProjectName:split('/')
    sProjectName = tProjectName[#tProjectName]:gsub('%..*$','')
    print('Project:',sProjectName)
    tParser:set_project_name(sProjectName)
    local headerHPP = sProjectName .. 'lua.h'
    local sourceCPP = sProjectName .. 'lua.cpp'
    local sRSTDoc   = sProjectName .. 'lua.rst'

    local bResult, hpp, cpp, doc = tParser:parse(sFilenameIn)

    if bResult then
        local bWritten = false
        tParser.fpOut = io.open(sourceCPP,"w")
        if (tParser.fpOut == nil) then
            tParser:failed("Could not create the file:" .. sourceCPP)
            
        else
            tParser.fpOut:write(cpp)
            tParser.fpOut:close()
            tParser.fpOut = io.open(headerHPP,"w")
            if (tParser.fpOut == nil) then
                tParser:failed("Could not create the file:" .. headerHPP)
            else
                tParser.fpOut:write(hpp)
                tParser.fpOut:close()
                tParser.fpOut = nil

                tParser.fpOut = io.open(sRSTDoc,"w")
                if (tParser.fpOut == nil) then
                    tParser:failed("Could not create the file:" .. sRSTDoc)
                else
                    tParser.fpOut:write(doc)
                    tParser.fpOut:close()
                    tParser.fpOut = nil
                    bWritten = true
                end
            end
        end
        if bWritten then
            print('Successfully generated file:',headerHPP)
            print('Successfully generated file:',sourceCPP)
            print('Successfully generated file:',sRSTDoc)
        end
    end
    tParser:release()
end
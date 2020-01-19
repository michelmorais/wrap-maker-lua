# wrap-maker-lua

create wrap (modules) to be used in LUA (current version 5.2.2) based on include (*.h) from any library.

## How to

An unique parser is needed:**wrap-maker.lua** located in the *src* folder.

The parser get a full path of a file (*.h) to parse and generate the needed wrapper (*.h, *.cpp).

## Example

Let's create a simnple library in C++ to demonstarte how does the **wrap-maker.lua** works.

#### dummyCalc.h
```cpp

int sum(const int v1, const int v2);


```

#### dummyCalc.cpp
```cpp

#include "dummyCalc.h"

int sum(const int v1, const int v2)
{
    return v1 + v2;
}

```

This is our library! pretty simple isn't?!


Now, the point is that there is a similar way to make it as **module** to be used in LUA.

Here is where the **wrap-maker.lua** comes...

### Parsing using **wrap-maker.lua**

![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/first-run.png)

As you can see, the only arg to **wrap-maker.lua** is the header file.

![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/run-over-test-folder.png)

Voila! Let's take a look what was created:

#### dummyCalclua.h

```cpp

#include "dummyCalc.h"

extern "C" DUMMYCALC_IMP_API int luaopen_dummyCalclua (lua_State * lua);


```

#### dummyCalclua.cpp

```cpp

int onNewdummycalcLua(lua_State *lua)
{
    const int  top                          = lua_gettop(lua);
    lua_settop(lua, 0);
    luaL_Reg regdummycalcMethods[]          = {  
        {"sum", onSumdummyCalcLua },
        {"test",  onTestdummycalc},//this method demonstrates how to get the class of a lua call
        {nullptr, nullptr}};

    luaL_newlib(lua, regdummycalcMethods);
    luaL_getmetatable(lua, "_mbmdummyCalc_LUA");
    lua_setmetatable(lua, -2);
    DUMMYCALC_LUA **udata                   = static_cast<DUMMYCALC_LUA **>(lua_newuserdata(lua, sizeof(DUMMYCALC_LUA *)));
    DUMMYCALC_LUA * that                    = new DUMMYCALC_LUA();
    *udata                                  = that;
    
    lua_rawseti(lua, -2, 1);
    return 1;
}

int luaopen_dummyCalclua (lua_State *lua)
{
    registerClassdummycalc(lua);
    return onNewdummycalcLua(lua);
}
```

There are more code generated which were omitted for explanation purpose (*This is not the full code*).

However the important to know is that those two files (dummyCalc**lua**.h and dummyCalc**lua**.cpp) are the wrapper generated.

You might need to adjust or solve some missing part in the parse however for this example it works just fine.

### Now, using it is just needed to build the module.

From test folder:

```sh

mkdir build && cd build && cmake .. && make


```

Here what we just have done:

![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/using-cmake-example.png)

Of course you **must** to adjust the path of **LUA** library according to your environment.


### Using the module in LUA

Now let's see how to use the module:

Before you dive deep in LUA let's make sure that the shared library is reachable.

Set the **LD_LIBRARY_PATH** to the right path:

```sh

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:~/wrap-maker-lua/test/build"

```

From lua interpreter use your module:

```lua

dummy = require "dummyCalclua"
result = dummy.sum(2,5)
print(result)

```


![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/lua-interpreter-module.png)



### What is the code behind of the wrapper?


The script **wrap-maker.lua** interpreted like this (two integers parameters and one result integer):


```cpp

int onSumdummyCalcLua(lua_State *lua)
{
    int index_input    = 1;
    const int v1       = luaL_checkinteger(lua,index_input++);
    const int v2       = luaL_checkinteger(lua,index_input++);
    const int ret_int  = sum(v1,v2);
    lua_pushinteger(lua,ret_int);
    return 1;
}

```


That is it folks!


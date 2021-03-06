# wrap-maker-lua

Create wrap (modules) to be used in [LUA](https://www.lua.org/home.html) (current version [5.2.2](https://www.lua.org/manual/5.2/) ) based on include (*.h) from any library.

## How to

An unique parser is needed:**wrap-maker.lua** located in the *src* folder.

The parser get a full path of a file (*.h) to parse and generate the needed wrapper (*.h, *.cpp).

## Motivation

The idea behind this is to facilitate some work that I have on my own engine and I thought it would be nice to share the work :)

There are a lot of useful libraries in C/C++ that has not a wrapper to **LUA** or if has, is not a pure. That is my main motivation. To easily use modules in **LUA** to be able to integrate to my project but in a isolated way (Not a really dependency).

As just explained, I use this to prototype some module in my engine, however, it generates a module compatible with [LUA 5.2.2](https://www.lua.org/manual/5.2/) which can also be used as pure module in **LUA**.

## Example

Let's create a simple library in C++ to demonstrate how does the **wrap-maker.lua** works.

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


Now, the point is that there is a similar way to make it as **module** to be used in [LUA](https://www.lua.org/home.html).

Here is where the **wrap-maker.lua** comes...

### Parsing using **wrap-maker.lua**

![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/first-run.png)

As you can see, the only arg that **wrap-maker.lua** need is the header file.


Let's parse our simple library **dummyCalc.h**:

![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/run-over-test-folder.png)

Voila! Let's take a look what was created:

#### dummyCalclua.h

```cpp

#include "dummyCalc.h"

extern "C" DUMMYCALC_IMP_API int luaopen_dummyCalclua (lua_State * lua);


```

#### dummyCalclua.cpp

```cpp

// Some previously generated code, but not interested at the moment ...

// Then the main entry point

int luaopen_dummyCalclua (lua_State *lua)
{
    registerClassdummycalc(lua);
    return onNewdummycalcLua(lua);
}
```

There are more generated code which were omitted for explanation purpose (*This is not the full code*).

Therefore the important to understand at this moment is that those two files (dummyCalc**lua**.h and dummyCalc**lua**.cpp) are the wrapper generated.

You might need to adjust or solve some missing part *post-parse* for other libraries, however, for this example, it works just fine.

### Now, just use it to build the module.

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

From **LUA** interpreter use your module:

```lua

dummy = require "dummyCalclua"
result = dummy.sum(2,5)
print(result)

```


![alt text](https://raw.githubusercontent.com/michelmorais/wrap-maker-lua/master/images/lua-interpreter-module.png)



### What is the code behind the wrapper?


The script **wrap-maker.lua** have interpreted for this example two parameters as integers and one result as integer:


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

When you call **dummy.sum(2,5)** this is the code called in the module.

That's all folks!


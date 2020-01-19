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

![alt text](https://github.com/michelmorais/wrap-maker-lua/edit/master/images/first-run.png)

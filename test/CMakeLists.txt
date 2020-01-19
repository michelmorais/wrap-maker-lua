cmake_minimum_required(VERSION 3.0)
cmake_policy(SET CMP0054 NEW)

set(WRAPPER_LIBRARY "dummyCalclua")

project(${WRAPPER_LIBRARY})

set(INCLUDE ".")
set(SOURCES ".")
set(LUA_VERSION_STRING      "5.2.2")
#I have have lua in my projects however you can set the right path or try to use find_package(Lua52 REQUIRED) 
set(LUA_INCLUDE_DIR         "/home/michel/mini-mbm-linux/third-party/lua-${LUA_VERSION_STRING}")
set(LUA_LIBRARIES           "lua-${LUA_VERSION_STRING}")
 
#find_package(Lua52 REQUIRED) 

message(STATUS "Building ${WRAPPER_LIBRARY} lib...")
file(GLOB_RECURSE DUMMY_SOURCES        "${SOURCES}/*.cpp")

#Bring the headers, such as xxx.h into the project
include_directories(${INCLUDE} ${LUA_INCLUDE_DIR})
link_directories("/home/michel/mini-mbm-linux/bin/release/linux_x86")
 
# remove pre fix "lib"
set(CMAKE_SHARED_LIBRARY_PREFIX "")
#Generate the shared library from the sources
add_library(${WRAPPER_LIBRARY} SHARED ${DUMMY_SOURCES})
# link to lua
target_link_libraries(${WRAPPER_LIBRARY} ${LUA_LIBRARIES})
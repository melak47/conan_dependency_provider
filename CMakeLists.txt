cmake_minimum_required(VERSION 3.24)

project(cdp VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(fmt REQUIRED)

add_executable(cdp src/cdp.cpp)
target_link_libraries(cdp PRIVATE fmt::fmt)


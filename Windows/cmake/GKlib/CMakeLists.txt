cmake_minimum_required(VERSION 3.18)
project(GKlibAdapter LANGUAGES C)
set(GKLIB_BUILD_APPS OFF CACHE BOOL "" FORCE)
set(SHARED OFF CACHE BOOL "" FORCE)
# 上游安装头文件使用 CMAKE_SOURCE_DIR，而不是自身目录。
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/../include" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/.." upstream)
# 上游无条件使用 GCC 优化选项；MSVC 的优化由构建配置负责。
if(MSVC)
    set_property(TARGET GKlib PROPERTY COMPILE_OPTIONS "")
    set_property(TARGET GKlib PROPERTY INTERFACE_COMPILE_OPTIONS "")
    target_compile_definitions(GKlib PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
set_target_properties(GKlib PROPERTIES
    COMPILE_PDB_NAME GKlib
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/symbols")

# 输出cmake版本提示
message(STATUS "The CMAKE_VERSION is ${CMAKE_VERSION}.")

# cmake的最低版本要求
cmake_minimum_required (VERSION 3.10)

# 工程名称、版本、语言
project(minizip VERSION 5.2.2)

# 支持当前目录
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# 判断编译器类型
message("CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")

# 判断编译器类型
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    message(">> using Clang")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message(">> using GCC")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
    message(">> using Intel C++")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(">> using Visual Studio C++")	  
    add_compile_options(/utf-8 /wd4996)  
else()
    message(">> unknow compiler.")
endif()

# 查找 ZLIB 模块
find_package(ZLIB REQUIRED)

# 源代码文件
set(PROJECT_SOURCES ioapi.c iowin32.c miniunz.c minizip.c mztools.c unzip.c zip.c)
set(PROJECT_HEADER crypt.h ioapi.h iowin32.h mztools.h unzip.h zip.h)

# 将源代码添加到此项目的可执行文件。
add_library(${PROJECT_NAME} STATIC ${PROJECT_SOURCES} ${PROJECT_HEADER})

#
target_link_libraries(${PROJECT_NAME} ZLIB::ZLIB)

# TODO: 如有需要，请添加测试

# 安装头文件到 include 目录
install(FILES ${PROJECT_HEADER} DESTINATION include/${PROJECT_NAME})

# 安装库文件到 lib 目录
install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION lib  # 对于共享库
        ARCHIVE DESTINATION lib  # 对于静态库
        RUNTIME DESTINATION bin  # 对于可执行文件
)

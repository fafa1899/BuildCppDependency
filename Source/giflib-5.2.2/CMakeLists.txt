# 输出cmake版本提示
message(STATUS "The CMAKE_VERSION is ${CMAKE_VERSION}.")

# cmake的最低版本要求
cmake_minimum_required (VERSION 3.10)

# 工程名称、版本、语言
project(giflib VERSION 5.2.2)

# 支持当前目录
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# 判断编译器类型
message("CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")

# 源代码文件
set(GIF_SRC dgif_lib.c egif_lib.c gifalloc.c gif_err.c gif_font.c gif_hash.c openbsd-reallocarray.c)
set(GIF_HEADER gif_hash.h  gif_lib.h  gif_lib_private.h)
#set(GIF_UTILSRC qprintf.c quantize.c getarg.c)
#set(GIF_UTILHEADER getarg.h)

# 动态库前缀与后缀
IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
	set(LibraryPrefix lib)
    set(LibraryPostfix so)
ELSEIF(CMAKE_SYSTEM_NAME MATCHES "Windows")
	set(LibraryPrefix )
    set(LibraryPostfix lib)
ENDIF()

# 将源代码添加到此项目的可执行文件。
add_library(${PROJECT_NAME} SHARED ${GIF_SRC} ${GIF_HEADER})

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
    set_property(TARGET ${PROJECT_NAME} PROPERTY LINK_FLAGS
    /DEF:"${CMAKE_SOURCE_DIR}/giflib.def")
else()
    message(">> unknow compiler.")
endif()

# TODO: 如有需要，请添加测试

# 安装头文件到 include 目录
install(FILES gif_lib.h DESTINATION include)

# 安装库文件到 lib 目录
install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION lib  # 对于共享库
        ARCHIVE DESTINATION lib  # 对于静态库
        RUNTIME DESTINATION bin  # 对于可执行文件
)

# 输出cmake版本提示
message(STATUS "The CMAKE_VERSION is ${CMAKE_VERSION}.")

# cmake的最低版本要求
cmake_minimum_required (VERSION 3.10)

# 工程名称、版本、语言
project(sqlite3 VERSION 3.4.6)

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
    add_compile_options(/utf-8)
else()
    message(">> unknow compiler.")
endif()

# 设置编译定义
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} \
-DSQLITE_THREADSAFE=1 \
-DSQLITE_ENABLE_COLUMN_METADATA \
-DSQLITE_ENABLE_PREUPDATE_HOOK \
-DSQLITE_ENABLE_RTREE \
-DSQLITE_ENABLE_GEOPOLY \
-DSQLITE_ENABLE_SESSION \
-DSQLITE_ENABLE_RBU")

# 源代码文件
set(INCLUDE_FILES 
    ./include/sqlite3.h
    ./include/sqlite3ext.h
)
set(SOURCE_FILES
    ./src/sqlite3.c
    ${INCLUDE_FILES}
)

# 动态库前缀与后缀
IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
	set(LibraryPrefix lib)
    set(LibraryPostfix so)
ELSEIF(CMAKE_SYSTEM_NAME MATCHES "Windows")
	set(LibraryPrefix )
    set(LibraryPostfix lib)
ENDIF()


# 将源代码添加到此项目的可执行文件。
add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})

if(CMAKE_SYSTEM_NAME MATCHES "Windows")   
    # 指定.def文件
    set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME ${PROJECT_NAME}
    LINK_FLAGS "/DEF:${CMAKE_CURRENT_SOURCE_DIR}/sqlite3.def")
endif()

# TODO: 如有需要，请添加测试

# 安装头文件到 include 目录
install(DIRECTORY include/ DESTINATION include)

# 安装库文件到 lib 目录
install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION lib  # 对于共享库
        ARCHIVE DESTINATION lib  # 对于静态库
        RUNTIME DESTINATION bin  # 对于可执行文件
)

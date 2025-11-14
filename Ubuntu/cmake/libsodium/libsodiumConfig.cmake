# Find the libsodium installation
set(LIBSODIUM_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../include")
set(LIBSODIUM_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../lib")
set(LIBSODIUM_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../bin")

# Import the targets
include("${CMAKE_CURRENT_LIST_DIR}/libsodiumTargets.cmake")

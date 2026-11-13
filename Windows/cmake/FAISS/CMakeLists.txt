cmake_minimum_required(VERSION 3.24)
project(FaissWindowsAdapter LANGUAGES CXX)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/.." upstream)

# Static consumers must not treat symbols as DLL imports on Windows.
if(WIN32 AND NOT BUILD_SHARED_LIBS)
    target_compile_definitions(faiss PUBLIC FAISS_MAIN_LIB)
endif()
set_target_properties(faiss PROPERTIES
    COMPILE_PDB_NAME faiss
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/symbols")

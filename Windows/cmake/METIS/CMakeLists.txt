cmake_minimum_required(VERSION 3.18)
project(METIS VERSION 5.2.1 LANGUAGES C)
include(CMakePackageConfigHelpers)
find_package(GKlib CONFIG REQUIRED)
get_filename_component(METIS_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE)
file(READ "${METIS_SOURCE}/include/metis.h" METIS_HEADER)
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/include/metis.h"
    "#define IDXTYPEWIDTH 32\n#define REALTYPEWIDTH 32\n${METIS_HEADER}")
file(GLOB METIS_SOURCES CONFIGURE_DEPENDS "${METIS_SOURCE}/libmetis/*.c")
add_library(metis STATIC ${METIS_SOURCES})
target_include_directories(metis
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include> $<INSTALL_INTERFACE:include>
    PRIVATE "${METIS_SOURCE}/libmetis")
target_link_libraries(metis PUBLIC GKlib::GKlib)
target_compile_definitions(metis PRIVATE USE_GKREGEX)
if(MSVC)
    target_compile_definitions(metis PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
set_target_properties(metis PROPERTIES COMPILE_PDB_NAME metis
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/symbols")
install(TARGETS metis EXPORT metisTargets ARCHIVE DESTINATION lib)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/include/metis.h" DESTINATION include)
install(EXPORT metisTargets DESTINATION lib/cmake/metis)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/metisConfig.cmake"
    "include(CMakeFindDependencyMacro)\nfind_dependency(GKlib CONFIG)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/metisTargets.cmake\")\n")
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/metisConfigVersion.cmake"
    VERSION 5.2.1 COMPATIBILITY SameMajorVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/metisConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/metisConfigVersion.cmake" DESTINATION lib/cmake/metis)

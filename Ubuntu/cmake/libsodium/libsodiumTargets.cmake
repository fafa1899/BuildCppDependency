# Define the imported target for libsodium
add_library(libsodium::libsodium SHARED IMPORTED)

# Platform-specific properties
if(WIN32)
    # Windows-specific configuration
    set_target_properties(libsodium::libsodium PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBSODIUM_INCLUDE_DIR}"
        IMPORTED_LOCATION "${LIBSODIUM_BIN_DIR}/libsodium.dll"
        IMPORTED_IMPLIB "${LIBSODIUM_LIB_DIR}/libsodium.lib"
    )
else()
    # Linux-specific configuration
    set_target_properties(libsodium::libsodium PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBSODIUM_INCLUDE_DIR}"
        IMPORTED_LOCATION "${LIBSODIUM_LIB_DIR}/libsodium.so"  # Shared library file on Linux
    )
endif()

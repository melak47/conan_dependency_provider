# Always ensure we have the policy settings this provider expects
cmake_minimum_required(VERSION 3.24)

set(CONAN_INSTALL_DIR ${CMAKE_BINARY_DIR}/conan
  CACHE PATH "The directory conan installs <package>-config.cmake files to"
)

# Tell the built-in implementation to look in our area first, unless
# the find_package() call uses NO_..._PATH options to exclude it
list(APPEND CMAKE_MODULE_PATH "${CONAN_INSTALL_DIR}")
list(APPEND CMAKE_PREFIX_PATH "${CONAN_INSTALL_DIR}")

if (EXISTS "${CMAKE_SOURCE_DIR}/conanfile.txt")
    set(CONANFILE "${CMAKE_SOURCE_DIR}/conanfile.txt")
elseif (EXISTS "${CMAKE_SOURCE_DIR}/conanfile.py")
    set(CONANFILE "${CMAKE_SOURCE_DIR}/conanfile.py")
else()
    message(FATAL_ERROR "no conanfile found in project root (${CMAKE_SOURCE_DIR})")
endif()

set(CDP_DIR "${CMAKE_CURRENT_LIST_DIR}")

set(LAST_CONANFILE ${CONAN_INSTALL_DIR}/conanfile)

file(MD5 ${CONANFILE} CONANFILE_HASH)

function(conan_provide_dependency method)
    # conan.cmake cannot detect compiler and other conan profile settings until
    # after project() has finished, so we need to delay it until the first find_package() call.
    # That's the only reason I implement this function at all;
    include(${CDP_DIR}/conan.cmake)

    if (NOT EXISTS ${LAST_CONANFILE} OR NOT CONANFILE_HASH STREQUAL LAST_CONANFILE_HASH)
        get_property(MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

        if (MULTI_CONFIG)
            foreach(TYPE ${CMAKE_CONFIGURATION_TYPES})
                conan_cmake_autodetect(settings BUILD_TYPE "${TYPE}")
                conan_cmake_install(
                    PATH_OR_REFERENCE ${CONANFILE}
                    BUILD missing
                    GENERATOR CMakeDeps
                    INSTALL_FOLDER ${CONAN_INSTALL_DIR}
                    SETTINGS ${settings}
                )
            endforeach()
        else() # single-config
            # override dependency build type to Release,
            # conan-center doesn't have RelWithDebInfo binaries
            if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
                set(CONAN_BUILD_TYPE "build_type=Release")
            endif()

            conan_cmake_autodetect(settings)
            unset(LAST_CONANFILE_HASH CACHE)
            conan_cmake_install(
                PATH_OR_REFERENCE ${CONANFILE}
                BUILD missing
                GENERATOR CMakeDeps
                INSTALL_FOLDER ${CONAN_INSTALL_DIR}
                SETTINGS ${settings} ${CONAN_BUILD_TYPE}
            )
            set(
                LAST_CONANFILE_HASH ${CONANFILE_HASH} CACHE STRING
                "conanfile hash from last successful conan install"
            )
        endif()

        # cause cmake to reconfigure if we make changes to conanfile.txt
        configure_file(${CONANFILE} ${LAST_CONANFILE} COPYONLY)
    endif()
endfunction()

cmake_language(
    SET_DEPENDENCY_PROVIDER conan_provide_dependency
    SUPPORTED_METHODS FIND_PACKAGE
)

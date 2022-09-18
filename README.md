Toy example of a [CMake dependency provider](https://cmake.org/cmake/help/latest/command/cmake_language.html#set-dependency-provider) that uses the [conan](https://conan.io) package manager to satisfy dependencies.

Pass `-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=cmake/conan_dependency_provider.cmake` to cmake to
enable the conan integration.

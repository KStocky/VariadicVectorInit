cmake_minimum_required(VERSION 3.30)

project(VariadicVectorInit VERSION 0.1.0 LANGUAGES CXX)

if(NOT WIN32 OR NOT MSVC)
    message(FATAL_ERROR "This project requires x64 Windows and MSVC or Clang-CL.")
endif()
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "Select an x64 compiler environment.")
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Do not let unrelated GNU tools on PATH become the MSVC librarian.
find_program(MSVC_LIB_EXECUTABLE NAMES lib.exe REQUIRED)
set(CMAKE_AR "${MSVC_LIB_EXECUTABLE}")

include(CTest)
set(FETCHCONTENT_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dependencies")
include(FetchContent)
include(cmake/SourceDXC.cmake)

FetchContent_Declare(
    catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.11.0
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/catch2-build"
)
FetchContent_Declare(
    stf
    GIT_REPOSITORY https://github.com/KStocky/ShaderTestFramework.git
    GIT_TAG d176dbb5892c894fd784202165d7b82f6f48ce40
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/stf-build"
)
set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)
set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)
set(STF_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(STF_INCLUDE_EXAMPLES OFF CACHE BOOL "" FORCE)
set(STF_DISABLE_UNITY_STF ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(stf)

set(stf_patch "${CMAKE_CURRENT_SOURCE_DIR}/cmake/stf-hlsl-const.patch")
execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${stf_SOURCE_DIR}" apply --reverse --check --unidiff-zero "${stf_patch}"
    RESULT_VARIABLE stf_patch_applied
    OUTPUT_QUIET ERROR_QUIET
)
if(NOT stf_patch_applied EQUAL 0)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${stf_SOURCE_DIR}" apply --unidiff-zero "${stf_patch}"
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()

list(PREPEND CMAKE_MODULE_PATH "${stf_SOURCE_DIR}/cmake")
add_dependencies(ShaderTestFramework source-dxc)

add_executable(variadic-vector-init-tests
    test/ShaderTests.cpp
    shader/VectorInit.hlsl
    shader/VectorInit.hlsli
)
set_source_files_properties(shader/VectorInit.hlsl shader/VectorInit.hlsli PROPERTIES HEADER_FILE_ONLY TRUE)
target_compile_options(variadic-vector-init-tests PRIVATE /W4 /permissive-)
set_target_properties(variadic-vector-init-tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    VS_DEBUGGER_WORKING_DIRECTORY "$<TARGET_FILE_DIR:variadic-vector-init-tests>"
)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES
    test/ShaderTests.cpp shader/VectorInit.hlsl shader/VectorInit.hlsli
)

include(AssetDependencyManagement)
include(STF)
asset_dependency_init(variadic-vector-init-tests)
target_add_asset_directory(variadic-vector-init-tests "${CMAKE_CURRENT_SOURCE_DIR}/shader" "/Shader")
add_stf_with_catch2(variadic-vector-init-tests)
set_target_properties(ShaderTestFramework Catch2 Catch2WithMain PROPERTIES
    FOLDER Dependencies
    UNITY_BUILD OFF
)

# The copy targets must wait for DXC, even when Ninja schedules them in parallel.
add_custom_target(deploy-source-dxc
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${SOURCE_DXC_RUNTIME_DIR}"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
        "${SOURCE_DXC_BUILD_DIR}/bin/dxcompiler.dll"
        "${SOURCE_DXC_BUILD_DIR}/bin/dxil.dll"
        "${SOURCE_DXC_BUILD_DIR}/bin/dxc.exe"
        "${SOURCE_DXC_RUNTIME_DIR}"
    DEPENDS source-dxc
    VERBATIM
)
get_property(project_targets DIRECTORY PROPERTY BUILDSYSTEM_TARGETS)
foreach(target IN LISTS project_targets)
    if(target MATCHES "^variadic-vector-init-testsCopy[0-9]+$")
        add_dependencies("${target}" deploy-source-dxc)
    endif()
endforeach()

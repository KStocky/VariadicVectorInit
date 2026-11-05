include_guard(GLOBAL)
include(ExternalProject)

find_package(Git REQUIRED)
set(SOURCE_DXC_REVISION ea3489109cc8a968b36e36ca20a698a68b516d32)
message(STATUS "Source DXC revision: ${SOURCE_DXC_REVISION}")

# A separate Release build isolates DXC's LLVM settings from the C++23 project.
# Both application toolchains reuse this MSVC-built compiler.
set(SOURCE_DXC_SOURCE_DIR "${PROJECT_SOURCE_DIR}/out/dxc/src/source-dxc")
set(SOURCE_DXC_BUILD_DIR "${PROJECT_SOURCE_DIR}/out/dxc/build")
set(SOURCE_DXC_RUNTIME_DIR "${PROJECT_SOURCE_DIR}/out/dxc/runtime")
find_program(SOURCE_DXC_CL NAMES cl.exe REQUIRED)
find_program(SOURCE_DXC_LIB NAMES lib.exe REQUIRED)
find_program(SOURCE_DXC_LINK NAMES link.exe REQUIRED)

ExternalProject_Add(source-dxc
    PREFIX "${PROJECT_SOURCE_DIR}/out/dxc"
    GIT_REPOSITORY https://github.com/microsoft/DirectXShaderCompiler.git
    GIT_TAG "${SOURCE_DXC_REVISION}"
    GIT_CONFIG core.longpaths=true
    GIT_SUBMODULES external/DirectX-Headers
    SOURCE_DIR "${SOURCE_DXC_SOURCE_DIR}"
    BINARY_DIR "${SOURCE_DXC_BUILD_DIR}"
    CMAKE_GENERATOR Ninja
    CMAKE_ARGS
        -C "${SOURCE_DXC_SOURCE_DIR}/cmake/caches/PredefinedParams.cmake"
        "-DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM}"
        "-DCMAKE_C_COMPILER:FILEPATH=${SOURCE_DXC_CL}"
        "-DCMAKE_CXX_COMPILER:FILEPATH=${SOURCE_DXC_CL}"
        "-DCMAKE_AR:FILEPATH=${SOURCE_DXC_LIB}"
        "-DCMAKE_LINKER:FILEPATH=${SOURCE_DXC_LINK}"
        -DCMAKE_LINKER_TYPE=MSVC
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_TARGETS_TO_BUILD=None
        -DLLVM_INCLUDE_TESTS=OFF
        -DCLANG_INCLUDE_TESTS=OFF
        -DHLSL_INCLUDE_TESTS=OFF
        -DHLSL_BUILD_DXILCONV=OFF
        -DENABLE_SPIRV_CODEGEN=OFF
        -DSPIRV_BUILD_TESTS=OFF
        -DLLVM_ENABLE_ASSERTIONS=OFF
    BUILD_COMMAND "${CMAKE_COMMAND}" --build <BINARY_DIR>
        --target dxc dxcompiler dxildll --parallel 12
    BUILD_ALWAYS TRUE
    BUILD_BYPRODUCTS
        "${SOURCE_DXC_BUILD_DIR}/lib/dxcompiler.lib"
        "${SOURCE_DXC_BUILD_DIR}/bin/dxcompiler.dll"
        "${SOURCE_DXC_BUILD_DIR}/bin/dxil.dll"
        "${SOURCE_DXC_BUILD_DIR}/bin/dxc.exe"
    INSTALL_COMMAND ""
)
set_target_properties(source-dxc PROPERTIES FOLDER Dependencies)
set(CMAKE_PROJECT_ShaderTestingFramework_INCLUDE
    "${CMAKE_CURRENT_LIST_DIR}/SourceDXCOverride.cmake")
file(WRITE "${CMAKE_BINARY_DIR}/dxc-revision.txt" "${SOURCE_DXC_REVISION}\n")

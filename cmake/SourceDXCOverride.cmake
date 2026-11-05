# Load STF's NuGet helpers before overriding its packaged DXC.
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(NugetPackages)

function(nuget_get_dxc IN_TARGET OUT_SUCCEEDED OUT_INCLUDE_PATH OUT_BINARY_PATH OUT_LIB_PATH)
    set(${OUT_SUCCEEDED} TRUE PARENT_SCOPE)
    set(${OUT_INCLUDE_PATH} "${SOURCE_DXC_SOURCE_DIR}/include/dxc" PARENT_SCOPE)
    set(${OUT_BINARY_PATH} "${SOURCE_DXC_RUNTIME_DIR}" PARENT_SCOPE)
    set(${OUT_LIB_PATH} "${SOURCE_DXC_BUILD_DIR}/lib" PARENT_SCOPE)
endfunction()

include_guard(GLOBAL)
find_package(Git REQUIRED)

file(MAKE_DIRECTORY "${PROJECT_SOURCE_DIR}/dependencies")
file(LOCK "${PROJECT_SOURCE_DIR}/dependencies/configure.lock" GUARD PROCESS TIMEOUT 120)

# Persistent checkouts must not be deleted when a build tree or CMake version changes.
function(checkout_dependency NAME REPOSITORY REVISION)
    set(source_dir "${PROJECT_SOURCE_DIR}/dependencies/${NAME}")
    if(NOT EXISTS "${source_dir}/.git")
        file(GLOB existing_files "${source_dir}/*")
        if(existing_files)
            message(FATAL_ERROR
                "${source_dir} is not a Git checkout and is not empty. "
                "Move it aside before configuring; it will not be deleted automatically.")
        endif()
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" clone --no-checkout --depth 1
                --config core.longpaths=true "${REPOSITORY}" "${source_dir}"
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif()

    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${source_dir}" rev-parse --verify "${REVISION}^{commit}"
        OUTPUT_VARIABLE revision
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE revision_missing
        ERROR_QUIET
    )
    if(REVISION STREQUAL "main" OR NOT revision_missing EQUAL 0)
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" -C "${source_dir}" fetch --depth 1 origin "${REVISION}"
            COMMAND_ERROR_IS_FATAL ANY
        )
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" -C "${source_dir}" rev-parse FETCH_HEAD
            OUTPUT_VARIABLE revision
            OUTPUT_STRIP_TRAILING_WHITESPACE
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif()
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${source_dir}" checkout --detach "${revision}"
        COMMAND_ERROR_IS_FATAL ANY
    )

    set(${NAME}_SOURCE_DIR "${source_dir}" PARENT_SCOPE)
    set(${NAME}_BINARY_DIR "${CMAKE_BINARY_DIR}/_deps/${NAME}-build" PARENT_SCOPE)
endfunction()

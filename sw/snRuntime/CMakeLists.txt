# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.13)

# Allow snRuntime to be built as a standalone library.
if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    # Read SnitchUtilities
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)
    include(SnitchUtilities)
    # Create snRuntime project
    project(snRuntime LANGUAGES C ASM)
    add_compile_options(-O3 -g -ffunction-sections)
else()
    # Export package information to includer.
    set(SNRUNTIME_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
    set(SNRUNTIME_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR} PARENT_SCOPE)
    set(SNRUNTIME_INCLUDE_DIRS
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/vendor
        PARENT_SCOPE)
endif()

# Default memory regions
if(SNITCH_RUNTIME STREQUAL "snRuntime-cluster")
    set(MEM_DRAM_ORIGIN "0x80000000" CACHE STRING "Base address of external memory")
    set(MEM_DRAM_SIZE "0x80000000" CACHE STRING "Size of external memory")
else()
    set(MEM_DRAM_ORIGIN "0x80000000" CACHE STRING "Base address of external memory")
    set(MEM_DRAM_SIZE "256M" CACHE STRING "Size of external memory")
endif()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/link/common.ld.in common.ld @ONLY)
set(LINKER_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/common.ld CACHE PATH "")

# provide linker script
# set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link/common.ld" CACHE PATH "")
message(STATUS "Using common linker script: ${LINKER_SCRIPT}")
# set(TARGET_LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/link/banshee.ld" CACHE FILEPATH "Linker Script")
# message(STATUS "Using target linker script: ${TARGET_LINKER_SCRIPT}")

if(RUNTIME_TRACE)
    # Enable runtime tracing
    add_compile_definitions(__SNRT_USE_TRACE)
endif()

include_directories(include vendor)

# Common sources
set(sources
    src/barrier.c
    src/dma.c
    src/memcpy.c
    src/printf.c
    src/team.c
    src/ssr.c
    src/alloc.c
)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    # Build all runtimes

    # Generic Runtime (requiring bootloader/OS)
    add_snitch_library(snRuntime src/start.S ${sources} src/ssr_v2.c)

    # Bare Runtimes (with startup code)
    add_snitch_library(snRuntime-banshee src/start_banshee.S src/start_banshee.c ${sources} src/ssr_v1.c)
    add_snitch_library(snRuntime-cluster src/start_cluster.S src/start_cluster.c ${sources} src/ssr_v2.c)
    add_snitch_library(snRuntime-billywig src/start_billywig.S ${sources} src/ssr_v1.c)
    add_snitch_library(snRuntime-bowtruckle src/start_bowtruckle.S ${sources} src/ssr_v1.c)
    add_snitch_library(snRuntime-lethifold src/start_lethifold.S ${sources} src/ssr_v1.c)
    add_snitch_library(snRuntime-thestral src/start_thestral.S ${sources} src/ssr_v1.c)

else()
    # snRuntime is added externally, only build required runtime
    if(SNITCH_RUNTIME STREQUAL "snRuntime")
        # Generic Runtime (requiring bootloader/OS)
        add_snitch_library(snRuntime src/start.S ${sources} src/ssr_v2.c)
    # Bare Runtimes (with startup code)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-banshee")
        add_snitch_library(snRuntime-banshee src/start_banshee.S src/start_banshee.c ${sources} src/ssr_v1.c)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-cluster")
        add_snitch_library(snRuntime-cluster src/start_cluster.S src/start_cluster.c ${sources} src/ssr_v2.c)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-billywig")
        add_snitch_library(snRuntime-billywig src/start_billywig.S ${sources} src/ssr_v1.c)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-bowtruckle")
        add_snitch_library(snRuntime-bowtruckle src/start_bowtruckle.S ${sources} src/ssr_v1.c)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-lethifold")
        add_snitch_library(snRuntime-lethifold src/start_lethifold.S ${sources} src/ssr_v1.c)
    elseif(SNITCH_RUNTIME STREQUAL "snRuntime-thestral")
        add_snitch_library(snRuntime-thestral src/start_thestral.S ${sources} src/ssr_v1.c)
    else()
        message(FATAL_ERROR "Requested runtime not implemented: ${SNITCH_RUNTIME}")
    endif()
endif()

# Tests
enable_testing()
set(SNITCH_TEST_PREFIX snRuntime-)
add_snitch_test(tls tests/tls.c)
add_snitch_test(simple tests/simple.c)
add_snitch_test(varargs_1 tests/varargs_1.c)
add_snitch_test(varargs_2 tests/varargs_2.c)
add_snitch_test(barrier tests/barrier.c)
add_snitch_test(lto tests/lto.c tests/lto_a.c)

add_snitch_test_executable(dma_simple tests/dma_simple.c)
add_snitch_test_executable(printf_simple tests/printf_simple.c)
add_snitch_test_executable(printf_fmtint tests/printf_fmtint.c)
add_snitch_test_executable(multi_cluster tests/multi_cluster.c)
add_snitch_test_rtl(dma_simple)
add_snitch_test_rtl(printf_simple)
add_snitch_test_rtl(printf_fmtint)
add_snitch_test_args(printf_simple printf_simple --no-opt-llvm --base-hartid=3)
add_snitch_test_args(printf_fmtint printf_fmtint-core --no-opt-llvm --base-hartid=3)
add_snitch_test_args(printf_fmtint printf_fmtint-cluster --no-opt-llvm --base-hartid=3 --num-cores=8)
add_snitch_test_args(printf_fmtint printf_fmtint-system --no-opt-llvm --base-hartid=3 --num-cores=8 --num-clusters=4)

add_snitch_test_executable(team_global tests/team_global.c)
add_snitch_test_rtl(team_global)
add_snitch_test_args(team_global team_global --base-hartid=3 --num-cores=4 --num-clusters=2)

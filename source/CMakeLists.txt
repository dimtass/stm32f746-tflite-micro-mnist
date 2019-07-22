# Author: Dimitris Tassopoulos <dimtass@gmail.com>

cmake_minimum_required(VERSION 3.6)

project(stm32f7-mnist-tflite LANGUAGES C CXX)

option(USE_CORTEX_NN "Use Cortex-M7 DSP/NN lib" OFF)
option(USE_HAL_DRIVER "Use HAL Driver library" OFF)
option(USE_FREERTOS "Use FreeRTOS" OFF)
option(USE_OVERCLOCK "Overclock the STM7" OFF)

# set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} ")
# find_library(ARM_MATH_LIB arm_cortexM7lfsp_math HINT ${CMAKE_SOURCE_DIR}/libs/CMSIS/DSP/Lib/GCC)
# message(STATUS "ARM_MATH_LIB: ${ARM_MATH_LIB}\n")

set(DEVICE_CONFIG_DIR ${CMAKE_SOURCE_DIR}/libs/CMSIS/Device/ST/STM32F7xx)

# Include toolchain (toolchain path )
include(cmake/TOOLCHAIN_arm_none_eabi_cortex_m7.cmake)
# If the toolchain path is not set in the build scsript then add it here${DEVICE_CONFIG_DIR}
# or in the toolchain cmake file
# set(TOOLCHAIN_DIR "/opt/toolchains/gcc-arm-none-eabi-8-2018-q4-major")

# Define the hardware
set(OTHER_SRC_FILES "${DEVICE_CONFIG_DIR}/system_stm32f7xx.c")

# Set STM32 SoC specific variables
set(STM32F7_DEFINES " \
    -DIVECT_TAB_OFFSET=0x0 \
    -DSTM32F746xx \
    ")

if (USE_OVERCLOCK)
    set(STM32F7_DEFINES "${STM32F7_DEFINES} -DOVERCLOCK")
endif()

# set compiler optimisations
set(COMPILER_OPTIMISATION "-g -O3")

# add startup and linker file
set(STARTUP_ASM_FILE "${CMAKE_SOURCE_DIR}/config/startup/startup_stm32f746xx.s")
set_property(SOURCE ${STARTUP_ASM_FILE} PROPERTY LANGUAGE ASM)
set(LINKER_FILE "${CMAKE_SOURCE_DIR}/STM32F746NGHX_FLASH.ld")

# Only build for arm-none-eabi
if (NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "arm-none-eabi")
    message(FATAL_ERROR "Invalid CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

if (USE_CORTEX_NN)
    set(STM32F7_DEFINES "${STM32F7_DEFINES} -DARM_MATH_DSP")
    include(cmake/cmsis_dsp_lib.cmake)
    include(cmake/cmsis_nn_lib.cmake)
endif()
# include(libs/CMSIS/DSP/Source/configDsp.cmake)

# CMSIS shared library
# HAL Driver shared library
if (USE_HAL_DRIVER)
    include(cmake/stm32f7_hal_driver.cmake)
endif()

# FreeRTOS Library
if (USE_FREERTOS)
    include(cmake/freertos.cmake)
endif()

include (cmake/tensorflow_lite_micro.cmake)

# Add the arch independent C lib
include (cmake/noarch_c_lib.cmake)

# force stm builds to debug.  This is a hack as when release is set, it automatically 
# sets the invalid -O3 flag on the assembler.
set(CMAKE_BUILD_TYPE Debug)

# Resolve the issue with Eclipse's indexer and C/C++ mixed source files
include(cmake/language_provider.cmake)
remove_from_SYSTEM_MACROS(CXX "__cplusplus;.*;")
create_language_provider("${CMAKE_BINARY_DIR}/.settings" "${GCC_PREFIX}-" "${CXX_STANDARD_FLAG}")

# enable asm for stm startup.s file
enable_language(ASM)

## Override toolchain flags ##
# CFLAGS
set (CMAKE_C_FLAGS "-g -mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -larm_cortexM7lfdp_math -lc -lnosys --specs=nosys.specs -DUSE_HAL_DRIVER -DSTM32F746xx")
# CXXFLAGS
set (CMAKE_CXX_FLAGS "-g -mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-rtti -s")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -lm -lc -lnosys --specs=nosys.specs")

# ASMFLAGS
set (CMAKE_ASM_FLAGS "-g -mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp" CACHE INTERNAL "asm compiler flags")
# LDFLAGS
set (CMAKE_EXE_LINKER_FLAGS "-g -Wl,--gc-sections -mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T ${LINKER_FILE}")

message(STATUS "System Processor      : ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS
    "BUILD FLAGS:\n"
    "   c flags         : ${CMAKE_C_FLAGS}\n"
    "   c++ flags       : ${CMAKE_CXX_FLAGS}\n"
    "   asm flags       : ${CMAKE_ASM_FLAGS}\n"
    "   ld flags        : ${CMAKE_EXE_LINKER_FLAGS}\n"
    "   optimizations   : ${COMPILER_OPTIMISATION}\n"
    "   CMSIS           : ${CMSIS_DIR}\n"
    "   HAL library     : ${STDPERIPHSTM32F7_HAL_DRIVER_DIR_DIR}\n"
    "   FreeRTOS        : ${FREERTOS_INC_DIR}\n"
)


# add the source code directory
add_subdirectory(${SRC})

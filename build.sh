#!/bin/bash -e

# Usage examples: 
# $ ./build.sh src_cpp
# $ CLEANBUILD=true ./build.sh src_cpp
# $ CLEANBUILD=true USE_HAL_DRIVER=ON ./build.sh src_cpp_hal
# $ CLEANBUILD=true USE_HAL_DRIVER=ON USE_FREERTOS=ON ./build.sh src_cpp_freertos

echo "Building the project in Linux environment"

# Toolchain path
: ${TOOLCHAIN_DIR:="/opt/toolchains/gcc-arm-none-eabi-9-2019-q4-major"}
# select cmake toolchain
: ${CMAKE_TOOLCHAIN:=TOOLCHAIN_arm_none_eabi_cortex_m7.cmake}
# select to clean previous builds
: ${CLEANBUILD:=false}
# select to create eclipse project files
: ${ECLIPSE_IDE:=false}
# Select DSP/NN lib use
: ${USE_CMSIS_NN:="OFF"}
# Select compressed/uncompressed model use
: ${USE_COMP_MODEL:="OFF"}
# Select HAL/LL lib use
: ${USE_HAL_DRIVER:="OFF"}
# Select Stdperiph lib use
: ${USE_FREERTOS:="OFF"}
# Use overclock
: ${USE_OVERCLOCK:="OFF"}
# Select source folder. Give a false one to trigger an error
: ${SRC:="__"}

# Set default arch to stm32
ARCHITECTURE=stm32
# default generator
IDE_GENERATOR="Unix Makefiles"
# Current working directory
WORKING_DIR=$(pwd)
# cmake scripts folder
SCRIPTS_CMAKE="${WORKING_DIR}/source/cmake"
# Compile objects in parallel, the -jN flag in make
PARALLEL=$(expr $(getconf _NPROCESSORS_ONLN) + 1)

if [ ! -d "source/${SRC}" ]; then
    echo -e "You need to specify the SRC parameter to point to the source code"
    exit 1
fi

if [ "${ECLIPSE}" == "true" ]; then
	IDE_GENERATOR="Eclipse CDT4 - Unix Makefiles" 
fi

BUILD_ARCH_DIR=${WORKING_DIR}/build-${ARCHITECTURE}

if [ "${ARCHITECTURE}" == "stm32" ]; then
    CMAKE_FLAGS="${CMAKE_FLAGS} \
                -DTOOLCHAIN_DIR=${TOOLCHAIN_DIR} \
                -DCMAKE_TOOLCHAIN_FILE=${SCRIPTS_CMAKE}/${CMAKE_TOOLCHAIN} \
                -DUSE_CMSIS_NN=${USE_CMSIS_NN} \
                -DUSE_HAL_DRIVER=${USE_HAL_DRIVER} \
                -DUSE_FREERTOS=${USE_FREERTOS} \
                -DUSE_OVERCLOCK=${USE_OVERCLOCK} \
                -DUSE_COMP_MODEL=${USE_COMP_MODEL} \
                -DSRC=${SRC} \
                "
else
    >&2 echo "*** Error: Architecture '${ARCHITECTURE}' unknown."
    exit 1
fi

if [ "${CLEANBUILD}" == "true" ]; then
    echo "- removing build directory: ${BUILD_ARCH_DIR}"
    rm -rf ${BUILD_ARCH_DIR}
fi

echo "--- Pre-cmake ---"
echo "architecture      : ${ARCHITECTURE}"
echo "distclean         : ${CLEANBUILD}"
echo "parallel          : ${PARALLEL}"
echo "cmake flags       : ${CMAKE_FLAGS}"
echo "cmake scripts     : ${SCRIPTS_CMAKE}"
echo "IDE generator     : ${IDE_GENERATOR}"
echo "Threads           : ${PARALLEL}"
echo "USE_OVERCLOCK     : ${USE_OVERCLOCK}"
echo "USE_CMSIS_NN      : ${USE_CMSIS_NN}"
echo "USE_COMP_MODEL    : ${USE_COMP_MODEL}"

mkdir -p build-stm32
cd build-stm32

# setup cmake
cmake ../source -G"${IDE_GENERATOR}" ${CMAKE_FLAGS}

# build
make -j${PARALLEL} --no-print-directory

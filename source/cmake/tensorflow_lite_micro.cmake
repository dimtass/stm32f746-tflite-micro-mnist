set(TENSORFLOW_LITE_DIR ${CMAKE_SOURCE_DIR}/libs/tensorflow)

# Make sure that git submodule is initialized and updated
if (NOT EXISTS "${TENSORFLOW_LITE_DIR}")
  message(FATAL_ERROR "Tensorflow-lite submodule not found. Initialize with 'git submodule update --init' in the source directory")
endif()

set (TENSORFLOW_LITE_INC
    ${TENSORFLOW_LITE_DIR}/lite/flatbuffers/include/flatbuffers
    ${TENSORFLOW_LITE_DIR}/lite/fixedpoint/fixedpoint
    ${TENSORFLOW_LITE_DIR}/lite/fixedpoint

    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/reference/integer_ops
    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/reference
    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/optimized
    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal
    ${TENSORFLOW_LITE_DIR}/lite/kernels
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/testing
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro
    ${TENSORFLOW_LITE_DIR}/lite/experimental
    ${TENSORFLOW_LITE_DIR}/lite/core
    ${TENSORFLOW_LITE_DIR}/lite/c
    ${TENSORFLOW_LITE_DIR}/lite/schema
    ${TENSORFLOW_LITE_DIR}/lite
)

include_directories(
    ${TENSORFLOW_LITE_INC}
)

aux_source_directory(${TENSORFLOW_LITE_DIR}/lite/flatbuffers/src FLATBUFFERS_SRC)

if (USE_CMSIS_NN)
  set(TENSORFLOW_LITE_SRC
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/cmsis-nn/depthwise_conv.cc
  )
else()
  set(TENSORFLOW_LITE_SRC
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/depthwise_conv.cc
    # ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/portable_optimized/depthwise_conv.cc
  )
endif()

# Get all source files from the Src directory
set(TENSORFLOW_LITE_SRC
    ${TENSORFLOW_LITE_SRC}
    ${TENSORFLOW_LITE_DIR}/lite/c/c_api_internal.c
    ${TENSORFLOW_LITE_DIR}/lite/core/api/error_reporter.cc
    ${TENSORFLOW_LITE_DIR}/lite/core/api/flatbuffer_conversions.cc
    ${TENSORFLOW_LITE_DIR}/lite/core/api/op_resolver.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/debug_log.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/debug_log_numbers.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/all_ops_resolver.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/conv.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/elementwise.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/fully_connected.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/pooling.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/softmax.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/micro_error_reporter.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/micro_interpreter.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/micro_mutable_op_resolver.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/simple_tensor_allocator.cc
    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/quantization_util.cc
    ${TENSORFLOW_LITE_DIR}/lite/kernels/kernel_util.cc
    ${FLATBUFFERS_SRC}
)

add_library(Tensorflow_lite_micro STATIC ${TENSORFLOW_LITE_SRC})
target_link_libraries(Tensorflow_lite_micro
  ${EXTERNAL_LIBS}
)

set_target_properties(Tensorflow_lite_micro PROPERTIES LINKER_LANGUAGE CXX)

set(EXTERNAL_EXECUTABLES ${EXTERNAL_EXECUTABLES} ${STARTUP_ASM_FILE})

set(EXTERNAL_LIBS ${EXTERNAL_LIBS} Tensorflow_lite_micro)

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

if (USE_CORTEX_NN)
  set(TENSORFLOW_LITE_SRC
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/cmsis-nn/depthwise_conv.cc
  )
else()
  set(TENSORFLOW_LITE_SRC
    # ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/depthwise_conv.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/portable_optimized/depthwise_conv.cc
  )
endif()

# Get all source files from the Src directory
set(TENSORFLOW_LITE_SRC
    ${TENSORFLOW_LITE_SRC}
    ${TENSORFLOW_LITE_DIR}/lite/c/c_api_internal.c
    ${TENSORFLOW_LITE_DIR}/lite/core/api/error_reporter.cc
    ${TENSORFLOW_LITE_DIR}/lite/core/api/flatbuffer_conversions.cc
    ${TENSORFLOW_LITE_DIR}/lite/core/api/op_resolver.cc
    # ${TENSORFLOW_LITE_DIR}/lite/core/subgraph.cc
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
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/activations.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/add.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/add_n.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/arg_min_max.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/audio_spectrogram.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/basic_rnn.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/batch_to_space_nd.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/bidirectional_sequence_lstm.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/bidirectional_sequence_rnn.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/cast.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/ceil.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/comparisons.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/concatenation.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/conv.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/cpu_backend_context.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/cpu_backend_gemm_eigen.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/cpu_backend_support.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/depthwise_conv.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/dequantize.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/detection_postprocess.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/div.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/eigen_support.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/elementwise.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/embedding_lookup.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/embedding_lookup_sparse.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/expand_dims.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/exp.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/fake_quant.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/fill.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/floor.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/floor_div.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/floor_mod.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/fully_connected.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/gather.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/gather_nd.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/gemmlowp_support.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/hashtable_lookup.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/if.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/kernel_utils.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/mfcc.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/mfcc_dct.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/mfcc_mel_filterbank.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/optimized/neon_tensor_utils.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/optimized/sse_tensor_utils.cc
    ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/quantization_util.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/reference/portable_tensor_utils.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/spectrogram.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/tensor_utils.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/internal/test_util.cc
    ${TENSORFLOW_LITE_DIR}/lite/kernels/kernel_util.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/l2norm.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/local_response_norm.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/logical.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/lsh_projection.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/lstm.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/lstm_eval.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/matrix_diag.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/matrix_set_diag.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/maximum_minimum.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/mfcc.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/mirror_pad.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/mul.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/neg.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/one_hot.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/pack.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/pad.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/pooling.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/pow.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/quantize.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/range.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/rank.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/reduce.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/register.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/register_ref.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/reshape.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/resize_bilinear.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/resize_nearest_neighbor.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/reverse.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/reverse_sequence.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/rfft2d.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/round.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/select.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/shape.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/skip_gram.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/slice.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/space_to_batch_nd.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/space_to_depth.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/sparse_to_dense.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/split.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/split_v.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/squared_difference.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/squeeze.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/strided_slice.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/sub.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/subgraph_test_util.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/svdf.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/test_util.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/tile.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/topk_v2.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/transpose.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/transpose_conv.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/unidirectional_sequence_lstm.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/unidirectional_sequence_rnn.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/unique.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/unpack.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/where.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/while.cc
    # ${TENSORFLOW_LITE_DIR}/lite/kernels/zeros_like.cc
    ${FLATBUFFERS_SRC}
)

# set_source_files_properties(${TENSORFLOW_LITE_SRC}
#     PROPERTIES COMPILE_FLAGS "${STM32F7_DEFINES} -Wno-fpermissive"
# )



add_library(Tensorflow_lite_micro STATIC ${TENSORFLOW_LITE_SRC})
target_link_libraries(Tensorflow_lite_micro
  ${EXTERNAL_LIBS}
)

set_target_properties(Tensorflow_lite_micro PROPERTIES LINKER_LANGUAGE CXX)

set(EXTERNAL_EXECUTABLES ${EXTERNAL_EXECUTABLES} ${STARTUP_ASM_FILE})

set(EXTERNAL_LIBS ${EXTERNAL_LIBS} Tensorflow_lite_micro)

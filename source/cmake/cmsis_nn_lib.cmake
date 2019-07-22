set(STM32F7_NN_LIB_DIR ${CMAKE_SOURCE_DIR}/libs/CMSIS/NN)

# Make sure the lib is there
if (NOT EXISTS "${STM32F7_NN_LIB_DIR}")
  message(FATAL_ERROR "STM32F7_NN_LIB_DIR not found.")
endif()

include_directories(
    ${CMSIS_DIR}/DSP/Include
    ${CMSIS_DIR}/NN/Include
)

# Get all source files from the Source directory
set(STM32F7_NN_LIB_SRC
        ${STM32F7_NN_LIB_DIR}/Source/ActivationFunctions/arm_relu_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/ActivationFunctions/arm_relu_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/ActivationFunctions/arm_nn_activations_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/ActivationFunctions/arm_nn_activations_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q15_fast.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q7_basic_nonsquare.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_depthwise_separable_conv_HWC_q7_nonsquare.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_depthwise_conv_u8_basic_ver1.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_q7_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_q7_q15_reordered.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_1x1_HWC_q7_fast_nonsquare.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast_nonsquare.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_depthwise_separable_conv_HWC_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q15_fast_nonsquare.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q7_basic.c
        ${STM32F7_NN_LIB_DIR}/Source/ConvolutionFunctions/arm_convolve_HWC_q15_basic.c
        ${STM32F7_NN_LIB_DIR}/Source/NNSupportFunctions/arm_nn_mult_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/NNSupportFunctions/arm_nntables.c
        ${STM32F7_NN_LIB_DIR}/Source/NNSupportFunctions/arm_nn_mult_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/NNSupportFunctions/arm_q7_to_q15_reordered_no_shift.c
        ${STM32F7_NN_LIB_DIR}/Source/NNSupportFunctions/arm_q7_to_q15_no_shift.c
        ${STM32F7_NN_LIB_DIR}/Source/PoolingFunctions/arm_pool_q7_HWC.c
        ${STM32F7_NN_LIB_DIR}/Source/SoftmaxFunctions/arm_softmax_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/SoftmaxFunctions/arm_softmax_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_q7.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_s8.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_q15_opt.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_q15.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_mat_q7_vec_q15_opt.c
        ${STM32F7_NN_LIB_DIR}/Source/FullyConnectedFunctions/arm_fully_connected_mat_q7_vec_q15.c
)

set_source_files_properties(${STM32F7_NN_LIB_SRC}
    PROPERTIES COMPILE_FLAGS ${STM32F7_DEFINES}
)

add_library(STM32F7_NN_Lib STATIC ${STM32F7_NN_LIB_SRC})
set_target_properties(STM32F7_NN_Lib PROPERTIES LINKER_LANGUAGE C)

set(EXTERNAL_EXECUTABLES ${EXTERNAL_EXECUTABLES} ${STARTUP_ASM_FILE})

set(EXTERNAL_LIBS ${EXTERNAL_LIBS} STM32F7_NN_Lib)
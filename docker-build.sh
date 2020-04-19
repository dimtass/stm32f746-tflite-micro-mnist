#!/bin/bash -e
#
# Example:
#   ./docker-build.sh "CLEANBUILD=true USE_HAL_DRIVER=ON USE_OVERCLOCK=OFF USE_CMSIS_NN=OFF SRC=src ./build.sh"

docker run --rm -it -v $(pwd):/tmp/tflite -w=/tmp/tflite dimtass/stm32-cde-image:0.1 -c "${1}"
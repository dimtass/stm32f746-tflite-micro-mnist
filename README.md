MNIST inference on STM32F746 using TensorFlow Lite for Microcontrollers
----

In this project you can evaluate the MNIST database or your hand-written
digits (using the included jupyter notebook) on the STM32F746.
This example is tested on the [STM32F7 discovery](https://www.st.com/en/evaluation-tools/32f746gdiscovery.html)
kit. If you have another one then you need to do the appropriate
changes that are needed.

The base project is derived from my CMAKE template for the STM32F7xx
[here](https://bitbucket.org/dimtass/stm32f7xx_cmake_template).

> Note: This project derived from this blog post [here](https://www.stupid-projects.com/machine-learning-on-embedded-part-3/)
The whole series starts from [here](https://www.stupid-projects.com/machine-learning-on-embedded-part-1/)

## Usage
First you need to build and upload the project on the stm32f7.
To do that follow the instructions in the build section. After
that you can use the jupyter notebook to hand-draw a digit and
then upload the digit on the stm32f7 and get the prediction back.
Please follow the guide inside the notebook.

In order to run the notebook, you need python3, tensorflow and
PySerial. I've used Ubuntu 18.04 and miniconda, but conda is not
really needed. In any case it's good to run the following commads
on a virtual environment.

Example for conda
```sh
conda create -n stm32f7-nn-env python
conda activate stm32f7-nn-env
conda install -c conda-forge numpy
conda install -c conda-forge jupyter
conda install -c conda-forge tensorflow-gpu
jupyter notebook
```

And then browse to the `jupyter_notebook/MNIST-TensorFlow.ipynb`
and run/use the notebook.

## Build

To select the which libraries you want to use you need to provide
cmake with the proper options. By default all the options are set
to `OFF`. The supported options are:

* `USE_CORTEX_NN`: If set to `ON` then the project will build using the DSP/NN libs
* `USE_HAL_DRIVER`: If set to `ON` enables the HAL Driver library
* `USE_FREERTOS`: If set to `ON` enables FreeRTOS

You also need to provide cmake with the source folder by pointing
the folder to the `SRC` parameter.

Finally, you also need to provide the path of the toolchain to
use in the `CMAKE_TOOLCHAIN`.

You can build 3 different version of this code. The one is use the
default `depthwise_conv` function, the other is to build the `portable_optimized`
version and last to build the `cmsis-nn` version. For the first two,
you have to select the proper version inside the `cmake/tensorflow_lite_micro.cmake`
file, where you'll see the following lines:

```cmake
set(TENSORFLOW_LITE_SRC
    # ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/depthwise_conv.cc
    ${TENSORFLOW_LITE_DIR}/lite/experimental/micro/kernels/portable_optimized/depthwise_conv.cc
)
```

By default, the `portable_optimized` version is selected, but you can comment
that line and uncomment the other one. Then you can build with the
following command:

```sh
CLEANBUILD=true USE_HAL_DRIVER=ON SRC=src ./build.sh
```

To build the binary using the Cortex-M and NN libs, then you need
to run the following command:

```sh\
CLEANBUILD=true USE_HAL_DRIVER=ON USE_CORTEX_NN=ON SRC=src ./build.sh
```

> Note: `CLEANBUILD=true` is only needed if you need to make a clean build
otherwise you can skip it. When it's used then depending on your machine
it will take quite some time as I'm building all the DSP and NN libs files.
To make it a bit faster you can remove the files that are not needed in
`cmake/cmsis_dsp_lib.cmake`.

## Overclocking
I've added an overclocking flag that overclocks the CPU @ 280. That's maybe
too high for every available CPU, but also yours can be clocked even higher. To
control the overclocking amount then in the `source/src/main.cpp` you'll find these
lines here:

```cpp
#ifdef OVERCLOCK
    RCC_OscInitStruct.PLL.PLLN = 288; // Overclock
#endif
```

You can change that number to the frequency you like. Then you need to build
with the `USE_OVERCLOCK" flag, like this:
```sh
CLEANBUILD=true USE_OVERCLOCK=ON USE_HAL_DRIVER=ON USE_CORTEX_NN=ON SRC=src ./build.sh
```

> Warning: Any overclocking may be the source of unknown issues you may have.
In my case I was able to OC up to 285MHz, but sometimes the flatbuffers API was
failing at that high frequency! Especially avoid developing with OC.

## Using CubeMX
Usually is more convenient to create your project with CubeMX,
then after you setup all the hardware and peripherals you can create
the code (I prefer `SW4STM32`, but it doens't really matter in this case).
Then after the code is exported then you just need to copy the files
that CubeMX customizes for your setup.

The files that usually you need to get and place them in your
`source/src` folder are:

* main.h
* main.c
* stm32f7xx_hal_conf.h
* stm32f7xx_hal_msp.c
* stm32f7xx_it.h
* stm32f7xx_it.c
* system_stm32f7xx.c (in case you have custom clocks)

In your case there might be more files. Usually are the files
that are in the exported `Inc` and `Src` folder.


## Cloning the code
Because this repo has dependencies on other submodules, in order to
fetch the repo use the following command:

```sh
git clone --recursive -j8 git@bitbucket.org:dimtass/stm32f746-tflite-micro-mnist.git

# or for http
git clone --recursive -j8 https://dimtass@bitbucket.org/dimtass/stm32f746-tflite-micro-mnist.git
```

## Flash
To flash the HEX file in windows use st-link utility like this:
```"C:\Program Files (x86)\STMicroelectronics\STM32 ST-LINK Utility\ST-LINK Utility\ST-LINK_CLI.exe" -c SWD -p build-stm32\src_\stm32-cmake-template.hex -Rst```

To flash the bin in Linux:
```st-flash --reset write build-stm32/src/stm32-cmake-template.bin 0x8000000```

Just replace `src` with the proper folder in your case

## Testing
I've also added a script to test the current supported default projects.
To use it just run:

```sh
./test.sh
```

If everything goes right you should see something like this:

```sh
Building test case: CLEANBUILD=true USE_HAL_DRIVER=ON SRC=src_c_hal
---RESULT: SUCCESS

Building test case: CLEANBUILD=true USE_HAL_DRIVER=ON USE_FREERTOS=ON SRC=src_c_freertos
---RESULT: SUCCESS

Building test case: CLEANBUILD=true USE_HAL_DRIVER=ON SRC=src_cpp_hal
---RESULT: SUCCESS

Building test case: CLEANBUILD=true USE_HAL_DRIVER=ON USE_FREERTOS=ON SRC=src_cpp_freertos
---RESULT: SUCCESS
```

## Flatbuffers
You might need to use Google's flatbuffers in case you want to experiment
with the serial commands from the python notebook to the stm32f7. These
are the commands if you want to build flatbuffers from source and install
them (I've used Ubuntu 18.04).

```sh
git clone https://github.com/google/flatbuffers.git
cd flatbuffers
cmake -G "Unix Makefiles"
make -j8
sudo make install
```

The `schema` file is located in `source/schema`. To build it then run:
```sh
source/schema/create-header.sh
```

The Python serial port client is in the `jupyter_notebook/STM32F7Comm` folder.
In order to build the schema for Python, run:
```sh
flatc --python -o jupyter_notebook/STM32F7Comm ./source/schema/schema.fbs
```

## FW details
* `CMSIS version`: 5.0.4
* `CMSIS-NN version`: V.1.0.0
* `CMSIS-DSP version`: V1.6.0
* `HAL Driver Library version`: 1.2.6


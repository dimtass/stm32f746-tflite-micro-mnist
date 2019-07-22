#!/bin/bash -e

# You don't need a makefile for a one-liner...

echo "Build FbComm test tool..."
g++ -o fb_comm_test fb_comm_test.cpp -I../../../source/libs/flatbuffers/include/flatbuffers/ -I../../../source/src/inc
echo "Done. Now you can run ./fb_comm_test"

#!/bin/bash -e

# Format file
echo "Formating $1..."
clang-format -i -style="{BasedOnStyle: llvm, ColumnLimit: 120, IndentWidth: 4, Standard: Cpp11, PointerBindsToType: false, BreakBeforeBraces: Linux, BreakConstructorInitializersBeforeComma: true, AccessModifierOffset: -4, BreakBeforeBinaryOperators: true}" $1

include(ExternalProject)

if ( NOT LLVM_DIR )

ExternalProject_Add(epic-llvm
    URL https://github.com/lowRISC/llvm-project/archive/refs/heads/epic.zip
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/llvm
    CMAKE_ARGS 
        ${CMAKE_CURRENT_BINARY_DIR}/llvm/src/epic-llvm/llvm
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_SHARED_LIBS=True
        -DLLVM_USE_SPLIT_DWARF=True
        -DLLVM_BUILD_TESTS=False
        -DCMAKE_C_COMPILER=clang
        -DCMAKE_CXX_COMPILER=clang++
        -DLLVM_ENABLE_LLD=True
        -DLLVM_APPEND_VC_REV=False
        -DLLVM_TARGETS_TO_BUILD=RISCV
        -DLLVM_ENABLE_PROJECTS=clang$<SEMICOLON>lld
        -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/install
    USES_TERMINAL_CONFIGURE true
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
)
set(LLVM_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)

else()

add_custom_target(epic-llvm)

endif()
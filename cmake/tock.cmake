set(LIBTOCK_RS_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/libtock-rs)
set(TOCK_ROOT ${LIBTOCK_RS_ROOT}/tock)

set(LIBTOCK_RS_BUILD ${CMAKE_CURRENT_BINARY_DIR}/libtock-rs)
set(LIBTOCK_RS_TARGET ${LIBTOCK_RS_BUILD}/target)

set(TOCK_BUILD ${CMAKE_CURRENT_BINARY_DIR}/tock)
set(TOCK_TARGET ${TOCK_BUILD}/target)

include(cmake/tock/utils.cmake)

# qemu
add_custom_target(qemu ALL DEPENDS ${TOCK_BUILD}/tools/qemu)
add_custom_command(OUTPUT ${TOCK_BUILD}/tools/qemu
    COMMAND mkdir -p ${TOCK_BUILD}/tools/qemu-runner
    COMMAND make -f ${TOCK_ROOT}/Makefile  CI=true ci-setup-qemu
    WORKING_DIRECTORY ${TOCK_BUILD}
    USES_TERMINAL
)

# elf2tab
add_custom_target(elf2tab ALL DEPENDS ${CARGO_HOME}/bin/elf2tab)
add_custom_command(OUTPUT ${CARGO_HOME}/bin/elf2tab
    COMMAND ${RUSTUP} cargo install --git https://github.com/jprendes/elf2tab.git --branch rela_lld
    USES_TERMINAL
)
add_dependencies(elf2tab rustup)

# runner
add_custom_target(runner ALL DEPENDS ${CARGO_HOME}/bin/runner)
add_custom_command(OUTPUT ${CARGO_HOME}/bin/runner
    COMMAND ${RUSTUP} cargo install --path ${LIBTOCK_RS_ROOT}/runner
    USES_TERMINAL
)
add_dependencies(runner rustup)

# kernels
function(add_kernel BOARD_VARIANT)
    parse_board_variant(${BOARD_VARIANT})
    set(${IDENTIFIER}_TARGET ${TARGET} PARENT_SCOPE)

    set(KERNEL_ELF ${TOCK_TARGET}/${TARGET}/release/${VARIANT}.elf)

    add_custom_target(kernel-${IDENTIFIER} ALL DEPENDS ${KERNEL_ELF})
    add_custom_command(OUTPUT ${KERNEL_ELF}
        COMMAND ${RUSTUP}
            CARGO_TARGET_RISCV32IMC_UNKNOWN_NONE_ELF_RUNNER=[]
            TARGET_DIRECTORY=${TOCK_TARGET}/
            make -C boards/${BOARD_VARIANT} ${KERNEL_ELF}
        WORKING_DIRECTORY ${TOCK_ROOT}
        USES_TERMINAL
    )
    add_dependencies(kernel-${IDENTIFIER} rustup)
endfunction()

# examples
function(add_epic_tock_example EXAMPLE BOARD_VARIANT)
    parse_board_variant(${BOARD_VARIANT})

    # For some reason things don't work with "riscv32imc" from opentitan, but does with "riscv32imac"
    set(TARGET riscv32imac-unknown-none-elf)

    string(MAKE_C_IDENTIFIER ${TARGET} TARGET_UPPER)
    string(TOUPPER ${TARGET_UPPER} TARGET_UPPER)

    set(EXAMPLE_ELF ${LIBTOCK_RS_TARGET}/${BOARD_VARIANT}/${TARGET}/release/examples/${EXAMPLE})

    add_custom_target(${EXAMPLE}-${IDENTIFIER} ALL DEPENDS ${EXAMPLE_ELF})
    add_custom_command(OUTPUT ${EXAMPLE_ELF}
        COMMAND ${RUSTUP}
            CARGO_BUILD_TARGET_DIR=${LIBTOCK_RS_TARGET}/${BOARD_VARIANT}
            RUSTUP_TOOLCHAIN=epic
            CARGO_TARGET_${TARGET_UPPER}_LINKER=${LLVM_DIR}/bin/ld.lld
            LIBTOCK_PLATFORM=${BOARD}
            cargo build -Zbuild-std=core --example console -p libtock2 --release --target=${TARGET}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/libtock-rs
        USES_TERMINAL
    )
    add_dependencies(${EXAMPLE}-${IDENTIFIER} rustup elf2tab epic-rust kernel-${IDENTIFIER})

    add_custom_target(run-${EXAMPLE}-${IDENTIFIER}
        COMMAND ${RUSTUP} LIBTOCK_PLATFORM=${BOARD} runner ${EXAMPLE_ELF} --deploy qemu --verbose
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        USES_TERMINAL
    )
endfunction()
include(ExternalProject)

add_custom_target(epic-rust DEPENDS ${RUSTUP_HOME}/toolchains/epic)
add_dependencies(epic-rust rustup)

if ( NOT RUST_DIR )

file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/epic-rust-upstream.config.toml
CONTENT 
"
[install]
prefix=\"${CMAKE_CURRENT_BINARY_DIR}/install\"
sysconfdir=\"etc\"

[llvm]
ninja=true
targets=\"RISCV;X86\"
experimental-targets=\"\"

[target.x86_64-unknown-linux-gnu]
cc=\"clang\"
cxx=\"clang++\"
"
)

ExternalProject_Add(epic-rust-upstream
    URL https://github.com/jprendes/rust/releases/download/epic-rust/epic2-rust-with-submodules.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/rust
    PATCH_COMMAND git apply --directory=src/llvm-project -p0 ${CMAKE_CURRENT_SOURCE_DIR}/relaxations.patch
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND rm -f ./config.toml
        && ../epic-rust-upstream/x.py setup codegen
        && cat ${CMAKE_CURRENT_BINARY_DIR}/epic-rust-upstream.config.toml >> ./config.toml
    BUILD_COMMAND ../epic-rust-upstream/x.py build
    INSTALL_COMMAND ../epic-rust-upstream/x.py install
        && ../epic-rust-upstream/x.py install src
    # USES_TERMINAL_CONFIGURE true # Setting this to true will result in x.py prompting if we want to install the git hooks
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
    DEPENDS rustup
)

set(RUST_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)

add_dependencies(epic-rust epic-rust-upstream)

endif()

add_custom_command(OUTPUT ${RUSTUP_HOME}/toolchains/epic
    COMMAND ${RUSTUP} rustup toolchain link epic ${RUST_DIR}
)
include(ExternalProject)

ExternalProject_Add(libtock-rs
    URL https://github.com/jprendes/libtock-rs/releases/download/epic-example/epic-libtock-rs-with-submodules.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libtock-rs
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make 
    INSTALL_COMMAND ""
    USES_TERMINAL_CONFIGURE true
    USES_TERMINAL_BUILD true
    USES_TERMINAL_INSTALL true
)

set(TOCK_DIR SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/tock/src/tock)
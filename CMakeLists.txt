cmake_minimum_required (VERSION 3.10.2)

include(cmake/epic-llvm.cmake)
include(cmake/rustup.cmake)
include(cmake/epic-rust.cmake)
include(cmake/tock.cmake)

project(epic-tock-rs-example)

enable_testing()

add_kernel(hifive1)
add_kernel(opentitan/earlgrey-cw310)

add_epic_tock_example(console hifive1)
add_epic_tock_example(console opentitan/earlgrey-cw310)

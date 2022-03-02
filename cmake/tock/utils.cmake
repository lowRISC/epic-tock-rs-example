file(CONFIGURE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Makefile.evaluator CONTENT
"
include $(SOURCE_MAKEFILE)
print-%:
	@echo $($*)
"
)

function(eval_makefile WORKING_DIRECTORY VARIABLE OUTPUT_VARIABLE)
    execute_process(
        COMMAND make -s -f ${CMAKE_CURRENT_BINARY_DIR}/Makefile.evaluator -C ${WORKING_DIRECTORY} SOURCE_MAKEFILE=${WORKING_DIRECTORY}/Makefile print-${VARIABLE}
        WORKING_DIRECTORY ${WORKING_DIRECTORY}
        OUTPUT_VARIABLE MAKEFILE_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(${OUTPUT_VARIABLE} ${MAKEFILE_OUTPUT} PARENT_SCOPE)
endfunction()

function(parse_board_variant BOARD_VARIANT)
    string(REGEX REPLACE "/.*" "" BOARD ${BOARD_VARIANT})
    string(REGEX REPLACE "[^/]*/" "" VARIANT ${BOARD_VARIANT})

    if(NOT VARIANT)
        if("${BOARD}" STREQUAL "opentitan")
            set(VARIANT "earlgrey-cw310")
        else()
            set(VARIANT ${BOARD})
        endif()
    endif()
    
    set(BOARD ${BOARD} PARENT_SCOPE)
    set(VARIANT ${VARIANT} PARENT_SCOPE)

    string(MAKE_C_IDENTIFIER ${BOARD_VARIANT} IDENTIFIER)
    set(IDENTIFIER ${IDENTIFIER} PARENT_SCOPE)

    if(NOT ${IDENTIFIER}_TARGET)
        eval_makefile(${TOCK_ROOT}/boards/${BOARD_VARIANT} TARGET TARGET)
    else()
        set(TARGET ${${IDENTIFIER}_TARGET})
    endif()
    set(TARGET ${TARGET} PARENT_SCOPE)
endfunction()
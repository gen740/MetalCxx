cmake_minimum_required(VERSION 3.26)

project(MetalCXX LANGUAGES CXX Swift)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if("${CMAKE_Swift_COMPILER_VERSION}" VERSION_LESS 5.9)
  message(
    FATAL_ERROR
      "Bidirectional C++ Interop requires Swift 5.9 or greater. Have ${CMAKE_Swift_COMPILER_VERSION}"
  )
endif()

if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"
   AND NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
  message(FATAL_ERROR "Project requires building with Clang.
  Have ${CMAKE_CXX_COMPILER_ID}")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AddSwift)

file(GLOB METALCXX_SWIFT_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.swift)

_swift_generate_cxx_header_target(
  swiftui_h
  SwiftUI_swift
  "${CMAKE_CURRENT_BINARY_DIR}/include/SwiftUI-swift.h"
  SOURCES
  ${METALCXX_SWIFT_SOURCES}
  SEARCH_PATHS
  "${CMAKE_CURRENT_LIST_DIR}/include")

add_library(swift_app STATIC ${METALCXX_SWIFT_SOURCES})
target_link_libraries(swift_app PRIVATE "-framework AppKit")
add_dependencies(swift_app swiftui_h)
target_include_directories(swift_app
                           PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include")
set_target_properties(swift_app PROPERTIES Swift_MODULE_NAME "SwiftUI_swift")
target_compile_options(
  swift_app
  PUBLIC "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>")

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
  COMMAND
    $<TARGET_FILE:Python3::Interpreter>
    ${CMAKE_CURRENT_LIST_DIR}/gen_compile_db.py ARGS -b
    ${CMAKE_CURRENT_BINARY_DIR} -s ${CMAKE_CURRENT_SOURCE_DIR} -o
    ${CMAKE_CURRENT_LIST_DIR}/compile_commands.json -ninjatool
    ${CMAKE_MAKE_PROGRAM} ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
  DEPENDS ${CMAKE_CURRENT_LIST_DIR}/gen_compile_db.py
          ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
  COMMENT "Build compile commands for IDE")

# ./gen_compile_db.py -b ./build -o compile_commands.json -ninjatool=ninja

add_executable(main "${CMAKE_CURRENT_LIST_DIR}/main.cc")
target_link_libraries(main PRIVATE swift_app)

cmake_minimum_required(VERSION 3.28)

project(Metalic LANGUAGES CXX Swift)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if("${CMAKE_Swift_COMPILER_VERSION}" VERSION_LESS 5.9)
  message(
    FATAL_ERROR
      "Bidirectional C++ Interop requires Swift 5.9 or greater. Have ${CMAKE_Swift_COMPILER_VERSION}"
  )
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(CFITSIO REQUIRED cfitsio)

if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"
   AND NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
  message(FATAL_ERROR "Project requires building with Clang.
  Have ${CMAKE_CXX_COMPILER_ID}")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(InitializeSwift)
include(AddSwift)

file(GLOB METALCXX_SWIFT_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.swift)
file(GLOB METALCXX_CXX_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)

_swift_generate_cxx_header_target(
  matalic_h
  Metalic_swift
  "${CMAKE_CURRENT_BINARY_DIR}/include/Metalic-swift.h"
  SOURCES
  ${METALCXX_SWIFT_SOURCES}
  SEARCH_PATHS
  "${CMAKE_CURRENT_LIST_DIR}/include")

add_library(metalic STATIC ${METALCXX_SWIFT_SOURCES})
target_sources(metalic PUBLIC FILE_SET CXX_MODULES FILES
                              ${METALCXX_CXX_SOURCES})
target_include_directories(
  metalic
  PUBLIC
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift
)
target_compile_features(metalic PUBLIC cxx_std_23)

target_link_libraries(metalic PRIVATE "-framework AppKit")
add_dependencies(metalic matalic_h)
target_include_directories(metalic PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/include")
target_include_directories(metalic PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include")
set_target_properties(metalic PROPERTIES Swift_MODULE_NAME "Metalic_swift")
target_compile_options(
  metalic
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

add_executable(main "${CMAKE_CURRENT_LIST_DIR}/main.cc")
target_link_libraries(main PRIVATE metalic)

message("Hello ${CFITSIO_INCLUDE_DIRS} ${CFITSIO_LIBRARIES}")

target_include_directories(main PRIVATE ${CFITSIO_INCLUDE_DIRS})
target_link_libraries(main PRIVATE ${CFITSIO_LIBRARIES})

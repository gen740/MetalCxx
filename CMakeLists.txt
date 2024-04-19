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

add_executable(main "${CMAKE_CURRENT_LIST_DIR}/main.cc")

_swift_generate_cxx_header_target(
  fibonacci_swift_h
  SwiftFibonacci
  "${CMAKE_CURRENT_BINARY_DIR}/include/fibonacci/fibonacci-swift.h"
  SOURCES
  "${CMAKE_CURRENT_SOURCE_DIR}/fibonacci.swift"
  SEARCH_PATHS
  "${PINGPONG_INCLUDE_DIR}")

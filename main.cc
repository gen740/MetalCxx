#include "app-swift.h"

#include <print>

auto main() -> int {
  std::println("{}", "Hello, World");
  SwiftApp::run();
  return 0;
}

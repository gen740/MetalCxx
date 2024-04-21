module;

#include "Metalic-swift.h"
// #include "Metalic.hh"
// #include <memory>
#include <print>

export module Metalic;

import :std_module;

namespace Metalic {

export class App {

  Metalic_swift::MetalicApp app;

public:
  App() : app(Metalic_swift::MetalicApp::getInstance()) {}
  ~App() = default;
  App(const App &) = delete;
  auto operator=(const App &) -> App & = delete;
  App(App &&) = delete;
  auto operator=(App &&) -> App & = delete;

  auto run() -> void { app.run(); }
};

} // namespace Metalic

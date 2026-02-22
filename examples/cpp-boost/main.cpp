#include <boost/format.hpp>
#include <iostream>
#include <memory>
#include <string>

int main() {
  // p1: Minimalism. Use smart pointers as per C++ standard
  auto message = std::make_unique<std::string>("Nix Seed");

  std::cout << boost::format("Hello from %1%!") % *message << std::endl;

  return 0;
}

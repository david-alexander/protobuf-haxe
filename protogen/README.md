ProtoC Plugin for Haxe
======================

This is a Haxe generator plugin for ProtoC. To use it, first <a href="https://code.google.com/p/protobuf/downloads/list">download the Protobuf source</a>, and then follow these steps:

* Copy the `haxe` directory (inside this directory) into `src/google/protobuf/compiler` (inside the Protobuf source tree).
* Add the files from the `haxe` directory to the build. (For MSVC, this means adding them to `vsprojects/libprotoc.vcproj`.)
* Make the following modifications to `src/google/protobuf/compiler/main.cc`
  * Add `#include <google/protobuf/compiler/haxe/haxe_generator.h>` to the includes.
  * Add the following lines to the end of the `main` function, before the `return` statement:

    ```
    // Proto2 Haxe
    google::protobuf::compiler::haxe::HaxeGenerator haxe_generator;
    cli.RegisterGenerator("--haxe_out", &haxe_generator,
                         "Generate Haxe source file.");
    ```
* Build the `protoc` project.

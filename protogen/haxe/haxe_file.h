// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.
// http://code.google.com/p/protobuf/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: kenton@google.com (Kenton Varda)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#ifndef GOOGLE_PROTOBUF_COMPILER_HAXE_FILE_H__
#define GOOGLE_PROTOBUF_COMPILER_HAXE_FILE_H__

#include <string>
#include <vector>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/stubs/common.h>
#include <google/protobuf/compiler/code_generator.h>

namespace google {
namespace protobuf {
	class FileDescriptor;        // descriptor.h
	namespace io {
		class Printer;             // printer.h
	}
	namespace compiler {
		class GeneratorContext;     // code_generator.h
	}
}

namespace protobuf {
namespace compiler {
namespace haxe {

class FileGenerator {
 public:
  explicit FileGenerator(const FileDescriptor* file);
  ~FileGenerator();

  // Checks for problems that would otherwise lead to cryptic compile errors.
  // Returns true if there are no problems, or writes an error description to
  // the given string and returns false otherwise.
  bool Validate(string* error);

  void Generate(io::Printer* printer, int message_number);
  void GenerateSiblings(const string& package_dir, OutputDirectory* output_directory);

  const string& haxe_package() { return haxe_package_; }

 private:
  const FileDescriptor* file_;
  string haxe_package_;
  
  void GenerateEnumSiblings(const string& package_dir, OutputDirectory* output_directory, Descriptor const* message);
  void GenerateMessageSiblings(const string& package_dir, OutputDirectory* output_directory, Descriptor const* root_message);

  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(FileGenerator);
};

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

#endif  // GOOGLE_PROTOBUF_COMPILER_HAXE_FILE_H__

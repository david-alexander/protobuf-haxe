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

// Author: Robert Blackwood (ported from Kenton's)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#include <algorithm>
#include <sstream>
#include <google/protobuf/stubs/hash.h>
#include <google/protobuf/compiler/haxe/haxe_enum_decoder.h>
#include <google/protobuf/compiler/haxe/haxe_helpers.h>
#include <google/protobuf/stubs/strutil.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format.h>
#include <google/protobuf/descriptor.pb.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace haxe {

using internal::WireFormat;

// ===================================================================

EnumDecoderGenerator::EnumDecoderGenerator(const EnumDescriptor* descriptor)
  : descriptor_(descriptor)
{

}

EnumDecoderGenerator::~EnumDecoderGenerator() {}

void EnumDecoderGenerator::Generate(io::Printer* printer)
{
	SourceLocation location;
	if (descriptor_->GetSourceLocation(&location))
	{
		PrintDocumentationComment(printer, location.leading_comments);
	}

	printer->Print("class EnumDecoder_$enumname$ implements com.cerebralfix.protobuf.EnumDecoder<$enumname$> {\n",
				   "enumname", descriptor_->name());
	printer->Indent();

	printer->Print("public function new():Void { };\n");

	printer->Outdent();
	printer->Print("}\n");
}

// ===================================================================

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

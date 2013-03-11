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
#include <google/protobuf/compiler/haxe/haxe_enum.h>
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

namespace {

static void GenerateField(io::Printer* printer, const EnumValueDescriptor* field)
{
	/*
		HaxeDoc doesn't like it if there is metadata separating the documentation
		comment from the field declaration, so we output the metadata first.
	*/
	stringstream enum_constant_string;
	enum_constant_string << field->number();
	printer->Print("\n@:enumConstant($enum_constant$)\n",
		"enum_constant", enum_constant_string.str());

	// Then, output the documentation comment (this comes from the proto file).
	SourceLocation location;
	if (field->GetSourceLocation(&location))
	{
		PrintDocumentationComment(printer, location.leading_comments);
	}

	// Finally, output the field declaration itself.
	printer->Print("$field_name$;\n",
		"field_name", field->name());
}

}  // namespace

// ===================================================================

EnumGenerator::EnumGenerator(const EnumDescriptor* descriptor)
  : descriptor_(descriptor)
{

}

EnumGenerator::~EnumGenerator() {}

void EnumGenerator::Generate(io::Printer* printer)
{
	SourceLocation location;
	if (descriptor_->GetSourceLocation(&location))
	{
		PrintDocumentationComment(printer, location.leading_comments);
	}

	printer->Print("enum $enumname$ {\n",
				   "enumname", descriptor_->name());

	printer->Indent();

	for (int i = 0; i < descriptor_->value_count(); i++)
	{
		GenerateField(printer, descriptor_->value(i));
	}
	
	printer->Outdent();
	printer->Print("}\n");
}

// ===================================================================

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

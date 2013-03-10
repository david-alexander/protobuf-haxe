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
#include <google/protobuf/compiler/haxe/haxe_message.h>
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

string HaxeFieldType(const FieldDescriptor* field)
{
	stringstream typeName;
	typeName << "com.cerebralfix.protobuf.fieldtypes.";

	if (field->is_repeated())
	{
		if (field->is_packed())
		{
			typeName << "Packed";
		}
		typeName << "RepeatedField<com.cerebralfix.protobuf.fieldtypes.";
	}

	switch (field->type()) {
		case FieldDescriptor::TYPE_DOUBLE	: typeName << "DoubleField"; break;
		case FieldDescriptor::TYPE_FLOAT	: typeName << "FloatField"; break;
		case FieldDescriptor::TYPE_INT64    : typeName << "Int64Field"; break;
		case FieldDescriptor::TYPE_UINT64   : typeName << "UInt64Field"; break;
		case FieldDescriptor::TYPE_INT32    : typeName << "Int32Field"; break;
		case FieldDescriptor::TYPE_FIXED64  : typeName << "Fixed64Field"; break;
		case FieldDescriptor::TYPE_FIXED32  : typeName << "Fixed32Field"; break;
		case FieldDescriptor::TYPE_BOOL		: typeName << "BoolField"; break;
		case FieldDescriptor::TYPE_STRING	: typeName << "StringField"; break;
		case FieldDescriptor::TYPE_BYTES	: typeName << "BytesField"; break;
		case FieldDescriptor::TYPE_UINT32	: typeName << "UInt32Field"; break;
		case FieldDescriptor::TYPE_SFIXED32	: typeName << "SFixed32Field"; break;
		case FieldDescriptor::TYPE_SFIXED64	: typeName << "SFixed64Field"; break;
		case FieldDescriptor::TYPE_SINT32	: typeName << "SInt32Field"; break;
		case FieldDescriptor::TYPE_SINT64	: typeName << "SInt64Field"; break;
		case FieldDescriptor::TYPE_MESSAGE:
			{
				typeName << "MessageField<" << FileHaxePackage(field->message_type()->file()) << "." << field->message_type()->name() << ">";
				break;
			}
		case FieldDescriptor::TYPE_ENUM:
			{
				typeName << "EnumField<" << field->enum_type()->name() << ">";
				break;
			}
		case FieldDescriptor::TYPE_GROUP: GOOGLE_LOG(FATAL) << "Groups are not yet supported in Protobuf-Haxe"; return NULL;
	}

	if (field->is_repeated())
	{
		typeName << ">";
	}

	return typeName.str();
}

static void PrintDocumentationComment(io::Printer* printer, std::string comment)
{
	vector<string> comment_lines;
	SplitStringUsing(comment, "\n", &comment_lines);

	bool printed_first_line = false;

	for (vector<string>::iterator i = comment_lines.begin(); i != comment_lines.end(); i++)
	{
		if (!i->empty())
		{
			if (!printed_first_line)
			{
				printer->Print("/**\n");
				printed_first_line = true;
			}

			printer->Print("  \t$comment_line$\n",
				"comment_line", *i
			);
		}
	}

	if (printed_first_line)
	{
		printer->Print(" **/\n");
	}
}

static void GenerateField(io::Printer* printer, const FieldDescriptor* field)
{
	/*
		HaxeDoc doesn't like it if there is metadata separating the documentation
		comment from the field declaration, so we output the metadata first.
	*/
	stringstream field_number_string;
	field_number_string << field->number();
	printer->Print("\n@:fieldNumber($field_number$)\n",
		"field_number", field_number_string.str());

	// Then, output the documentation comment (this comes from the proto file).
	SourceLocation location;
	if (field->GetSourceLocation(&location))
	{
		PrintDocumentationComment(printer, location.leading_comments);
	}

	// Finally, output the field declaration itself.
	printer->Print("public var $field_name$ (default, null) : $field_type$;\n",
		"field_name", field->name(),
		"field_type", HaxeFieldType(field));
}

}  // namespace

// ===================================================================

MessageGenerator::MessageGenerator(const Descriptor* descriptor)
  : descriptor_(descriptor)
{

}

MessageGenerator::~MessageGenerator() {}

void MessageGenerator::Generate(io::Printer* printer)
{
	SourceLocation location;
	if (descriptor_->GetSourceLocation(&location))
	{
		PrintDocumentationComment(printer, location.leading_comments);
	}

	printer->Print("class $classname$ implements com.cerebralfix.protobuf.Message {\n",
				   "classname", descriptor_->name());

	printer->Indent();

	printer->Print("public function new():Void { }\n");

	for (int i = 0; i < descriptor_->field_count(); i++)
	{
		GenerateField(printer, descriptor_->field(i));
	}
	
	printer->Outdent();
	printer->Print("}\n");
}

// ===================================================================

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

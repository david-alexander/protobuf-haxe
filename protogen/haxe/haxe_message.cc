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

const char* HaxeFieldType(const FieldDescriptor* field, bool isInsideRepeatedField = false)
{
	if (field->is_repeated() && !isInsideRepeatedField)
	{
		return "RepeatedField";
	}
	else
	{
		switch (field->type()) {
		case FieldDescriptor::TYPE_DOUBLE	: return "DoubleField";
		case FieldDescriptor::TYPE_FLOAT	: return "FloatField";          
		case FieldDescriptor::TYPE_INT64    : return "Int64Field";                       
		case FieldDescriptor::TYPE_UINT64   : return "UInt64Field";     
		case FieldDescriptor::TYPE_INT32    : return "Int32Field";             
		case FieldDescriptor::TYPE_FIXED64  : return "Fixed64Field";
		case FieldDescriptor::TYPE_FIXED32  : return "Fixed32Field";
		case FieldDescriptor::TYPE_BOOL		: return "BoolField";
		case FieldDescriptor::TYPE_STRING	: return "StringField";
		case FieldDescriptor::TYPE_GROUP	: GOOGLE_LOG(FATAL) << "Groups are not supported in Protobuf-Haxe";
		case FieldDescriptor::TYPE_MESSAGE	: return "MessageField";
		case FieldDescriptor::TYPE_BYTES	: return "BytesField";
		case FieldDescriptor::TYPE_UINT32	: return "UInt32Field";
		case FieldDescriptor::TYPE_ENUM		: return "EnumField";
		case FieldDescriptor::TYPE_SFIXED32	: return "SFixed32Field";
		case FieldDescriptor::TYPE_SFIXED64	: return "SFixed64Field";
		case FieldDescriptor::TYPE_SINT32	: return "SInt32Field";
		case FieldDescriptor::TYPE_SINT64	: return "SInt64Field";
		}
	}
	GOOGLE_LOG(FATAL) << "Can't get here.";
	return NULL;
}

const char* HaxeFieldTypeParameter(const FieldDescriptor* field)
{
	if (field->is_repeated())
	{
		return HaxeFieldType(field, true);
	}
	else
	{
		switch (field->type()) {
		case FieldDescriptor::TYPE_MESSAGE	: return field->message_type()->name().c_str();
		case FieldDescriptor::TYPE_ENUM		: return field->enum_type()->name().c_str();
		}
	}
	return NULL;
}

void PrintFieldComment(io::Printer* printer, const FieldDescriptor* field) {
  // Print the field's proto-syntax definition as a comment.  We don't want to
  // print group bodies so we cut off after the first line.
  string def = field->DebugString();
  printer->Print("\n// $def$\n",
    "def", def.substr(0, def.find_first_of('\n')));
}

static void GenerateField(io::Printer* printer, const FieldDescriptor* field)
{
	PrintFieldComment(printer, field);

	const char* field_type = HaxeFieldType(field);
	const char* field_type_parameter = HaxeFieldTypeParameter(field);

	stringstream field_number_string;
	field_number_string << field->number();

	printer->Print("@:fieldNumber($field_number$)\n",
		"field_number", field_number_string.str());

	if (field_type_parameter == NULL)
	{
		printer->Print("public var $field_name$:com.cerebralfix.protobuf.fieldtypes.$field_type$;\n",
			"field_name", field->name(),
			"field_type", field_type);
	}
	else
	{
		printer->Print("public var $field_name$:com.cerebralfix.protobuf.fieldtypes.$field_type$<com.cerebralfix.protobuf.fieldtypes.$field_type_parameter$>;\n",
			"field_name", field->name(),
			"field_type", field_type,
			"field_type_parameter", field_type_parameter);
	}
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

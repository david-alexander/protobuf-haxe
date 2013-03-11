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

#include <vector>

#include <google/protobuf/compiler/haxe/haxe_helpers.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace haxe {

const char kThickSeparator[] =
  "// ===================================================================\n";
const char kThinSeparator[] =
  "// -------------------------------------------------------------------\n";

namespace {

const char* kDefaultPackage = "";

const string& FieldName(const FieldDescriptor* field) {
  // Groups are hacky:  The name of the field is just the lower-cased name
  // of the group type.  In As3, though, we would like to retain the original
  // capitalization of the type name.
  if (field->type() == FieldDescriptor::TYPE_GROUP) {
    return field->message_type()->name();
  } else {
    return field->name();
  }
}

string UnderscoresToCamelCaseImpl(const string& input, bool cap_next_letter) {
  string result;
  // Note:  I distrust ctype.h due to locales.
  for (int i = 0; i < input.size(); i++) {
    if ('a' <= input[i] && input[i] <= 'z') {
      if (cap_next_letter) {
        result += input[i] + ('A' - 'a');
      } else {
        result += input[i];
      }
      cap_next_letter = false;
    } else if ('A' <= input[i] && input[i] <= 'Z') {
      if (i == 0 && !cap_next_letter) {
        // Force first letter to lower-case unless explicitly told to
        // capitalize it.
        result += input[i] + ('a' - 'A');
      } else {
        // Capital letters after the first are left as-is.
        result += input[i];
      }
      cap_next_letter = false;
    } else if ('0' <= input[i] && input[i] <= '9') {
      result += input[i];
      cap_next_letter = true;
    } else {
      cap_next_letter = true;
    }
  }
  return result;
}

}  // namespace

string UnderscoresToCamelCase(const FieldDescriptor* field) {
  return UnderscoresToCamelCaseImpl(FieldName(field), false);
}

string UnderscoresToCapitalizedCamelCase(const FieldDescriptor* field) {
  return UnderscoresToCamelCaseImpl(FieldName(field), true);
}

string UnderscoresToCamelCase(const MethodDescriptor* method) {
  return UnderscoresToCamelCaseImpl(method->name(), false);
}

string StripProto(const string& filename) {
  if (HasSuffixString(filename, ".protodevel")) {
    return StripSuffixString(filename, ".protodevel");
  } else {
    return StripSuffixString(filename, ".proto");
  }
}

string FileClassName(const FileDescriptor* file) {
  if (file->options().has_java_outer_classname()) {
    return file->options().java_outer_classname();
  } else {
    string basename;
    string::size_type last_slash = file->name().find_last_of('/');
    if (last_slash == string::npos) {
      basename = file->name();
    } else {
      basename = file->name().substr(last_slash + 1);
    }
    return UnderscoresToCamelCaseImpl(StripProto(basename), true);
  }
}

string FileHaxePackage(const FileDescriptor* file) {
  if (file->options().has_java_package()) {
    return file->options().java_package();
  } else {
    string result = kDefaultPackage;
    if (!file->package().empty()) {
      if (!result.empty()) result += '.';
      result += file->package();
    }
    return result;
  }
}

string ToHaxeName(const string& full_name, const FileDescriptor* file) {
  string result;
  if (file->options().java_multiple_files()) {
    result = FileHaxePackage(file);
  } else {
    result = ClassName(file);
  }
  if (!result.empty()) {
    result += '.';
  }
  if (file->package().empty()) {
    result += full_name;
  } else {
    // Strip the proto package from full_name since we've replaced it with
    // the Haxe package.
    result += full_name.substr(file->package().size() + 1);
  }
  return result;
}

string ClassName(const FileDescriptor* descriptor) {
  string result = FileHaxePackage(descriptor);
  if (!result.empty()) result += '.';
  result += FileClassName(descriptor);
  return result;
}

void PrintDocumentationComment(io::Printer* printer, std::string comment)
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

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

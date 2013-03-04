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

// Author:  Robert Blackwood (ported from Kenton's)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#include <google/protobuf/compiler/haxe/haxe_generator.h>
#include <google/protobuf/compiler/haxe/haxe_file.h>
#include <google/protobuf/compiler/haxe/haxe_helpers.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace haxe {

namespace {

// Parses a set of comma-delimited name/value pairs, e.g.:
//   "foo=bar,baz,qux=corge"
// parses to the pairs:
//   ("foo", "bar"), ("baz", ""), ("qux", "corge")
void ParseOptions(const string& text, vector<pair<string, string> >* output) {
	vector<string> parts;
	SplitStringUsing(text, ",", &parts);

	for (int i = 0; i < parts.size(); i++) {
		string::size_type equals_pos = parts[i].find_first_of('=');
		pair<string, string> value;
		if (equals_pos == string::npos) {
			value.first = parts[i];
			value.second = "";
		} else {
			value.first = parts[i].substr(0, equals_pos);
			value.second = parts[i].substr(equals_pos + 1);
		}
		output->push_back(value);
	}
}

}  // namespace

HaxeGenerator::HaxeGenerator() {}
HaxeGenerator::~HaxeGenerator() {}

bool HaxeGenerator::Generate(const FileDescriptor* file,
							 const string& parameter,
							 OutputDirectory* output_directory,
							 string* error) const
{
	vector<pair<string, string> > options;
	ParseOptions(parameter, &options);

	for (int i = 0; i < file->message_type_count(); i++)
	{
		// Validate the input.
		FileGenerator file_generator(file);
		if (!file_generator.Validate(error))
		{
			return false;
		}

		// Generate the filename.
		string package_dir = StringReplace(file_generator.haxe_package(), ".", "/", true);
		if (!package_dir.empty()) package_dir += "/";
		string haxe_filename = package_dir + file->message_type(i)->name() + ".hx";

		// Write the file.
		scoped_ptr<io::ZeroCopyOutputStream> output(output_directory->Open(haxe_filename));
		io::Printer printer(output.get(), '$');

		file_generator.Generate(&printer, i);

		// TODO: Generate "siblings" (enums, services, etc.)
	}

	return true;
}

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

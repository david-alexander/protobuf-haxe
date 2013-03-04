#ifndef GOOGLE_PROTOBUF_COMPILER_HAXE_GENERATOR_H__
#define GOOGLE_PROTOBUF_COMPILER_HAXE_GENERATOR_H__

#include <string>
#include <google/protobuf/compiler/code_generator.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace haxe {

class LIBPROTOC_EXPORT HaxeGenerator : public CodeGenerator {
 public:
  HaxeGenerator();
  ~HaxeGenerator();

  // implements CodeGenerator ----------------------------------------
  bool Generate(const FileDescriptor* file,
                const string& parameter,
                OutputDirectory* output_directory,
                string* error) const;

 private:
  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(HaxeGenerator);
};

}  // namespace haxe
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

#endif  // GOOGLE_PROTOBUF_COMPILER_HAXE_GENERATOR_H__

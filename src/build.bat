haxe compile.hxml
if %errorlevel% neq 0 exit /b %errorlevel%

pushd ..\build\cpp

REM This is a hack to get around an issue (seems to be a bug in HXCPP) where an unnecessary CPP file is created for a "@:generic" class, which sometimes breaks the build depending on the content of this class.

> .\src\com\cerebralfix\protobuf\fieldtypes\RepeatedField.cpp echo #include "hxcpp.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\RepeatedField.cpp echo #include "com/cerebralfix/protobuf/fieldtypes/RepeatedField.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\RepeatedField.cpp echo namespace com{ namespace cerebralfix{ namespace protobuf{ namespace fieldtypes{ void RepeatedField_obj::__register() { } void RepeatedField_obj::__boot() { } } } } }

> .\src\com\cerebralfix\protobuf\fieldtypes\MessageField.cpp echo #include "hxcpp.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\MessageField.cpp echo #include "com/cerebralfix/protobuf/fieldtypes/MessageField.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\MessageField.cpp echo namespace com{ namespace cerebralfix{ namespace protobuf{ namespace fieldtypes{ void MessageField_obj::__register() { } void MessageField_obj::__boot() { } } } } }

> .\src\com\cerebralfix\protobuf\stream\MessageDataDecoder.cpp echo #include "hxcpp.h"
>> .\src\com\cerebralfix\protobuf\stream\MessageDataDecoder.cpp echo #include "com/cerebralfix/protobuf/stream/MessageDataDecoder.h"
>> .\src\com\cerebralfix\protobuf\stream\MessageDataDecoder.cpp echo namespace com{ namespace cerebralfix{ namespace protobuf{ namespace stream{ void MessageDataDecoder_obj::__register() { } void MessageDataDecoder_obj::__boot() { } } } } }

> .\src\com\cerebralfix\protobuf\fieldtypes\MessageDispatcher.cpp echo #include "hxcpp.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\MessageDispatcher.cpp echo #include "com/cerebralfix/protobuf/stream/MessageDispatcher.h"
>> .\src\com\cerebralfix\protobuf\fieldtypes\MessageDispatcher.cpp echo namespace com{ namespace cerebralfix{ namespace protobuf{ namespace stream{ void MessageDispatcher_obj::__register() { } void MessageDispatcher_obj::__boot() { } } } } }


haxelib run hxcpp Build.xml haxe -Dhaxe3="1" -Dhaxe_ver="3."
if %errorlevel% neq 0 exit /b %errorlevel%

popd
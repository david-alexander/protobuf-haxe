..\test\protoc --haxe_out=. --proto_path=..\test ..\test\ChatClientTest.proto
haxe -swf ..\build\Main.swf -debug -main com.cerebralfix.protobuf.test.Main -xml ..\build\flash.xml

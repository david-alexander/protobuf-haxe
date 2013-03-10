Protobuf-Haxe
=============

**Protobuf-Haxe** is an implementation of Google's *[Protocol Buffers](https://code.google.com/p/protobuf/)* library for the [Haxe](http://haxe.org/) platform. It requires [Haxe 3.0](http://haxe.org/manual/haxe3) or above.

The project is still in the **very early** stages of development, and further information will be posted here soon.

**Contact:** David Alexander (<david@cerebralfix.com>)

### What is Implemented?

* ProtoC generator plugin (see `protogen` directory)
* Reading and writing from byte arrays
* All primitive types (not all tested yet - expect some issues with signed vs unsigned integers, endianness, etc.)
* Repeated fields (packed and non-packed)
* Messages within messages
* Length-prefixed messages (à la <a href="https://code.google.com/p/protobuf-net/">protobuf-net</a>)
* Utility code for dealing with sockets (synchronous and asynchronous)
* Utility code for managing <a href="https://developers.google.com/protocol-buffers/docs/techniques#union">union messages</a>, including passing them to appropriate callbacks

### To-Do List

* Type-safe enum fields
* Required fields (currently all are considered optional, even if specified as required in the proto file)
* Unit tests for the library and the ProtoC generator, covering all data types
* Memory pooling of messages
* Source code documentation
* Sample code (e.g. basic chat client/server)
* Support for Protobuf RPC Services
* An option to interpret union messages as parameterized enums
* Support for the now-deprecated "group" field type

### Known Issues

* The `RepeatedField` class seems to be triggering a bug in HXCPP which causes the C++ build to fail. It is currently being worked around using a batch script that deletes the offending C++ code before the C++ compiler is run.
* Enums are not yet properly implemented, even though the EnumField class exists. Also, the ProtoC generator may not generate valid code for them.
* The MessageBuilder macros can generate cryptic compiler errors (such as "this pattern is unused") when given incorrect message specifications (e.g. missing field numbers). The file/line information for these errors is also incorrect.

Protobuf-Haxe
=============

**Protobuf-Haxe** is an implementation of Google's *[Protocol Buffers](https://code.google.com/p/protobuf/)* library for the [Haxe](http://haxe.org/) platform. It requires [Haxe 3.0](http://haxe.org/manual/haxe3) or above.

The project is still in the **very early** stages of development, and further information will be posted here soon.

**Contact:** David Alexander (<david@cerebralfix.com>)

### What is Implemented?

* Reading and writing from byte arrays
* All primitive types (not all tested yet - expect some issues with signed vs unsigned integers, endianness, etc.)
* Repeated fields

### To-Do List

* Length-prefixed messages (à la [protobuf-net][https://code.google.com/p/protobuf-net/])
* Messages within messages
* Type-safe enum fields
* Utility code for dealing with sockets (synchronous and asynchronous)
* Utility code for managing [union messages][https://developers.google.com/protocol-buffers/docs/techniques#union], including passing them to appropriate callbacks
* ProtoC generator
* Required fields (currently all are considered optional, even if specified as required in the proto file)
* Unit tests for the library and the ProtoC generator, covering all data types

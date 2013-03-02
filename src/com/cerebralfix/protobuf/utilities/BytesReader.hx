// This file is part of Protobuf-Haxe.
// 
// Protobuf-Haxe is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Protobuf-Haxe is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with Protobuf-Haxe.  If not, see <http://www.gnu.org/licenses/>.

package com.cerebralfix.protobuf.utilities;

import haxe.io.Bytes;

class BytesReader
{
	private var _bytes : Bytes;
	private var _position : Int;

	public inline function new(bytes:Bytes)
	{
		_bytes = bytes;
		_position = 0;
	}

	public inline function readByte():Int
	{
#if debug
		if (hasByte())
		{
#end
			return _bytes.get(_position++);
#if debug
		}
		else
		{
			throw "Tried to read past end of byte array.";
		}
#end
	}

	public inline function fillByteArray(buffer:Bytes):Void
	{
#if debug
		if ((_position + buffer.length) <= _bytes.length)
		{
#end
			buffer.blit(0, _bytes, _position, buffer.length);
			_position += buffer.length;
#if debug
		}
		else
		{
			_position = _bytes.length;
			throw "Tried to read past end of byte array.";
		}
#end
	}

	public inline function length():Int
	{
		return _bytes.length;
	}

	public inline function bytesAvailable():Int
	{
		return _bytes.length - _position;
	}

	public inline function hasByte():Bool
	{
		return _position < _bytes.length;
	}

	public inline function reset():Void
	{
		_position = 0;
	}
}
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

package com.cerebralfix.protobuf.fieldtypes;

import haxe.Int64;

class SInt64Field implements Field
{
	public var _value:Int64;

	public inline function new()
	{

	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case VarInt(value):
			{
				// From http://stackoverflow.com/questions/2210923/zig-zag-decoding
				_value = Int64.xor(Int64.shr(value, 1), Int64.neg(Int64.and(value, Int64.ofInt(1))));
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (_value != null)
		{
			return [VarInt(Int64.xor(Int64.shl(_value, 1), Int64.shr(_value, 31)))];
		}
		else
		{
			return [];
		}
	}

	public inline function isSet():Bool
	{
		return _value != null;
	}
}
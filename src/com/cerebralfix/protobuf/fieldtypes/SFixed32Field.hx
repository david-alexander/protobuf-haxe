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

class SFixed32Field implements Field
{
	public var _value:Null<Int>;

	public inline function new()
	{

	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case ThirtyTwoBit(value):
			{
				_value = value;
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (_value != null)
		{
			return [ThirtyTwoBit(_value)];
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
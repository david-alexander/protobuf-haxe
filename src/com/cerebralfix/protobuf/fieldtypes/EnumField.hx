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
import com.cerebralfix.protobuf.EnumDecoder;
import com.cerebralfix.protobuf.field.FieldData;
import com.cerebralfix.protobuf.field.PackableField;
import com.cerebralfix.protobuf.field.PackableType;
import com.cerebralfix.protobuf.field.ValueField;

class EnumField<T> implements ValueField<Null<T>> implements PackableField
{
	public var value (default, default) : Null<T>;

	private var _decoder : EnumDecoder<T>;

	public inline function new(decoder : EnumDecoder<T>)
	{
		_decoder = decoder;
	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case VarInt(dataValue):
			{
				value = _decoder.enumValueFromInt(Int64.toInt(dataValue));
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (value != null)
		{
			return [VarInt(Int64.ofInt(_decoder.intFromEnumValue(value)))];
		}
		else
		{
			return [];
		}
	}

	public inline function isSet():Bool
	{
		return value != null;
	}

	public inline function getPackableType():PackableType
	{
		return PackableVarInt;
	}
}
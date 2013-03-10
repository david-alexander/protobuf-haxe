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

import com.cerebralfix.protobuf.utilities.BytesReader;
import haxe.io.BytesOutput;
import com.cerebralfix.protobuf.field.FieldData;
import com.cerebralfix.protobuf.field.FieldDataReader;
import com.cerebralfix.protobuf.field.FieldDataWriter;
import com.cerebralfix.protobuf.field.PackableField;
import com.cerebralfix.protobuf.field.PackableType;
import com.cerebralfix.protobuf.field.ValueField;

@:generic class PackedRepeatedField<TField : (PackableField, {function new():Void;})> implements Field
{
	public var _fields:Array<TField>;

	public inline function new()
	{
		_fields = [];
	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case LengthDelimited(bytes):
			{
				var reader = new BytesReader(bytes);

				while (reader.hasByte())
				{
					var field = new TField();

					readField(field, reader);

					if (field.isSet())
					{
						_fields.push(field);
					}
				}
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		var bytesOutput = new BytesOutput();

		for (field in _fields)
		{
			writeField(field, bytesOutput);
		}

		return [LengthDelimited(bytesOutput.getBytes())];
	}

	public inline function isSet():Bool
	{
		return true;
	}

	public inline function get(index:Int):TField
	{
		return _fields[index];
	}

	public inline function push(field:TField):Void
	{
		_fields.push(field);
	}

	@:generic public inline function newEntry():TField
	{
		var field = new TField();
		_fields.push(field);
		return field;
	}

	private inline function readField(field:PackableField, reader:BytesReader):Void
	{
		var fieldData = switch (field.getPackableType())
		{
			case PackableVarInt:
			{
				FieldDataReader.readFieldDataVarInt(reader);
			}

			case PackableThirtyTwoBit:
			{
				FieldDataReader.readFieldData32Bit(reader);
			}

			case PackableSixtyFourBit:
			{
				FieldDataReader.readFieldData64Bit(reader);
			}
		}

		field.readFrom(fieldData);
	}

	private inline function writeField(field:PackableField, output:BytesOutput):Void
	{
		for (fieldData in field.write())
		{
			switch (fieldData)
			{
				case VarInt(value):
				{
					FieldDataWriter.writeFieldDataVarInt(output, value);
				}

				case ThirtyTwoBit(value):
				{
					FieldDataWriter.writeFieldData32Bit(output, value);
				}

				case SixtyFourBit(value):
				{
					FieldDataWriter.writeFieldData64Bit(output, value);
				}

				default: {}
			}
		}
	}
}
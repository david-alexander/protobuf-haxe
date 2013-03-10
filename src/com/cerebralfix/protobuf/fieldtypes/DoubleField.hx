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
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import com.cerebralfix.protobuf.field.FieldData;
import com.cerebralfix.protobuf.field.PackableField;
import com.cerebralfix.protobuf.field.PackableType;
import com.cerebralfix.protobuf.field.ValueField;

class DoubleField implements ValueField<Null<Float>> implements PackableField
{
	public var value (default, default) : Null<Float>;

	public inline function new()
	{

	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case SixtyFourBit(dataValue):
			{
				var bytesOutput = new BytesOutput();

				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 56)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 48)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 40)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 32)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 24)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 16)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 8)));
				bytesOutput.writeByte(Int64.toInt(Int64.shr(dataValue, 0)));

				var bytes = bytesOutput.getBytes();

				var bytesInput = new BytesInput(bytes, 0, bytes.length);
				value = bytesInput.readDouble();
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (value != null)
		{
			var bytesOutput = new BytesOutput();
			bytesOutput.writeDouble(value);
			var bytes = bytesOutput.getBytes();
			var bytesInput = new BytesInput(bytes, 0, bytes.length);

			var result = Int64.ofInt(0);

			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 56));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 48));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 40));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 32));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 24));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 16));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 8));
			result = Int64.or(result, Int64.shl(Int64.ofInt(bytesInput.readByte()), 0));

			return [SixtyFourBit(result)];
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
import com.cerebralfix.protobuf.field.PackableField;
import com.cerebralfix.protobuf.field.PackableType;
import com.cerebralfix.protobuf.field.ValueField;
	{
		return PackableSixtyFourBit;
	}
}
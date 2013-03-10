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

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class FloatField implements ValueField<Null<Float>> implements PackableField
{
	public var value:Null<Float>;

	public inline function new()
	{

	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case ThirtyTwoBit(dataValue):
			{
				var bytesOutput = new BytesOutput();
				bytesOutput.writeInt32(dataValue);

				var bytes = bytesOutput.getBytes();

				var bytesInput = new BytesInput(bytes, 0, bytes.length);
				value = bytesInput.readFloat();
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (value != null)
		{
			var bytesOutput = new BytesOutput();
			bytesOutput.writeFloat(value);
			var bytes = bytesOutput.getBytes();
			var bytesInput = new BytesInput(bytes, 0, bytes.length);

			return [ThirtyTwoBit(bytesInput.readInt32())];
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

	public inline function getPackableType():PackableField.PackableType
	{
		return PackableThirtyTwoBit;
	}
}
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

package com.cerebralfix.protobuf;

import haxe.Int64;
import haxe.io.Bytes;

enum ReadVarIntResult
{
	VarInt(value : Int64);
	Incomplete;
}

typedef ProtobufInput = com.cerebralfix.protobuf.utilities.BytesReader;

class FieldDataReader
{
	public static inline function readFieldData(input : ProtobufInput) : {fieldNumber: Int, data: FieldData}
	{
		return switch (readVarInt(input))
		{
			case Incomplete:
				// TODO: Use an enum for the result of readFieldData.
				{fieldNumber: -1, data: FieldData.Incomplete};

			case VarInt(key):
			{
				var keyAs32Bits = Int64.toInt(key);
				var fieldNumber = keyAs32Bits >> 3;
				var wireType = keyAs32Bits & ((1 << 3) - 1);

				var data = switch (wireType) {
					case 0:
						readFieldDataVarInt(input);

					case 5:
						readFieldData32Bit(input);

					case 1:
						readFieldData64Bit(input);

					case 2:
						readFieldDataLengthDelimited(input);

					default:
						FieldData.Unknown;
				}

				{fieldNumber: fieldNumber, data: data};
			}
		}
	}

	private static inline function readFieldDataVarInt(input : ProtobufInput) : FieldData
	{
		return switch (readVarInt(input))
		{
			case Incomplete:
				FieldData.Incomplete;

			case VarInt(value):
				FieldData.VarInt(value);
		}
	}

	// TOOD: Check endianness.
	private static inline function readFieldData32Bit(input : ProtobufInput) : FieldData
	{
		var result = FieldData.Incomplete;

		if (input.bytesAvailable() >= 4)
		{
			var b1 = input.readByte();
			var b2 = input.readByte();
			var b3 = input.readByte();
			var b4 = input.readByte();

			result = FieldData.ThirtyTwoBit((b1 << 24) | (b2 << 16) | (b2 << 8) | (b3 << 0));
		}

		return result;
	}

	// TOOD: Check endianness.
	private static inline function readFieldData64Bit(input : ProtobufInput) : FieldData
	{
		var result = FieldData.Incomplete;

		if (input.bytesAvailable() >= 8)
		{
			var b1:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 56);
			var b2:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 48);
			var b3:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 40);
			var b4:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 32);
			var b5:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 24);
			var b6:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 16);
			var b7:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 8);
			var b8:Int64 = Int64.shl(Int64.ofInt(input.readByte()), 0);

			result = FieldData.SixtyFourBit(Int64.add(b1, Int64.add(b2, Int64.add(b3, Int64.add(b4, Int64.add(b5, Int64.add(b6, Int64.add(b7, b8))))))));
		}

		return result;
	}

	private static inline function readFieldDataLengthDelimited(input : ProtobufInput) : FieldData
	{
		var result = FieldData.Incomplete;

		switch (readVarInt(input))
		{
			case Incomplete:
				result = FieldData.Incomplete;

			case VarInt(length):
			{
				var lengthAs32Bit = Int64.toInt(length);
				if (input.bytesAvailable() >= lengthAs32Bit)
				{
					var bytes = Bytes.alloc(lengthAs32Bit);
					input.fillByteArray(bytes);
					result = FieldData.LengthDelimited(bytes);
				}
			}
		}

		return result;
	}

	private static inline function readVarInt(input : ProtobufInput) : ReadVarIntResult
	{
		var varInt:Int64 = Int64.ofInt(0);
		var result = ReadVarIntResult.Incomplete;

		while (input.hasByte())
		{
			var byte : Int = input.readByte();

			varInt = Int64.add(varInt, Int64.ofInt(byte & ~(1 << 7)));

			if ((byte & (1 << 7)) == 0)
			{
				result = ReadVarIntResult.VarInt(varInt);
				break;
			}

			varInt = Int64.shl(varInt, 7);
		}

		return result;
	}
}
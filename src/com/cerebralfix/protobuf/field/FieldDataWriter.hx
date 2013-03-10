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

package com.cerebralfix.protobuf.field;

import haxe.Int64;
import haxe.io.Bytes;

typedef ProtobufOutput = haxe.io.Output;

class FieldDataWriter
{
	public static inline function writeFieldData(output : ProtobufOutput, fieldNumber : Int, data : FieldData) : Void
	{
		switch (data)
		{
			case VarInt(value):
			{
				writeFieldKey(output, fieldNumber, 0);
				writeFieldDataVarInt(output, value);
			}

			case ThirtyTwoBit(value):
			{
				writeFieldKey(output, fieldNumber, 5);
				writeFieldData32Bit(output, value);
			}

			case SixtyFourBit(value):
			{
				writeFieldKey(output, fieldNumber, 1);
				writeFieldData64Bit(output, value);
			}

			case LengthDelimited(bytes):
			{
				writeFieldKey(output, fieldNumber, 2);
				writeFieldDataLengthDelimited(output, bytes);
			}

			default: {}
		}
	}

	private static inline function writeFieldKey(output : ProtobufOutput, fieldNumber : Int, wireType : Int) : Void
	{
		writeVarInt(output, Int64.ofInt((fieldNumber << 3) | wireType));
	}

	public static inline function writeFieldDataVarInt(output : ProtobufOutput, value : Int64) : Void
	{
		writeVarInt(output, value);
	}

	// TODO: Check endianness.
	public static inline function writeFieldData32Bit(output : ProtobufOutput, value : Int) : Void
	{
		output.writeInt32(value);
	}

	// TODO: Check endianness.
	public static inline function writeFieldData64Bit(output : ProtobufOutput, value : Int64) : Void
	{
		output.writeByte(Int64.toInt(Int64.shr(value, 56)));
		output.writeByte(Int64.toInt(Int64.shr(value, 48)));
		output.writeByte(Int64.toInt(Int64.shr(value, 40)));
		output.writeByte(Int64.toInt(Int64.shr(value, 32)));
		output.writeByte(Int64.toInt(Int64.shr(value, 24)));
		output.writeByte(Int64.toInt(Int64.shr(value, 16)));
		output.writeByte(Int64.toInt(Int64.shr(value, 8)));
		output.writeByte(Int64.toInt(Int64.shr(value, 0)));
	}

	public static inline function writeFieldDataLengthDelimited(output : ProtobufOutput, bytes : Bytes) : Void
	{
		writeVarInt(output, Int64.ofInt(bytes.length));
		output.writeBytes(bytes, 0, bytes.length);
	}

	private static inline function writeVarInt(output : ProtobufOutput, value : Int64) : Void
	{
		do
		{
			var byte : Int = Int64.toInt(Int64.and(value, Int64.ofInt((1 << 7) - 1)));

			value = Int64.shr(value, 7);

			if (!Int64.isZero(value))
			{
				byte |= (1 << 7);
			}

			output.writeByte(byte);

		} while  (!Int64.isZero(value));
	}
}
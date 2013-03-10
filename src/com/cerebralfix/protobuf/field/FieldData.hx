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

enum FieldData
{
	VarInt(value : Int64);
	ThirtyTwoBit(value : Int);
	SixtyFourBit(value : Int64);
	LengthDelimited(value : Bytes);
	//StartGroup;
	//EndGroup;
	Unknown;
	Incomplete;
}
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

package com.cerebralfix.protobuf.test;

import com.cerebralfix.protobuf.fieldtypes.BoolField;
import com.cerebralfix.protobuf.fieldtypes.BytesField;
import com.cerebralfix.protobuf.fieldtypes.DoubleField;
import com.cerebralfix.protobuf.fieldtypes.EnumField;
import com.cerebralfix.protobuf.fieldtypes.Fixed32Field;
import com.cerebralfix.protobuf.fieldtypes.Fixed64Field;
import com.cerebralfix.protobuf.fieldtypes.FloatField;
import com.cerebralfix.protobuf.fieldtypes.Int32Field;
import com.cerebralfix.protobuf.fieldtypes.Int64Field;
import com.cerebralfix.protobuf.fieldtypes.SFixed32Field;
import com.cerebralfix.protobuf.fieldtypes.SFixed64Field;
import com.cerebralfix.protobuf.fieldtypes.SInt32Field;
import com.cerebralfix.protobuf.fieldtypes.SInt64Field;
import com.cerebralfix.protobuf.fieldtypes.StringField;
import com.cerebralfix.protobuf.fieldtypes.UInt32Field;
import com.cerebralfix.protobuf.fieldtypes.UInt64Field;
import com.cerebralfix.protobuf.fieldtypes.RepeatedField;

class TestMessage implements com.cerebralfix.protobuf.Message
{
	@:fieldNumber(1) public var testField1:BoolField;
	@:fieldNumber(2) public var testField2:BytesField;
	@:fieldNumber(3) public var testField3:DoubleField;
	//@:fieldNumber(4) public var testField4:EnumField;
	@:fieldNumber(5) public var testField5:Fixed32Field;
	@:fieldNumber(6) public var testField6:Fixed64Field;
	@:fieldNumber(7) public var testField7:FloatField;
	@:fieldNumber(8) public var testField8:Int32Field;
	@:fieldNumber(9) public var testField9:Int64Field;
	@:fieldNumber(10) public var testField10:SFixed32Field;
	@:fieldNumber(11) public var testField11:SFixed64Field;
	@:fieldNumber(12) public var testField12:SInt32Field;
	@:fieldNumber(13) public var testField13:SInt64Field;
	@:fieldNumber(14) public var testField14:StringField;
	@:fieldNumber(15) public var testField15:UInt32Field;
	@:fieldNumber(16) public var testField16:UInt64Field;
	@:fieldNumber(17) public var testField17:RepeatedField<Int32Field>;

	public function new()
	{

	}
}
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
import haxe.io.BytesBuffer;
import haxe.io.BytesOutput;

@:generic class MessageField<TMessage : (Message, {function new():Void;})> implements Field
{
	public var _message:TMessage;

	public inline function new()
	{
		_message = new TMessage();
		_message.initializeMessageFields();
	}

	public inline function readFrom(data:FieldData):Void
	{
		switch (data)
		{
			case LengthDelimited(bytes):
			{
				_message.readMessageFields(new BytesReader(bytes));
			}

			default: {}
		}
	}

	public inline function write():Array<FieldData>
	{
		if (_message != null)
		{
			var output = new BytesOutput();
			_message.writeMessageFields(output);
			var bytes = output.getBytes();

			return [LengthDelimited(bytes)];
		}
		else
		{
			return [];
		}
	}

	public inline function isSet():Bool
	{
		return _message != null;
	}
}
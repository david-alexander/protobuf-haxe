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

package com.cerebralfix.protobuf.stream;

import com.cerebralfix.protobuf.utilities.BytesReader;
import haxe.io.Bytes;

@:generic class MessageDataDecoder<TBaseMessage : (Message, {function new():Void;})>
{
	private var _bytes:Bytes;
	private var HEADER_LENGTH:Int = 4;

	public function new():Void
	{

	}

	public function appendBytes(bytes:Bytes):Void
	{
		var newBytes:Bytes = Bytes.alloc( ((_bytes != null) ? _bytes.length : 0) + bytes.length );
		var pos:Int = 0;

		if (_bytes != null)
		{
			newBytes.blit(pos, _bytes, 0, _bytes.length);
			pos += _bytes.length;
		}

		newBytes.blit(pos, bytes, 0, bytes.length);
		pos += bytes.length;

		_bytes = newBytes;
	}

	public function hasMessage():Bool
	{
		if (_bytes == null) return false;

		var messageLength = getMessageLength();
		return messageLength != null && (_bytes.length - HEADER_LENGTH) >= messageLength;
	}

	public function getMessage():TBaseMessage
	{
		if (_bytes == null) return null;

		if (hasMessage())
		{
			var messageLength = getMessageLength();
			var messageBytes = _bytes.sub(HEADER_LENGTH, messageLength);
			var message = new TBaseMessage();
			message.initializeMessageFields();
			message.readMessageFields(new BytesReader(messageBytes));
			consumeBytes(HEADER_LENGTH + messageLength);
			return message;
		}

		return null;
	}

	private inline function getMessageLength():Null<Int>
	{
		return (_bytes != null) ? int32AtPosition(_bytes, 0) : null;
	}

	private inline function consumeBytes(numBytes:Int):Void
	{
		if (_bytes != null)
		{
			if (numBytes >= _bytes.length)
			{
				_bytes = null;
			}
			else
			{
				var newBytes = Bytes.alloc(_bytes.length - numBytes);
				newBytes.blit(0, _bytes, numBytes, (_bytes.length - numBytes));
				_bytes = newBytes;
			}
		}
	}

	private inline function int32AtPosition(bytes:Bytes, pos:Int):Null<Int>
	{
		var result:Null<Int> = null;

		if ((pos + 4) <= bytes.length)
		{
			var b1:Int = bytes.get(pos);
			var b2:Int = bytes.get(pos + 1);
			var b3:Int = bytes.get(pos + 2);
			var b4:Int = bytes.get(pos + 3);

			result = (b4 << 24) | (b3 << 16) | (b2 << 8) | (b1 << 0);
		}

		return result;
	}
}

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

import haxe.ds.ObjectMap;

@:generic class MessageDispatcher<TBaseMessage : (Message, {function new():Void;})>
{
	private var _handlers:ObjectMap<String, Message -> Void>;

	public function new():Void
	{
		_handlers = new ObjectMap<String, Message -> Void>();
	}

	@:generic public function registerMessageHandler<TMessage : (Message, {function new():Void;})>(handler : TMessage -> Void):Void
	{
		_handlers.set(new TMessage().getMessageTypeId(), function(message:Message):Void
			{
				handler(untyped message);
			}
		);
	}

	public function dispatchMessage(baseMessage:TBaseMessage):Void
	{
		var message = baseMessage.getActiveSubmessage();

		if (message != null)
		{
			var messageTypeId = message.getMessageTypeId();

			if (_handlers.exists(messageTypeId))
			{
				var handler = _handlers.get(messageTypeId);
				handler(message);
			}
		}
	}
}

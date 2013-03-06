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

import com.cerebralfix.protobuf.stream.FlashMessageOutput;
import com.cerebralfix.protobuf.stream.MessageDataDecoder;
import com.cerebralfix.protobuf.stream.MessageDispatcher;
import com.cerebralfix.protobuf.utilities.BytesReader;
import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.Endian;
import haxe.io.Bytes;

class Main
{
	private static var _socket:Socket;
	private static var _decoder:MessageDataDecoder<BaseMessage>;
	private static var _dispatcher:MessageDispatcher<BaseMessage>;
	private static var _output:FlashMessageOutput;

	private static var _messageView:TextField;
	private static var _messageField:TextField;

	private static var _isWaitingForUsername:Bool;
	private static var _isLoggedIn:Bool;

	public static function main():Void
	{
		setUpStage();

		_socket = new Socket();
		_socket.endian = Endian.LITTLE_ENDIAN;
		_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

		_decoder = new MessageDataDecoder<BaseMessage>();

		_dispatcher = new MessageDispatcher<BaseMessage>();
		_dispatcher.registerMessageHandler(onConnectionResponseMessage);
		_dispatcher.registerMessageHandler(onLoginResponseMessage);
		_dispatcher.registerMessageHandler(onNewUserResponseMessage);
		_dispatcher.registerMessageHandler(onChatResponseMessage);

		_output = new FlashMessageOutput(_socket);

		_socket.connect("localhost", 1234);
	}

	public static function setUpStage():Void
	{
		var stage = Lib.current;

		_messageView = new TextField();
		_messageField = new TextField();

		stage.addChild(_messageView);
		stage.addChild(_messageField);

		//_messageField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	public static function onConnectionResponseMessage(message:ConnectionResponseMessage):Void
	{
		login();
	}

	public static function login():Void
	{
		_messageView.appendText("Enter your username:\n");
		_isWaitingForUsername = true;
	}

	public static function onLoginResponseMessage(message:LoginResponseMessage):Void
	{
		if (message.logged_in._value)
		{
			trace("Logged in.");
			_isLoggedIn = true;
		}
		else
		{
			_isLoggedIn = false;
			login();
		}
	}

	public static function onNewUserResponseMessage(message:NewUserResponseMessage):Void
	{
		_messageView.appendText("User Joined: " + message.username + "\n");
	}

	public static function onChatResponseMessage(message:ChatResponseMessage):Void
	{
		_messageView.appendText(message.username + ": " + message.message + "\n");
	}

	public static function onKeyUp(event:KeyboardEvent):Void
	{
		trace("TEST");
		if (event.keyCode == 13) // carriage return
		{
			var baseMessage = new BaseMessage();

			if (_isLoggedIn)
			{
				var message = new ChatRequestMessage();
				message.message._string = _messageField.text;

				baseMessage.chat_request_message._message = message;
			}
			else if (_isWaitingForUsername)
			{
				var message = new LoginRequestMessage();
				message.username._string = _messageField.text;

				baseMessage.login_request_message._message = message;

				_isWaitingForUsername = false;
			}

			_output.writeMessage(baseMessage);
			_messageField.text = "";
		}
	}

	public static function onSocketData(event:ProgressEvent):Void
	{
		if (_socket.bytesAvailable > 0)
		{
			var bytes:ByteArray = new ByteArray();
			_socket.readBytes(bytes, 0, _socket.bytesAvailable);
			_decoder.appendBytes(Bytes.ofData(bytes));

			if (_decoder.hasMessage())
			{
				var message = _decoder.getMessage();
				_dispatcher.dispatchMessage(message);
			}
		}
	}
}
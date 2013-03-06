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

		_socket.connect("localhost", 8999);
	}

	public static function setUpStage():Void
	{
		var stage = Lib.current;

		_messageView = new TextField();
		_messageView.width = 300;
		_messageView.height = 200;
		_messageView.border = true;
		_messageView.x = 20;
		_messageView.y = 20;
		stage.addChild(_messageView);

		_messageField = new TextField();
		_messageField.width = 300;
		_messageField.height = 20;
		_messageField.x = 20;
		_messageField.y = 225;
		_messageField.border = true;
		_messageField.type = INPUT;
		stage.addChild(_messageField);

		_messageField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		// Disable tracing to the screen.
		haxe.Log.trace = function( v : Dynamic, ?inf : haxe.PosInfos ) { };
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
		printText("User Joined: " + message.username._string + "\n");
	}

	public static function onChatResponseMessage(message:ChatResponseMessage):Void
	{
		printText(message.username._string + ": " + message.message._string + "\n");
	}

	public static function printText(text:String):Void
	{
		_messageView.appendText(text);
		_messageView.scrollV = _messageView.maxScrollV;
	}

	public static function onKeyUp(event:KeyboardEvent):Void
	{
		if (event.keyCode == 13) // carriage return
		{
			var baseMessage = new BaseMessage();
			baseMessage.initializeMessageFields();

			if (_isLoggedIn)
			{
				var message = new ChatRequestMessage();
				message.initializeMessageFields();
				message.message._string = _messageField.text;

				baseMessage.chat_request_message._message = message;
			}
			else if (_isWaitingForUsername)
			{
				var message = new LoginRequestMessage();
				message.initializeMessageFields();
				message.username._string = _messageField.text;

				baseMessage.login_request_message._message = message;

				_isWaitingForUsername = false;
			}

			_output.writeMessage(baseMessage);
			_socket.flush();
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
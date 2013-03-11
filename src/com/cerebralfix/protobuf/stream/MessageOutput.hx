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

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Output;

@:generic class MessageOutput<TBaseMessage : (Message, {function new():Void;})>
{
	private var _output:Output;

	public function new(output:Output):Void
	{
		_output = output;
	}

	public function writeMessage(message:Message):Void
	{
		var baseMessage = new TBaseMessage();
		baseMessage.setActiveSubmessage(message);

		var bytesOutput:BytesOutput = new BytesOutput();
		baseMessage.writeMessageFields(bytesOutput);

		var bytes:Bytes = bytesOutput.getBytes();

		_output.writeInt(bytes.length);
		_output.writeBytes(bytes);
	}
}

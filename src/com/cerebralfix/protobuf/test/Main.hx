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

import com.cerebralfix.protobuf.utilities.BytesReader;
import cpp.io.File;
import haxe.io.Bytes;

class Main
{
	public static function main():Void
	{
		if (Sys.args().length > 0)
		{
			var filename = Sys.args()[0];
			var file = File.read(filename);

			var bytes = file.readAll();
			var bytesReader = new BytesReader(bytes);

			var message = new TestMessage();
			message.initializeMessageFields(); // TODO: Make the initialisation happen automatically.
			message.readMessageFields(bytesReader);

			trace(message.testField14._string);
		}
		else
		{
			trace("No command-line arguments given.");
		}
	}
}
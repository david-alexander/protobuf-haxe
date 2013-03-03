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

@:generic class RepeatedField<TField : (Field, {function new():Void;})> implements Field
{
	public var _fields:Array<TField>;

	public function new()
	{
		_fields = [];
	}

	public function readFrom(data:FieldData):Void
	{
		var field = new TField();

		field.readFrom(data);

		if (field.isSet())
		{
			_fields.push(field);
		}
	}

	public function write():Array<FieldData>
	{
		var results:Array<FieldData> = [];

		for (field in _fields)
		{
			results = results.concat(field.write());
		}

		return results;
	}

	public function isSet():Bool
	{
		return true;
	}

	public function get(index:Int):TField
	{
		return _fields[index];
	}

	public function push(field:TField):Void
	{
		_fields.push(field);
	}

	@:generic public inline function newEntry():TField
	{
		var field = new TField();
		_fields.push(field);
		return field;
	}
}
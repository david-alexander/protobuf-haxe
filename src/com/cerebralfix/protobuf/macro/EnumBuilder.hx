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

package com.cerebralfix.protobuf.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class EnumBuilder
{
	public macro static function buildEnum() : Array<Field>
	{
		var fields = Context.getBuildFields();

		var typeParameter = getTypeParameter();

		if (typeParameter == null)
		{
			return fields;
		}

		var enumFields = getParameterlessEnumFields(typeParameter);

		var decodeCases:Array<Case> = [];
		var encodeCases:Array<Case> = [];

		for (enumField in enumFields)
		{
			var metadata = getMetadataForEnumField(enumField);

			var enumConstantExpr = macro $v{metadata.enumConstant};
			var enumFieldExpr = macro $i{enumField.name};

			decodeCases.push({
				values: [enumConstantExpr],
				guard: null,
				expr: enumFieldExpr
			});

			encodeCases.push({
				values: [enumFieldExpr],
				guard: null,
				expr: enumConstantExpr
			});
		}

		var decodeSwitch = MacroUtilities.expr(ExprDef.ESwitch(macro int, decodeCases, macro null));
		var encodeSwitch = MacroUtilities.expr(ExprDef.ESwitch(macro enumValue, encodeCases, null));

		var typeParameterComplexType = Context.toComplexType(typeParameter);

		var decodeFunc = MacroUtilities.functionFieldFromExpression(macro function enumValueFromInt(int:Int):Null<$typeParameterComplexType> {
			return $decodeSwitch;
		});

		var encodeFunc = MacroUtilities.functionFieldFromExpression(macro function intFromEnumValue(enumValue:$typeParameterComplexType):Int
		{
			return $encodeSwitch;
		});

		return fields.concat([decodeFunc, encodeFunc]);
	}

	private static function getTypeParameter() : Null<Type>
	{
		var typeParams = MacroUtilities.getTypeParametersForImplementedInterface(Context.getLocalClass().get(), MacroUtilities.getClassTypeByName("com.cerebralfix.protobuf.EnumDecoder"));

		if (typeParams.length == 1)
		{
			return typeParams[0];
		}
		return null;
	}

	private static function getParameterlessEnumFields(type:Type) : Array<EnumField>
	{
		var result = [];

		switch (type)
		{
			case TEnum(enumTypeRef, _):
			{
				var enumType = enumTypeRef.get();

				for (constructor in enumType.constructs)
				{
					if (constructor.params.length == 0)
					{
						result.push(constructor);
					}
				}
			}

			default: {}
		}

		return result;
	}

	private static function getMetadataForEnumField(field:EnumField):{enumConstant : Int}
	{
		var enumConstant = -1; // TODO: Use a proper error value.

		for (entry in field.meta.get())
		{
			if (entry.name == ":enumConstant" && entry.params.length > 0)
			{
				switch (entry.params[0].expr)
				{
					case EConst(CInt(value)):
					{
						enumConstant = Std.parseInt(value);
					}

					default: {}
				}
			}
		}

		return {enumConstant: enumConstant};
	}
}
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

package com.cerebralfix.protobuf;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MessageBuilder
{
	public macro static function build() : Array<Field>
	{
		var fields = Context.getBuildFields();

		var fieldInterface = getFieldInterface();

		var initExprs = new Array<Expr>();
		var readCases = new Array<Case>();
		var writeExprs = new Array<Expr>();

		for (field in fields)
		{
			switch (field.kind)
			{
				case FVar(complexType, _): // TODO: Support properties.
				{
					switch (resolveComplexType(complexType))
					{
						case TInst(classTypeRef, _):
						{
							if (implementsInterface(classTypeRef.get(), fieldInterface))
							{
								// TODO: Pass the correct type parameters.
								addField(field, complexType, [], classTypeRef.get(), field.name, initExprs, readCases, writeExprs);
							}
						}

						default: {}
					}
				}

				default: {}
			}
		}

		var initBlock = expr(ExprDef.EBlock(initExprs));
		var readSwitch = expr(ExprDef.ESwitch(macro fieldData.fieldNumber, readCases, null));
		var writeBlock = expr(ExprDef.EBlock(writeExprs));

		var initFunc = functionFieldFromExpression(macro function initializeMessageFields():Void { $initBlock; } );

		var readFunc = functionFieldFromExpression(
			macro function readMessageFields(input:com.cerebralfix.protobuf.utilities.BytesReader):Bool {

				var result = true;

				while (input.hasByte())
				{
					var fieldData = FieldDataReader.readFieldData(input);

					trace("FieldDataReader.readFieldData returned " + Std.string(fieldData));

					switch (fieldData.data)
					{
						case Incomplete:
						{
							result = false;
						}

						default:
						{
							$readSwitch;
						}
					}
				}

				// TODO: This currently returns true as long as the buffer doesn't end in the middle of a field.
				//       It doesn't necessarily mean you've got the entire packet.
				//       A length prefix may be needed (as in the C# version - see http://stackoverflow.com/questions/586819/how-to-detect-when-a-protocol-buffer-message-is-fully-received).
				return result;
			}
		);

		var writeFunc = functionFieldFromExpression(
			macro function writeMessageFields(output:haxe.io.Output):Void {
				$writeBlock;
			}
		);

		return fields.concat([initFunc, readFunc, writeFunc]);
	}

	private static function addField(field : Field, fieldType : ComplexType, typeParams: Array<Expr>, fieldClassType : ClassType, fieldName : String, initExprs : Array<Expr>, readCases : Array<Case>, writeExprs : Array<Expr>) : Void
	{
		switch (fieldType)
		{
			case TPath(fieldTypePath):
			{
				var metadata = getMetadataForMessageField(field);
				var fieldNumberExpr = expr(EConst(CInt(Std.string(metadata.fieldNumber))));

				var fieldExpr = expr(ExprDef.EConst(Constant.CIdent(fieldName)));
				var newExpr = expr(ExprDef.ENew(fieldTypePath, typeParams));

				var initExpr = macro $fieldExpr = $newExpr;

				var readCase =
					{
						values: [fieldNumberExpr],
						guard: null,
						expr: macro $fieldExpr.readFrom(fieldData.data)
					};

				var writeExpr = macro {
					for (fieldData in $fieldExpr.write())
					{
						trace("Writing data for field " + Std.string($fieldNumberExpr));
						FieldDataWriter.writeFieldData(output, $fieldNumberExpr, fieldData);
					}
				};

				initExprs.push(initExpr);
				readCases.push(readCase);
				writeExprs.push(writeExpr);
			}

			default:
			{

			}
		}
	}

	private static function implementsInterface(t:ClassType, targetInterface:ClassType):Bool
	{
		for (implementedInterfaceRef in t.interfaces)
		{
			if (implementedInterfaceRef.t.get().name == targetInterface.name)
			{
				return true;
			}
		}

		if (t.superClass != null && implementsInterface(t.superClass.t.get(), targetInterface))
		{
			return true;
		}

		return false;
	}

	private static function getFieldInterface():ClassType
	{
		switch (resolveComplexType(macro : com.cerebralfix.protobuf.Field))
		{
			case TInst(classTypeRef, _):
			{
				return classTypeRef.get();
			}

			default:
			{
				return null;
			}
		}
	}

	private static function functionFieldFromExpression(expr:Expr):Field
	{
		switch (expr.expr) {
			case EFunction(name, f):
			{
				return { pos: getPosition(), name: name, meta: [], kind: FFun(f), doc: null, access: [APublic, AInline] };
			}

			default:
			{
				return null;
			}
		}
	}

	private static function getMetadataForMessageField(field:Field):{fieldNumber : Int}
	{
		var fieldNumber = -1; // TODO: Use a proper error value.

		for (entry in field.meta)
		{
			if (entry.name == ":fieldNumber" && entry.params.length > 0)
			{
				switch (entry.params[0].expr)
				{
					case EConst(c):
					{
						switch (c)
						{
							case CInt(value):
							{
								fieldNumber = Std.parseInt(value);
							}

							default: {}
						}
					}

					default: {}
				}
			}
		}

		return {fieldNumber: fieldNumber};
	}

	// TODO: Figure out why Context.currentPos() doesn't return the right thing.
	private static function getPosition():Position
	{
		//var currentPos = Context.currentPos();
		return Context.makePosition({min: 0, max: 0, file: ""});
	}

	// From http://en.usenet.digipedia.org/thread/14424/1626/
	private static function resolveComplexType(t:ComplexType):Type
	{
		return Context.typeof( 
			expr(EBlock([
				expr(EVars([ { name:'_', type: t, expr: null } ])),
				expr(EConst(CIdent('_')))
				]))
			);
	}

	private static function expr(e:ExprDef):Expr
	{
		// TODO: Use the position of the existing field, where applicable.
		return { expr:e, pos: getPosition() };
	}
}
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

import com.cerebralfix.protobuf.MessageTypeId;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MessageBuilder
{
	public macro static function buildMessage() : Array<Field>
	{
		var readCases = new Array<Case>();
		var writeExprs = new Array<Expr>();
		var submessageExprs = new Array<Expr>();

		var fields = Context.getBuildFields();
		var fieldInterface = MacroUtilities.classTypeFromComplexType(macro : com.cerebralfix.protobuf.field.Field);

		for (fieldInfo in MacroUtilities.getDataFieldsImplementingInterface(fields, fieldInterface))
		{
			addField(fieldInfo, readCases, writeExprs, submessageExprs);
		}

		var readSwitch = MacroUtilities.expr(ExprDef.ESwitch(macro fieldData.fieldNumber, readCases, null));
		var writeBlock = MacroUtilities.expr(ExprDef.EBlock(writeExprs));

		var readFunc = MacroUtilities.functionFieldFromExpression(
			macro function readMessageFields(input:com.cerebralfix.protobuf.utilities.BytesReader):Bool {

				var result = true;

				while (input.hasByte())
				{
					var fieldData = com.cerebralfix.protobuf.field.FieldDataReader.readFieldData(input);

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

				// NOTE: This currently returns true as long as the buffer doesn't end in the middle of a field.
				//       It doesn't necessarily mean you've got the entire packet.
				//       For that, use MessageDataDecoder and MessageOutput, which include a length prefix before the message itself.
				return result;
			}
		);

		var writeFunc = MacroUtilities.functionFieldFromExpression(
			macro function writeMessageFields(output:haxe.io.Output):Void {
				$writeBlock;
			}
		);

		var submessageBlock = MacroUtilities.expr(ExprDef.EBlock(submessageExprs));

		var typeFunc = MacroUtilities.functionFieldFromExpression(macro function getMessageTypeId():com.cerebralfix.protobuf.MessageTypeId { return $v{MacroUtilities.getMangledName(Context.getLocalClass().get())}; });

		var submessageFunc = MacroUtilities.functionFieldFromExpression(
			macro function getActiveSubmessage():com.cerebralfix.protobuf.Message {
				$submessageBlock;
				return null;
			}
		);

		return fields.concat([readFunc, writeFunc, typeFunc, submessageFunc]);
	}

	private static function addField(fieldInfo : MacroUtilities.FieldInfo, readCases : Array<Case>, writeExprs : Array<Expr>, submessageExprs:Array<Expr>) : Void
	{
		var metadata = getMetadataForMessageField(fieldInfo.field);
		var fieldNumberExpr = MacroUtilities.expr(EConst(CInt(Std.string(metadata.fieldNumber))));

		var fieldExpr = MacroUtilities.expr(ExprDef.EConst(Constant.CIdent(fieldInfo.field.name)));

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
				com.cerebralfix.protobuf.field.FieldDataWriter.writeFieldData(output, $fieldNumberExpr, fieldData);
			}
		};

		readCases.push(readCase);
		writeExprs.push(writeExpr);

		checkForSubmessage(fieldInfo.classType, fieldExpr, submessageExprs);
	}

	private static function checkForSubmessage(fieldClassType : ClassType, fieldExpr:Expr, submessageExprs:Array<Expr>):Void
	{
		if (fieldClassType.name.indexOf("MessageField") == 0)
		{
			submessageExprs.push(macro
				{
					if ($fieldExpr.isSet())
					{
						return $fieldExpr.value;
					}
				}
			);
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
					case EConst(CInt(value)):
					{
						fieldNumber = Std.parseInt(value);
					}

					default: {}
				}
			}
		}

		return {fieldNumber: fieldNumber};
	}
}
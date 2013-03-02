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
	@:macro public static function build() : Array<Field>
	{
		var fields = Context.getBuildFields();

		var fieldInterface = getFieldInterface();

		var initExprs = new Array<Expr>();
		var readExprs = new Array<Expr>();

		for (field in fields)
		{
			switch (field.kind)
			{
				case FVar(complexType, expr): // TODO: Support properties.
				{
					switch (resolveComplexType(complexType))
					{
						case TInst(classTypeRef, typeParams):
						{
							if (implementsInterface(classTypeRef.get(), fieldInterface))
							{
								addField(complexType, field.name, initExprs, readExprs);
							}
						}

						default: {}
					}
				}

				default: {}
			}
		}

		var initBlock = expr(ExprDef.EBlock(initExprs));
		var readBlock = expr(ExprDef.EBlock(readExprs));

		var initFunc = functionFieldFromExpression(macro function initializeMessageFields():Void { $initBlock; } );
		var readFunc = functionFieldFromExpression(macro function readMessageFields(input:BytesReader):Void { $readBlock; } );

		return fields.concat([initFunc, readFunc]);
	}

	private static function addField(fieldType : ComplexType, fieldName : String, initExprs : Array<Expr>, readExprs : Array<Expr>) : Void
	{
		switch (fieldType)
		{
			case TPath(fieldTypePath):
			{
				var fieldExpr = expr(ExprDef.EConst(Constant.CIdent(fieldName)));
				var newExpr = expr(ExprDef.ENew(fieldTypePath, []));

				var initExpr = macro $fieldExpr = $newExpr;
				var readExpr = macro $fieldExpr.readFrom(input);

				initExprs.push(initExpr);
				readExprs.push(readExpr);
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
			case TInst(classTypeRef, typeParams):
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
				return { pos: Context.currentPos(), name: name, meta: [], kind: FFun(f), doc: null, access: [APublic, AInline] };
			}

			default:
			{
				return null;
			}
		}
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
		return { expr:e, pos: Context.currentPos() };
	}
}
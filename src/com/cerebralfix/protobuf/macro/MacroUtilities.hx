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

typedef FieldInfo = {field : Field, classType : ClassType, constructorExprDef : ExprDef};

class MacroUtilities
{
	/**
	 	Gets information on all of the fields from the given array that are data fields whose data types implement the specified interface.
	 	@param	fields				The fields.
	 	@param	targetInterface		The interface.
	 	@return	An array of FieldInfo structs, each containing information on a data field whose data type implements the specified interface.
	 **/
	public static function getDataFieldsImplementingInterface(fields:Array<Field>, targetInterface:ClassType):Array<FieldInfo>
	{
		var result:Array<FieldInfo> = [];

		for (field in fields)
		{
			switch (field.kind)
			{
				case FVar(complexType, _) | FProp(_, _, complexType, _):
				{
					var classType = classTypeFromComplexType(complexType);
					var typePath = typePathFromComplexType(complexType);

					if (classType != null && implementsInterface(classType, targetInterface) && typePath != null)
					{
						// TODO: Use the correct type parameters.
						var typeParams:Array<Expr> = [];
						result.push({field: field, classType: classType, constructorExprDef: ExprDef.ENew(typePath, typeParams)});
					}
				}

				default: {}
			}
		}

		return result;
	}

	/**
	 	Determines whether the given class implements the given interface.
	 	@param	t					The class.
	 	@param	targetInterface		The interface.
	 	@return	True if the class implements the given interface; false otherwise.
	 **/
	public static function implementsInterface(t:ClassType, targetInterface:ClassType):Bool
	{
		return getTypeParametersForImplementedInterface(t, targetInterface) != null;
	}

	public static function getTypeParametersForImplementedInterface(t:ClassType, targetInterface:ClassType):Array<Type>
	{
		for (implementedInterfaceRef in t.interfaces)
		{
			if (implementedInterfaceRef.t.get().name == targetInterface.name)
			{
				return implementedInterfaceRef.params;
			}

			var parentParams = getTypeParametersForImplementedInterface(implementedInterfaceRef.t.get(), targetInterface);

			if (parentParams != null)
			{
				return parentParams;
			}
		}

		if (t.superClass != null)
		{
			var parentParams = getTypeParametersForImplementedInterface(t.superClass.t.get(), targetInterface);

			if (parentParams != null)
			{
				return parentParams;
			}
		}

		return null;
	}

	/**
	 	Creates a Field that uses the function defined in the given expression (assumed to contain an ExprDef.EFunction instance) as a method to be added to a class.
	 	@param	expr	An Expr that directly contains a function to be wrapped in a Field.
	 	@return	The Field.
	 **/
	public static function functionFieldFromExpression(expr:Expr):Field
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

	/**
	 	Gets the current source position, to be used in expressions and/or compiler warnings and errors.
	 	@return	The position.
	 **/
	public static function getPosition():Position
	{
		// TODO: Figure out why Context.currentPos() doesn't return the right thing.
		//var currentPos = Context.currentPos();
		return Context.makePosition({min: 0, max: 0, file: ""});
	}

	/**
	 	Gets a string that uniquely names the given ClassType.
	 	@return	A string that uniquely names the given ClassType.
	 **/
	public static function getMangledName(classType:ClassType)
	{
		return "_" + classType.pack.join("_") + classType.name;
	}

	/**
	 	Converts a ComplexType into a Type.
	 	@param	ComplexType		A ComplexType.
	 	@return	The Type that corresponds to the given ComplexType.
	 **/
	public static function resolveComplexType(t:ComplexType):Type
	{
		// From http://en.usenet.digipedia.org/thread/14424/1626/
		return Context.typeof( 
			expr(EBlock([
				expr(EVars([ { name:'_', type: t, expr: null } ])),
				expr(EConst(CIdent('_')))
				]))
			);
	}

	/**
	 	Converts a ComplexType into a ClassType.
	 	@param	ComplexType		A ComplexType.
	 	@return	The ClassType that corresponds to the given ComplexType.
	 **/
	public static function classTypeFromComplexType(complexType:ComplexType):ClassType
	{
		switch (resolveComplexType(complexType))
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

	public static function typePathFromComplexType(complexType:ComplexType):TypePath
	{
		return switch (complexType)
		{
			case TPath(typePath): typePath;
			default: null;
		}
	}

	public static function getClassTypeByName(name:String):ClassType
	{
		switch (Context.getType(name))
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

	/**
	 	Creates an Expr from the given ExprDef, at the current source position.
	 	@param	e		An ExprDef.
	 	@return	An Expr containing the given ExprDef.
	 **/
	public static function expr(e:ExprDef):Expr
	{
		// TODO: Use the position of the existing field, where applicable.
		return { expr:e, pos: getPosition() };
	}
}
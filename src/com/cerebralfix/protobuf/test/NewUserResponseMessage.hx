// Generated by the protocol buffer compiler.  DO NOT EDIT!

package com.cerebralfix.protobuf.test;

/**
  	 A message send by the server to all clients when a new user logs in.
 **/
class NewUserResponseMessage implements com.cerebralfix.protobuf.Message {
  public function new():Void { }

  @:fieldNumber(1)
  /**
    	 The username of the new user.
   **/
  public var username (default, null) : com.cerebralfix.protobuf.fieldtypes.StringField;
}

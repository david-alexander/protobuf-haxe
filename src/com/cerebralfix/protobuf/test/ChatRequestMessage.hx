// Generated by the protocol buffer compiler.  DO NOT EDIT!

package com.cerebralfix.protobuf.test;

/**
  	 A message sent by the client when the user wishes to send a chat message to the other users.
 **/
class ChatRequestMessage implements com.cerebralfix.protobuf.Message {
  public function new():Void { }

  @:fieldNumber(1)
  /**
    	 The message to send.
   **/
  public var message (default, null) : com.cerebralfix.protobuf.fieldtypes.StringField;
}

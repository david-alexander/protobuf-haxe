// Generated by the protocol buffer compiler.  DO NOT EDIT!

package com.cerebralfix.protobuf.test;

/**
  	 A union message containing all other types of messages that we want to send and receive.
 **/
class BaseMessage implements com.cerebralfix.protobuf.Message {

  @:fieldNumber(1)
  public var connection_response_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ConnectionResponseMessage>;

  @:fieldNumber(2)
  public var login_request_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.LoginRequestMessage>;

  @:fieldNumber(3)
  public var login_response_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.LoginResponseMessage>;

  @:fieldNumber(4)
  public var chat_request_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ChatRequestMessage>;

  @:fieldNumber(5)
  public var chat_response_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ChatResponseMessage>;

  @:fieldNumber(6)
  public var new_user_response_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.NewUserResponseMessage>;

  @:fieldNumber(7)
  public var user_disconnected_response_message (default, null) : com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.UserDisconnectedResponseMessage>;
  public function new():Void
  {
    connection_response_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ConnectionResponseMessage>();
    login_request_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.LoginRequestMessage>();
    login_response_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.LoginResponseMessage>();
    chat_request_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ChatRequestMessage>();
    chat_response_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.ChatResponseMessage>();
    new_user_response_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.NewUserResponseMessage>();
    user_disconnected_response_message = new com.cerebralfix.protobuf.fieldtypes.MessageField<com.cerebralfix.protobuf.test.UserDisconnectedResponseMessage>();
  }

}

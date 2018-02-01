import 'dart:async';

import 'dart:ui';
import 'package:flutter/services.dart';

typedef void AvailabilityHandler(bool result);
typedef void StringResultHandler(String text);
typedef void IntResultHandler(int i);

/// the channel to control the speech recognition
class SpeechRecognition {
  static const MethodChannel _channel =
      const MethodChannel('speech_recognition');

  static final SpeechRecognition _speech = new SpeechRecognition._internal();

  factory SpeechRecognition() => _speech;

  SpeechRecognition._internal() {
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  AvailabilityHandler availabilityHandler;
  AvailabilityHandler permissionHandler;
  StringResultHandler currentLocaleHandler;
  StringResultHandler recognitionResultHandler;
  IntResultHandler errorHandler;
  VoidCallback recognitionStartedHandler;

  VoidCallback recognitionCompleteHandler;

  /// ask for speech  recognizer permission
  Future<bool> activate() => _channel.invokeMethod("speech.activate");

  /// start listening
  Future listen({String locale}) =>
      _channel.invokeMethod("speech.listen", locale);

  Future cancel() => _channel.invokeMethod("speech.cancel");

  Future stop() => _channel.invokeMethod("speech.stop");

  Future requestPermissions() => _channel.invokeMethod("speech.requestPermissions");

  Future _platformCallHandler(MethodCall call) async {
    print("_platformCallHandler call ${call.method} ${call.arguments}");
    switch (call.method) {
      case "speech.onSpeechAvailability":
        availabilityHandler(call.arguments);
        break;
      case "speech.onPermission":
        permissionHandler(call.arguments);
        break;
      case "speech.onCurrentLocale":
        currentLocaleHandler(call.arguments);
        break;
      case "speech.onSpeech":
        recognitionResultHandler(call.arguments);
        break;
      case "speech.onError":
        errorHandler(call.arguments);
        break;
      case "speech.onRecognitionStarted":
        recognitionStartedHandler();
        break;
      case "speech.onRecognitionComplete":
        recognitionCompleteHandler();
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }


  Future<bool> hasPermission() async {
      return await _channel.invokeMethod("speech.hasPermissions");
  }
  
  // define a method to handle availability / permission result
  void setPermissionHandler(AvailabilityHandler handler) =>
      permissionHandler = handler;

  // define a method to handle availability / permission result
  void setAvailabilityHandler(AvailabilityHandler handler) =>
      availabilityHandler = handler;

  // define a method to handle recognition result
  void setRecognitionResultHandler(StringResultHandler handler) =>
      recognitionResultHandler = handler;

	  // define a method to handle errors
  void setErrorHandler(IntResultHandler handler) =>
      errorHandler = handler;

  // define a method to handle native call
  void setRecognitionStartedHandler(VoidCallback handler) =>
      recognitionStartedHandler = handler;

  // define a method to handle native call
  void setRecognitionCompleteHandler(VoidCallback handler) =>
      recognitionCompleteHandler = handler;

  void setCurrentLocaleHandler(StringResultHandler handler) =>
      currentLocaleHandler = handler;
}

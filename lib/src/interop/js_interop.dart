@JS()
library firebase.js_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;

@JS("JSON.stringify")
external String stringify(Object obj);

@JS("Object.keys")
external List<String> objectKeys(Object obj);

@JS("Date")
class JsDate {
  // https://github.com/dart-lang/linter/issues/864
  // ignore: avoid_unused_constructor_parameters
  external factory JsDate(Object millisecondsSinceEpochOr8601String);
  external int getTime();
}

DateTime dartifyDate(Object jsObject) {
  // if already a date time good
  if (jsObject is DateTime) {
    // Likely running on Dartium – which converts JSDate - Datetime
    // Work-around until Dartium support is dropped
    return jsObject;
  }

  if (util.hasProperty(jsObject, "toDateString")) {
    try {
      var date = jsObject as JsDate;
      return new DateTime.fromMillisecondsSinceEpoch(date.getTime());
    } on NoSuchMethodError {
      // so it's not a JsDate!
      return null;
    } on String catch (e) {
      if (e == 'property is not a function') {
        // Handling Dartium behavior – which throws this String - weird
        // Work-around until Dartium support is dropped
        return null;
      }
      rethrow;
    }
  }
  return null;
}

Object jsifyDate(Object dartObject) {
  if (dartObject is DateTime) {
    try {
      return new JsDate(dartObject.millisecondsSinceEpoch);
    } on TypeError {
      // Likely running on Dartium – which converts JSDate to Datetime which
      // throws when using this interop feature.
      // Work-around until Dartium support is dropped
      return dartObject;
    }
  }
  return null;
}

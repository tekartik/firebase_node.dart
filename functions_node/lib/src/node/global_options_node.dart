import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_functions/firebase_functions.dart';

import 'firebase_functions_node_js_interop.dart' show JSGlobalOptions;

/// Sets [name] on the native options object [nativeOptions] when [value] is
/// not null.
///
/// An object literal factory sets every argument passed, null ones included,
/// and firebase-functions uses a property that is present as is: a null
/// `region` overrides the global region, a null `cors` disables the CORS a
/// callable has by default, a null `timeoutSeconds` fails 7.3+.
void nodeOptionsSetIfNotNull(
  js.JSObject nativeOptions,
  String name,
  js.JSAny? value,
) {
  if (value != null) {
    nativeOptions.setProperty(name.toJS, value);
  }
}

/// Sets on a native options object the [GlobalOptions] values its factory
/// does not take: [GlobalOptions.regions] (as the native region array),
/// memory, timeoutSeconds, concurrency and maxInstances.
///
/// A value is only set when not null: firebase-functions copies every own
/// property, so a null one would override the value set by setGlobalOptions.
T globalOptionsApplyToNode<T extends js.JSObject>(
  T nativeOptions,
  GlobalOptions options,
) {
  void set(String name, js.JSAny? value) {
    if (value != null) {
      nativeOptions.setProperty(name.toJS, value);
    }
  }

  var regions = options.regions;
  if (regions != null) {
    set('region', [for (var region in regions) region.toJS].toJS);
  }
  set('memory', options.memory?.toJS);
  set('timeoutSeconds', options.timeoutSeconds?.toJS);
  set('concurrency', options.concurrency?.toJS);
  set('maxInstances', options.maxInstances?.toJS);
  return nativeOptions;
}

/// The native options of `setGlobalOptions` for [options], only its non null
/// values set (see [globalOptionsApplyToNode]).
///
/// The factory of [JSGlobalOptions] sets every argument passed, null ones
/// included: a null `timeoutSeconds` fails firebase-functions 7.3+ when a
/// function is defined ("timeoutSeconds must be a number, Expression, or
/// RESET_VALUE. Got object.").
JSGlobalOptions globalOptionsToNode(GlobalOptions options) {
  var nativeOptions = JSGlobalOptions();
  var region = options.region;
  if (region != null) {
    nativeOptions.setProperty('region'.toJS, region.toJS);
  }
  return globalOptionsApplyToNode(nativeOptions, options);
}

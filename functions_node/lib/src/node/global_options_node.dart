import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_functions/firebase_functions.dart';

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

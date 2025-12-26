// lib/utils/timeago_init.dart
import 'package:timeago/timeago.dart' as timeago;

class TimeAgoInit {
  static void initialize() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    timeago.setDefaultLocale('id');
  }
}
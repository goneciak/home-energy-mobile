import 'package:flutter/widgets.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'request_language.g.dart';

/// The language GI Core is asked for in `Accept-Language` (plan §13.2):
/// the language the app shows, so that server texts (error messages, and
/// later weather and other Core strings) match the UI.
///
/// [appLocale] mirrors the effective app language (`appLocaleProvider`,
/// the signed-in user's GI Core profile language) and is kept in sync by
/// `syncedRequestLanguageProvider`; while it is `null` the phone language
/// counts ([appLanguageCode]). It is a plain holder read on every request
/// rather than a watched provider, because the app language depends on the
/// session, and the session on the client that sends the header.
final class RequestLanguage {
  new({this._phoneLanguage = appLanguageCode});

  final String Function() _phoneLanguage;

  /// The language the signed-in user's profile chose, or `null` for the
  /// phone language.
  Locale? appLocale;

  /// The language code to send now.
  String call() => appLocale?.languageCode ?? _phoneLanguage();
}

@Riverpod(keepAlive: true)
RequestLanguage requestLanguage(Ref ref) => RequestLanguage();

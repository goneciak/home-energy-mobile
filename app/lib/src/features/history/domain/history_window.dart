/// Time ranges the history screen offers (plan §20 M3: 1 h/6 h/24 h, 7 d
/// paged). The range always ends "now".
enum HistoryWindow {
  hour(Duration(hours: 1)),
  sixHours(Duration(hours: 6)),
  day(Duration(hours: 24)),
  week(Duration(days: 7));

  new(this.span);

  final Duration span;

  /// The window a `?window=` query value names; [day] for anything else.
  static HistoryWindow parse(String? name) =>
      values.where((w) => w.name == name).firstOrNull ?? day;
}

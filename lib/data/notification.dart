class NotifiablePage {
  void update(String m, int count, bool error) {}
}

class Notifier {
  static List<NotifiablePage> _listeners = [];

  static addListener(NotifiablePage n) {
    if (!_listeners.contains(n)) {
      _listeners.add(n);
    }
  }

  static send(String m, int count, bool error) {
    _listeners.forEach((listener) {
      listener.update(m, count, error);
    });
  }

  static void remove(NotifiablePage n) {
    _listeners.remove(n);
  }
}

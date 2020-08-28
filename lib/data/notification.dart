class NotifiablePage {
  void update() {}
}

class Notifier {
  static List<NotifiablePage> _listeners = [];

  static String lastMessage = "Loading...";
  static bool lastError = false;

  static addListener(NotifiablePage n) {
    if (!_listeners.contains(n)) {
      _listeners.add(n);
    }
  }

  static send(String m, bool error) {
    _listeners.forEach((listener) {
      lastMessage = m;
      lastError = error;
      listener.update();
    });
  }

  static void remove(NotifiablePage n) {
    _listeners.remove(n);
  }
}

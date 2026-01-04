import 'dart:async';

class DialogRequest {
  final String title;
  final String description;
  final String? buttonTitle;
  final String? cancelTitle;

  DialogRequest({
    required this.title,
    required this.description,
    this.buttonTitle,
    this.cancelTitle,
  });
}

class DialogResponse {
  final bool confirmed;

  DialogResponse({required this.confirmed});
}

class DialogService {
  final _dialogStreamController = StreamController<DialogRequest>.broadcast();
  late Completer<DialogResponse> _dialogCompleter;

  Stream<DialogRequest> get dialogStream => _dialogStreamController.stream;

  Future<DialogResponse> showDialog({
    required String title,
    required String description,
    String? buttonTitle,
    String? cancelTitle,
  }) async {
    _dialogCompleter = Completer<DialogResponse>();

    _dialogStreamController.add(
      DialogRequest(
        title: title,
        description: description,
        buttonTitle: buttonTitle,
        cancelTitle: cancelTitle,
      ),
    );

    return await _dialogCompleter.future;
  }

  void dismissDialog() {
    if (_dialogCompleter.isCompleted) {
      return;
    }
    _dialogCompleter.complete(DialogResponse(confirmed: false));
  }

  void dispose() {
    _dialogStreamController.close();
  }
}

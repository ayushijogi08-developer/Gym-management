import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_message_model.dart';
import '../data/repositories/chat_history_repository.dart';
import '../services/ai_service.dart';

class AiAssistantProvider extends ChangeNotifier {
  final ChatHistoryRepository _repo = ChatHistoryRepository();
  bool _isLoading = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  List<ChatMessageModel> getHistory(String memberId) =>
      _repo.getLocalHistory(memberId);

  /// Send a chat message. Persists user + assistant messages locally so
  /// the in-app history stays in sync with the backend. [context] is
  /// kept as a parameter so callers can pass a human-readable hint,
  /// but the backend now does its own context injection — this value
  /// is only used for legacy callers and is not forwarded to the
  /// backend.
  Future<String?> sendMessage(
    String memberId,
    String text,
    String context, // kept for signature compatibility, ignored
    bool includeMedical,
  ) async {
    if (text.trim().isEmpty) return null;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    final userMsg = ChatMessageModel(
      id: const Uuid().v4(),
      memberId: memberId,
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
      includedMedicalContext: includeMedical,
    );
    await _repo.addMessage(userMsg);

    // Pull the most recent turns from local history so the backend can
    // fold them into the prompt for conversational continuity. We bound
    // it to the last 20 turns to keep the request body small.
    final prior = _repo.getLocalHistory(memberId);
    final recentTurns = prior.length > 20
        ? prior.sublist(prior.length - 20)
        : prior;
    final historyPayload = recentTurns
        .where((m) => m.content.trim().isNotEmpty)
        .map((m) => {
              'role': m.role,
              'content': m.content,
            })
        .toList();

    final result = await AiService.sendMessage(
      userMessage: text,
      memberId: memberId,
      includeMedical: includeMedical,
      history: historyPayload,
    );

    if (result.isSuccess) {
      final reply = result.reply!;
      final assistantMsg = ChatMessageModel(
        id: const Uuid().v4(),
        memberId: memberId,
        role: 'assistant',
        content: reply,
        timestamp: DateTime.now(),
        includedMedicalContext: includeMedical,
      );
      await _repo.addMessage(assistantMsg);

      _isLoading = false;
      _lastError = null;
      notifyListeners();
      return reply;
    }

    _lastError = result.errorMessage ?? 'Unknown error';
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> clearHistory(String memberId) async {
    await _repo.clearForMember(memberId);
    _lastError = null;
    notifyListeners();
  }
}

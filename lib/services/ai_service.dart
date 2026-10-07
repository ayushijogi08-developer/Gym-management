import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';

/// Result wrapper for [AiService.sendMessage] so callers can show
/// backend-provided error messages (rate limit, missing message, etc.)
/// instead of generic strings.
class AiServiceResult {
  final String? reply;
  final String? errorMessage;
  final int? statusCode;
  final bool contextInjected;
  final int historyTurns;

  const AiServiceResult({
    this.reply,
    this.errorMessage,
    this.statusCode,
    this.contextInjected = false,
    this.historyTurns = 0,
  });

  bool get isSuccess => reply != null && errorMessage == null;
}

/// Client for the backend's `POST /api/ai/chat` endpoint.
///
/// Accepts the new flexible payload (`message` or `messages`, optional
/// `memberId`/`includeMedical`) and surfaces structured error info to
/// callers.
class AiService {
  AiService._();

  /// Send a chat message to the backend AI proxy.
  ///
  /// [memberId] is the Mongo member reference; when provided the
  /// backend injects the member's diet plan, workout routine, and
  /// recent body-progress metrics into the system prompt. If it's
  /// empty the backend will fall back to the member linked to the
  /// authenticated JWT, so we still get a personalised response when
  /// the client simply forwards a member-typed login session.
  /// [history] is a list of prior turns (`{role, content}`) to fold
  /// into the prompt for context continuity.
  /// [includeMedical] toggles medical context inclusion.
  static Future<AiServiceResult> sendMessage({
    required String userMessage,
    String? memberId,
    List<Map<String, String>>? history,
    bool includeMedical = false,
  }) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) {
      return const AiServiceResult(
        errorMessage: 'Please type a message before sending.',
        statusCode: 400,
      );
    }

    // Build a *clean* JSON payload that maps directly to the backend's
    // expected structure. We deliberately send `message` as the canonical
    // field and only include `memberId` when it is a non-empty string
    // (the backend also accepts `userId` as an alias if other clients
    // need it). The optional `history` is converted to a `messages` array
    // for the backend's OpenAI/Anthropic-style history support.
    final payload = <String, dynamic>{
      'message': trimmed,
      'includeMedical': includeMedical,
      if (memberId != null && memberId.trim().isNotEmpty)
        'memberId': memberId.trim(),
      if (history != null && history.isNotEmpty)
        'messages': [
          ...history,
          {'role': 'user', 'content': trimmed},
        ],
    };

    try {
      final response = await ApiClient.post(
        ApiEndpoints.aiChat,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final reply = data['reply'] as String?;
        if (response.statusCode == 200 && reply != null && reply.isNotEmpty) {
          return AiServiceResult(
            reply: reply,
            contextInjected: data['contextInjected'] == true,
            historyTurns: (data['historyTurns'] as num?)?.toInt() ?? 0,
          );
        }

        // Backend reported a structured failure.
        final msg = data['message'] as String? ??
            'The AI service returned an unexpected response.';
        return AiServiceResult(
          errorMessage: msg,
          statusCode: response.statusCode,
        );
      }

      return AiServiceResult(
        errorMessage: 'The AI service returned an unexpected response.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('[AiService] DioException: ${e.type} '
          '${e.response?.statusCode} ${e.response?.data}');
      final status = e.response?.statusCode;
      String message;
      if (status == 400) {
        message = 'Invalid request. Please rephrase and try again.';
      } else if (status == 401) {
        message = 'Your session has expired. Please sign in again.';
      } else if (status == 429) {
        message = 'Too many AI requests. Please wait a few minutes.';
      } else if (status != null && status >= 500) {
        message = 'The AI service is temporarily unavailable.';
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection error. Please check your internet.';
      } else {
        message = 'Connection error. Please try again.';
      }

      // Try to surface a backend-provided message when present so the
      // user sees actionable feedback (e.g. "Request body must include
      // a non-empty message...") instead of a generic one.
      final detail = e.response?.data;
      if (detail is Map && detail['message'] is String) {
        final backendMsg = detail['message'] as String;
        // Only override if the backend's message is more specific.
        if (backendMsg.isNotEmpty) message = backendMsg;
      }

      return AiServiceResult(
        errorMessage: message,
        statusCode: status,
      );
    } catch (e, st) {
      debugPrint('[AiService] unexpected error: $e\n$st');
      return const AiServiceResult(
        errorMessage: 'Connection error. Please try again.',
      );
    }
  }
}

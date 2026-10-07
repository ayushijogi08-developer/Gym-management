import 'dart:convert';

class QrPayload {
  final String memberId;
  final String name;
  final DateTime expiryDate;
  final String membershipStatus;
  final String planName;
  final String token;

  QrPayload({
    required this.memberId,
    required this.name,
    required this.expiryDate,
    required this.membershipStatus,
    required this.planName,
    this.token = 'valid_gym_2026',
  });

  String toRawString() {
    final map = {
      'm': memberId,
      'n': name,
      'e': expiryDate.toIso8601String(),
      's': membershipStatus,
      'p': planName,
      't': token,
    };
    return jsonEncode(map);
  }

  static QrPayload? fromRawString(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return QrPayload(
        memberId: map['m'],
        name: map['n'],
        expiryDate: DateTime.parse(map['e']),
        membershipStatus: map['s'],
        planName: map['p'],
        token: map['t'] ?? 'valid',
      );
    } catch (_) {
      return null;
    }
  }
}
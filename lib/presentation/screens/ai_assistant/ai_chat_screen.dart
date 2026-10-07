import 'package:flutter/material.dart';
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_assistant_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/ai_consent_dialog.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _consentGiven = false;
  bool _includeMedical = false;
@override
  void initState() {
    super.initState();
    // CHANGED: Replaced simple Future.delayed with the new loading logic
    _loadConsentPreference();
  }

  // NEW: Add this method to handle Hive loading and dialog results
  Future<void> _loadConsentPreference() async {
    final settingsBox = Hive.box(HiveBoxes.settings);
    setState(() {
      _consentGiven = settingsBox.get('ai_consent_given', defaultValue: false);
      _includeMedical = settingsBox.get('ai_include_medical', defaultValue: false);
    });

    if (!_consentGiven) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await showDialog<Object>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AiConsentDialog(),
        );

        if (result is Map<String, bool>) {
          // User tapped Accept.
          setState(() {
            _consentGiven = true;
            _includeMedical = result['includeMedical'] ?? false;
          });

          // Save to Hive
          await settingsBox.put('ai_consent_given', true);
          await settingsBox.put('ai_include_medical', _includeMedical);
        } else if (result == false) {
          // User tapped Decline: permanently dismiss the popup for this
          // session by recording the choice in Hive, but flag it as a
          // decline (not consent) so the user can re-open the screen
          // later if they change their mind without being re-prompted
          // on every visit.
          await settingsBox.put('ai_consent_given', true);
          await settingsBox.put('ai_include_medical', false);
          await settingsBox.put('ai_consent_declined', true);
        }
        // result == null (dismissed without choosing) leaves
        // _consentGiven = false, so the prompt will appear again.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiAssistantProvider>();
    final auth = context.watch<AuthProvider>();
    final memberId = auth.currentUser?.linkedMemberId ?? '';
    final history = aiProvider.getHistory(memberId);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Fitness Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final msg = history[history.length - 1 - index];
                return ChatBubble(
                  message: msg.content,
                  isUser: msg.role == 'user',
                );
              },
            ),
          ),
          if (aiProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          if (aiProvider.lastError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                aiProvider.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about diet, workout...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;
                    await aiProvider.sendMessage(
                      memberId,
                      _controller.text.trim(),
                      // The backend now builds the system prompt from the
                      // member's diet/workout/goals/body-progress — no
                      // need to send a hand-rolled context string.
                      '',
                      true,
                    );
                    if (mounted) _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
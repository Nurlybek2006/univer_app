import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../providers/app_providers.dart';

// ─── Model ────────────────────────────────────────────────────────
class AppMessage {
  final String id;
  final String studentId;
  final String title;
  final String body;
  final String sender;
  final DateTime createdAt;
  final bool isRead;

  AppMessage({
    required this.id,
    required this.studentId,
    required this.title,
    required this.body,
    required this.sender,
    required this.createdAt,
    required this.isRead,
  });

  factory AppMessage.fromFirestore(String id, Map<String, dynamic> d) =>
      AppMessage(
        id: id,
        studentId: d['studentId'] as String? ?? '',
        title: d['title'] as String? ?? '',
        body: d['body'] as String? ?? '',
        sender: d['sender'] as String? ?? 'Admin',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: d['isRead'] as bool? ?? false,
      );
}

// ─── Messages Page ─────────────────────────────────────────────────
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  List<AppMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('messages')
          .where('studentId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        _messages =
            snap.docs.map((d) => AppMessage.fromFirestore(d.id, d.data())).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(AppMessage msg) async {
    if (msg.isRead) return;
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(msg.id)
        .update({'isRead': true});
    setState(() {
      _messages = _messages
          .map((m) => m.id == msg.id
              ? AppMessage(
                  id: m.id,
                  studentId: m.studentId,
                  title: m.title,
                  body: m.body,
                  sender: m.sender,
                  createdAt: m.createdAt,
                  isRead: true,
                )
              : m)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _messages.where((m) => !m.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Хабарламалар'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() => _loading = true);
              _loadMessages();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? _buildEmpty(isDark)
              : RefreshIndicator(
                  onRefresh: _loadMessages,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) =>
                        _MessageCard(msg: _messages[i], onTap: _markRead),
                  ),
                ),
    );
  }

  Widget _buildEmpty(bool isDark) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined,
                size: 72,
                color: isDark
                    ? Colors.white24
                    : AppTheme.primary.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text('Хабарлама жоқ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppTheme.primary)),
            const SizedBox(height: 8),
            Text('Жаңа хабарламалар осында пайда болады',
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45)),
          ],
        ),
      );
}

// ─── Message Card ─────────────────────────────────────────────────
class _MessageCard extends StatelessWidget {
  final AppMessage msg;
  final Future<void> Function(AppMessage) onTap;
  const _MessageCard({required this.msg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Оқылды/оқылмады индикатор
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: msg.isRead
                        ? (isDark
                            ? Colors.white12
                            : AppTheme.primary.withValues(alpha: 0.08))
                        : AppTheme.accent.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    msg.isRead
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_rounded,
                    color: msg.isRead
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : AppTheme.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              msg.title,
                              style: TextStyle(
                                fontWeight: msg.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (!msg.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accent),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 12,
                              color: isDark ? Colors.white38 : Colors.black38),
                          const SizedBox(width: 4),
                          Text(msg.sender,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38)),
                          const Spacer(),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(msg.createdAt),
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    onTap(msg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: ctrl,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(msg.title,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.primary)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(msg.sender,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey)),
                const Spacer(),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(msg.createdAt),
                  style:
                      const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ]),
              const Divider(height: 24),
              Text(msg.body,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.white.withValues(alpha: 0.87) : const Color(0xFF1A1A2E))),
            ],
          ),
        ),
      ),
    );
  }
}

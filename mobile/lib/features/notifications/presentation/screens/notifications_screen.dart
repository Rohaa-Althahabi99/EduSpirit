import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationRepository repository;
  const NotificationsScreen({super.key, required this.repository});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _notifications = await widget.repository.getAll();
    } catch (_) {
      _error = 'تعذّر تحميل الإشعارات.';
    }
    setState(() => _loading = false);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'exam_reminder': return Icons.menu_book_rounded;
      case 'assignment_reminder': return Icons.assignment_rounded;
      case 'lecture_reminder': return Icons.school_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                : _notifications.isEmpty
                    ? ListView(children: const [Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: Text('لا توجد إشعارات حاليًا 🔔')),
                      )])
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return ListTile(
                            tileColor: n.isRead ? null : AppColors.primarySoft.withOpacity(0.5),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primarySoft,
                              child: Icon(_iconFor(n.notificationType), color: AppColors.primary, size: 20),
                            ),
                            title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w700)),
                            subtitle: Text(n.body ?? ''),
                            trailing: Text(_relativeTime(n.createdAt), style: const TextStyle(fontSize: 11)),
                            onTap: () async {
                              if (!n.isRead) {
                                await widget.repository.markAsRead(n.id);
                                _load();
                              }
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

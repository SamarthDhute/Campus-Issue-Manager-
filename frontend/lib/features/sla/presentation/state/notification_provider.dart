import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/sla_models.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void startPolling() {
    refreshNotifications();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshUnreadCount();
    });
  }

  Future<void> refreshNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getNotifications(),
        _repository.getUnreadCount(),
      ]);

      _notifications = results[0] as List<NotificationModel>;
      _unreadCount = results[1] as int;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          recipientId: old.recipientId,
          issueId: old.issueId,
          issueNumber: old.issueNumber,
          notificationType: old.notificationType,
          title: old.title,
          body: old.body,
          channel: old.channel,
          status: 'READ',
          sentAt: old.sentAt,
          readAt: DateTime.now(),
          createdAt: old.createdAt,
        );
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          recipientId: n.recipientId,
          issueId: n.issueId,
          issueNumber: n.issueNumber,
          notificationType: n.notificationType,
          title: n.title,
          body: n.body,
          channel: n.channel,
          status: 'READ',
          sentAt: n.sentAt,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

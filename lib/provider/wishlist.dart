import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:speak_up/models/wishlist.dart';
import 'package:speak_up/core/services/dio_client.dart';

class WishlistProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;

  List<WishlistModel> _items = [];

  List<WishlistModel> get items => _items;

  /// 📥 Lấy danh sách wishlist từ server
  Future<void> fetchWishlist() async {
    try {
      final res = await _dio.get('/wishlist');
      final data = res.data['data'];

      if (data is List) {
        _items = data.map((e) => WishlistModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        debugPrint("❌ Dữ liệu wishlist không phải list: $data");
      }
    } catch (e) {
      debugPrint("❌ fetchWishlist error: $e");
    }
  }

  /// ➕ Thêm 1 bài học vào wishlist và đồng bộ lại toàn bộ danh sách
  Future<void> addToWishlist(String lessonId) async {
    try {
      await _dio.post('/wishlist/add', data: {
        'lessonId': lessonId,
      });

      // ✅ Gọi lại để đồng bộ với backend
      await fetchWishlist();
    } catch (e) {
      debugPrint("❌ addToWishlist error: $e");
    }
  }

  /// ❌ Xoá bài học khỏi wishlist
  Future<void> removeFromWishlist(String lessonId) async {
    try {
      await _dio.delete('/wishlist/remove/$lessonId');
      _items.removeWhere((item) => item.lessonId == lessonId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ removeFromWishlist error: $e");
    }
  }

  /// ✅ Kiểm tra bài học có trong wishlist không
  bool isInWishlist(String lessonId) {
    return _items.any((item) => item.lessonId == lessonId);
  }
}

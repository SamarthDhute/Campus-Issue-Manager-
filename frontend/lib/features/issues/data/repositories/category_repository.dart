import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      if (response is List) {
        return response
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      // Fallback categories for resilient UI testing
      return [
        CategoryModel(id: 'c1', name: 'Water & Plumbing', description: 'Leakage, taps, drainage, supply'),
        CategoryModel(id: 'c2', name: 'Electrical & Power', description: 'Lights, fans, sockets, wiring'),
        CategoryModel(id: 'c3', name: 'Hostel & Furniture', description: 'Beds, doors, windows, almirah'),
        CategoryModel(id: 'c4', name: 'Network & IT Support', description: 'Wi-Fi, LAN, projector, smart board'),
        CategoryModel(id: 'c5', name: 'Cleaning & Sanitation', description: 'Garbage, washroom cleaning, pest control'),
      ];
    }
  }
}

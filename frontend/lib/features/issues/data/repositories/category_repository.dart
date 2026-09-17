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
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000001', name: 'Electrical', description: 'Power cuts, faulty switches, broken wiring, lighting failures'),
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000002', name: 'Plumbing & Water', description: 'Water leakages, tap damages, washroom drainage issues'),
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000003', name: 'Internet & Wi-Fi', description: 'Network disconnections, weak Wi-Fi, router failures'),
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000004', name: 'Classroom Equipment', description: 'Projectors, microphones, smart podiums, broken seating'),
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000005', name: 'Hostel Amenities', description: 'Water coolers, lift maintenance, common room equipment'),
        CategoryModel(id: 'c0000000-0000-0000-0000-000000000006', name: 'Cleanliness & Waste', description: 'Housekeeping, waste bins, campus sanitation'),
      ];
    }
  }
}

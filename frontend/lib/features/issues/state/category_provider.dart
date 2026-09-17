import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  bool get isLoading => _isLoading;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getActiveCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

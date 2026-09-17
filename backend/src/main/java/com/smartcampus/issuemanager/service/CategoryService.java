package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.CategoryResponse;

import java.util.List;

public interface CategoryService {
    List<CategoryResponse> getActiveCategories();
}

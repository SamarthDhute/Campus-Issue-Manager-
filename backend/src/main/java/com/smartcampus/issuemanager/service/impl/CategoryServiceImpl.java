package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.CategoryResponse;
import com.smartcampus.issuemanager.entity.Category;
import com.smartcampus.issuemanager.repository.CategoryRepository;
import com.smartcampus.issuemanager.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryResponse> getActiveCategories() {
        List<Category> categories = categoryRepository.findByActiveTrue();
        return categories.stream()
                .map(c -> CategoryResponse.builder()
                        .id(c.getId())
                        .name(c.getName())
                        .description(c.getDescription())
                        .active(Boolean.TRUE.equals(c.getActive()))
                        .build())
                .collect(Collectors.toList());
    }
}

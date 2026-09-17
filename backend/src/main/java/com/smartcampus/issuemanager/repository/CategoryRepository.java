package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CategoryRepository extends JpaRepository<Category, UUID> {
    List<Category> findByOrganizationIdAndActiveTrue(UUID organizationId);
}

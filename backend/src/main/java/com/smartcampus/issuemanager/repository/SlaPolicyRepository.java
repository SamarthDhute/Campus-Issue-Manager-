package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Category;
import com.smartcampus.issuemanager.entity.IssuePriority;
import com.smartcampus.issuemanager.entity.Organization;
import com.smartcampus.issuemanager.entity.SlaPolicy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SlaPolicyRepository extends JpaRepository<SlaPolicy, UUID> {

    Optional<SlaPolicy> findByOrganizationAndCategoryAndPriorityAndActiveTrue(
            Organization organization, Category category, IssuePriority priority);

    Optional<SlaPolicy> findByOrganizationAndCategoryIsNullAndPriorityAndActiveTrue(
            Organization organization, IssuePriority priority);

    List<SlaPolicy> findByOrganizationAndActiveTrue(Organization organization);
}

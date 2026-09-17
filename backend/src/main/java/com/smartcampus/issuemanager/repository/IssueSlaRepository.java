package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.IssueSla;
import com.smartcampus.issuemanager.entity.SlaStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface IssueSlaRepository extends JpaRepository<IssueSla, UUID> {

    Optional<IssueSla> findByIssueId(UUID issueId);

    List<IssueSla> findByStatusIn(List<SlaStatus> statuses);

    @Query("SELECT s FROM IssueSla s WHERE s.status = 'ON_TRACK' AND s.responseMetAt IS NULL AND s.responseDueAt <= :now")
    List<IssueSla> findOverdueResponses(OffsetDateTime now);

    @Query("SELECT s FROM IssueSla s WHERE s.status != 'MET' AND s.resolutionMetAt IS NULL AND s.resolutionDueAt <= :now")
    List<IssueSla> findOverdueResolutions(OffsetDateTime now);
}

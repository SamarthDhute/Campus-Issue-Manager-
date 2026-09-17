package com.smartcampus.issuemanager.integration.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Builder;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.util.Map;

@Slf4j
@Component
public class GeminiClient {

    @Value("${GEMINI_API_KEY:}")
    private String geminiApiKey;

    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public GeminiClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.restClient = RestClient.builder().build();
    }

    @Data
    @Builder
    public static class AiRawAnalysisResult {
        private String summary;
        private String missingInformation;
        private BigDecimal overallConfidence;
        private String recommendedPriority;
        private BigDecimal priorityConfidence;
        private String priorityExplanation;
        private String nextAction;
        private BigDecimal nextActionConfidence;
        private String modelUsed;
    }

    public AiRawAnalysisResult analyzeIssue(String title, String description, String categoryName, String location) {
        if (geminiApiKey != null && !geminiApiKey.isBlank() && !geminiApiKey.startsWith("<")) {
            try {
                return callGeminiApi(title, description, categoryName, location);
            } catch (Exception e) {
                log.warn("Gemini API call failed or timed out. Falling back to heuristic AI engine: {}", e.getMessage());
            }
        }
        return performHeuristicAnalysis(title, description, categoryName, location);
    }

    private AiRawAnalysisResult callGeminiApi(String title, String description, String categoryName, String location) throws Exception {
        String prompt = String.format("""
            You are an AI Campus Facility Operations Intelligence assistant.
            Analyze the following reported campus issue and respond ONLY with a raw JSON object (no markdown, no backticks).
            
            Issue Details:
            Title: %s
            Description: %s
            Category: %s
            Location: %s
            
            JSON schema to return:
            {
              "summary": "1-2 sentence concise executive summary",
              "missingInformation": "specify any missing room/floor/device/hazard details or 'None'",
              "overallConfidence": 0.92,
              "recommendedPriority": "LOW|MEDIUM|HIGH|URGENT",
              "priorityConfidence": 0.90,
              "priorityExplanation": "Brief justification",
              "nextAction": "Actionable technician dispatch or next step",
              "nextActionConfidence": 0.88
            }
            """, title, description, categoryName, location);

        Map<String, Object> requestBody = Map.of(
            "contents", new Object[]{
                Map.of("parts", new Object[]{
                    Map.of("text", prompt)
                })
            },
            "generationConfig", Map.of(
                "temperature", 0.2,
                "responseMimeType", "application/json"
            )
        );

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + geminiApiKey;

        String responseStr = restClient.post()
            .uri(url)
            .contentType(MediaType.APPLICATION_JSON)
            .body(requestBody)
            .retrieve()
            .body(String.class);

        JsonNode root = objectMapper.readTree(responseStr);
        JsonNode textNode = root.path("candidates").get(0).path("content").path("parts").get(0).path("text");
        String jsonText = textNode.asText().trim();
        if (jsonText.startsWith("```json")) {
            jsonText = jsonText.substring(7, jsonText.length() - 3).trim();
        } else if (jsonText.startsWith("```")) {
            jsonText = jsonText.substring(3, jsonText.length() - 3).trim();
        }

        JsonNode parsed = objectMapper.readTree(jsonText);

        return AiRawAnalysisResult.builder()
            .summary(parsed.path("summary").asText("Reported campus facility issue requiring operational review."))
            .missingInformation(parsed.path("missingInformation").asText("None"))
            .overallConfidence(BigDecimal.valueOf(parsed.path("overallConfidence").asDouble(0.90)))
            .recommendedPriority(parsed.path("recommendedPriority").asText("MEDIUM"))
            .priorityConfidence(BigDecimal.valueOf(parsed.path("priorityConfidence").asDouble(0.88)))
            .priorityExplanation(parsed.path("priorityExplanation").asText("AI risk evaluation based on reported location and impact."))
            .nextAction(parsed.path("nextAction").asText("Assign appropriate maintenance operator to inspect the reported area."))
            .nextActionConfidence(BigDecimal.valueOf(parsed.path("nextActionConfidence").asDouble(0.86)))
            .modelUsed("gemini-1.5-flash")
            .build();
    }

    public AiRawAnalysisResult performHeuristicAnalysis(String title, String description, String categoryName, String location) {
        String combined = (title + " " + description).toLowerCase();

        String priority = "MEDIUM";
        BigDecimal priorityConf = new BigDecimal("0.8500");
        String explanation = "Standard maintenance ticket priority assigned based on location and scope.";
        String nextAction = "Assign designated maintenance technician for preliminary inspection.";
        BigDecimal nextActionConf = new BigDecimal("0.8400");
        String missingInfo = "None. Location and description provided.";

        if (combined.contains("fire") || combined.contains("shock") || combined.contains("spark") || combined.contains("emergency") || combined.contains("danger") || combined.contains("gas")) {
            priority = "URGENT";
            priorityConf = new BigDecimal("0.9600");
            explanation = "Severe life safety or electrical hazard detected in case report.";
            nextAction = "Emergency dispatch: cut power/utility supply and alert safety team immediately.";
            nextActionConf = new BigDecimal("0.9500");
        } else if (combined.contains("leak") || combined.contains("water") || combined.contains("dripping") || combined.contains("overflow") || combined.contains("flood") || combined.contains("hazard")) {
            priority = "HIGH";
            priorityConf = new BigDecimal("0.9200");
            explanation = "Active water leakage or physical slip hazard poses structural and safety risks.";
            nextAction = "Dispatch plumbing technician with pipe isolation tools and wet vacuum.";
            nextActionConf = new BigDecimal("0.9000");
        } else if (combined.contains("projector") || combined.contains("wifi") || combined.contains("internet") || combined.contains("light") || combined.contains("fan") || combined.contains("ac") || combined.contains("screen")) {
            priority = "MEDIUM";
            priorityConf = new BigDecimal("0.8800");
            explanation = "Facility appliance or digital amenity malfunction impacting academic/work routine.";
            nextAction = "Assign technical specialist to test device power, wiring, and network cables.";
            nextActionConf = new BigDecimal("0.8700");
        } else if (combined.contains("dust") || combined.contains("trash") || combined.contains("clean") || combined.contains("paint") || combined.contains("door handle")) {
            priority = "LOW";
            priorityConf = new BigDecimal("0.8200");
            explanation = "Cosmetic or scheduled housekeeping task with low operational disruption.";
            nextAction = "Queue task for next routine daily housekeeping rounds.";
            nextActionConf = new BigDecimal("0.8000");
        }

        // Check for missing info
        if (!combined.contains("room") && !combined.contains("block") && !combined.contains("floor") && !location.toLowerCase().contains("room")) {
            missingInfo = "Specific room number or floor level not specified in report.";
        }

        String summary = String.format("%s reported at %s requiring %s priority intervention.",
            title, location, priority.toLowerCase());

        return AiRawAnalysisResult.builder()
            .summary(summary)
            .missingInformation(missingInfo)
            .overallConfidence(priorityConf)
            .recommendedPriority(priority)
            .priorityConfidence(priorityConf)
            .priorityExplanation(explanation)
            .nextAction(nextAction)
            .nextActionConfidence(nextActionConf)
            .modelUsed("campus-heuristic-ai-v1")
            .build();
    }
}

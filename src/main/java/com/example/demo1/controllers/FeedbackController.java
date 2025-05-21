package com.example.demo1.controllers;

import com.example.demo1.models.FeedbackModel;
import com.example.demo1.services.FeedbackService;
import com.example.demo1.utils.CustomLinkedList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/feedbacks")
public class FeedbackController extends HttpServlet {
    private FeedbackService feedbackService = new FeedbackService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String sortByRating = req.getParameter("sortByRating");
        String getLinkedList = req.getParameter("getLinkedList");

        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                FeedbackModel feedback = feedbackService.getFeedbackById(id);
                if (feedback != null) {
                    out.print("{\"id\":" + feedback.getId() +
                            ",\"message\":\"" + escapeJson(feedback.getMessage()) +
                            "\",\"feedback\":\"" + escapeJson(feedback.getFeedback()) +
                            "\",\"rating\":" + feedback.getRating() + "}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Feedback not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID format\"}");
            }
        } else if (sortByRating != null && sortByRating.equals("true")) {
            List<FeedbackModel> sortedFeedbacks = feedbackService.getFeedbacksSortedByRating();
            out.print("[");
            for (int i = 0; i < sortedFeedbacks.size(); i++) {
                FeedbackModel feedback = sortedFeedbacks.get(i);
                out.print("{\"id\":" + feedback.getId() +
                        ",\"message\":\"" + escapeJson(feedback.getMessage()) +
                        "\",\"feedback\":\"" + escapeJson(feedback.getFeedback()) +
                        "\",\"rating\":" + feedback.getRating() + "}");
                if (i < sortedFeedbacks.size() - 1) {
                    out.print(",");
                }
            }
            out.print("]");
        } else if (getLinkedList != null && getLinkedList.equals("true")) {
            CustomLinkedList linkedList = feedbackService.storeFeedbacksInLinkedList();
            out.print("{\"linkedListSize\":" + linkedList.size() + ",\"data\":\"" + escapeJson(linkedList.toString()) + "\"}");
        } else {
            List<FeedbackModel> feedbacks = feedbackService.getAllFeedbacks();
            out.print("[");
            for (int i = 0; i < feedbacks.size(); i++) {
                FeedbackModel feedback = feedbacks.get(i);
                out.print("{\"id\":" + feedback.getId() +
                        ",\"message\":\"" + escapeJson(feedback.getMessage()) +
                        "\",\"feedback\":\"" + escapeJson(feedback.getFeedback()) +
                        "\",\"rating\":" + feedback.getRating() + "}");
                if (i < feedbacks.size() - 1) {
                    out.print(",");
                }
            }
            out.print("]");
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String body = readBody(req);
        String message = extractJsonValue(body, "message");
        String feedback = extractJsonValue(body, "feedback");
        String rating = extractJsonValue(body, "rating");

        FeedbackModel feedbackModel = new FeedbackModel();
        feedbackModel.setMessage(message);
        feedbackModel.setFeedback(feedback);
        feedbackModel.setRating(Integer.parseInt(rating));

        boolean created = feedbackService.createFeedback(feedbackModel);
        if (created) {
            out.print("{\"message\":\"Feedback created successfully\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to create feedback\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String body = readBody(req);
        String message = extractJsonValue(body, "message");
        String feedback = extractJsonValue(body, "feedback");
        String rating = extractJsonValue(body, "rating");

        try {
            if (idParam == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID parameter is required\"}");
                out.flush();
                return;
            }
            int id = Integer.parseInt(idParam);
            FeedbackModel feedbackModel = new FeedbackModel();
            feedbackModel.setId(id);
            feedbackModel.setMessage(message);
            feedbackModel.setFeedback(feedback);
            feedbackModel.setRating(Integer.parseInt(rating));

            boolean updated = feedbackService.updateFeedback(feedbackModel);
            if (updated) {
                out.print("{\"message\":\"Feedback updated successfully\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Feedback not found\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid ID format\"}");
        }
        out.flush();
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                boolean deleted = feedbackService.deleteFeedback(id);
                if (deleted) {
                    out.print("{\"message\":\"Feedback deleted successfully\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Feedback not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID format\"}");
            }
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"ID parameter is required\"}");
        }
        out.flush();
    }

    // Helper to read request body
    private String readBody(HttpServletRequest req) throws IOException {
        BufferedReader reader = req.getReader();
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        return sb.toString();
    }

    // Simple JSON value extractor (for demonstration only)
    private String extractJsonValue(String json, String key) {
        // Try to match quoted string
        String patternString = "\"" + key + "\"\\s*:\\s*\"([^\"]*)\"";
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(patternString);
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        // Try to match unquoted number (not needed for question fields, but kept for consistency)
        patternString = "\"" + key + "\"\\s*:\\s*(\\d+)";
        pattern = java.util.regex.Pattern.compile(patternString);
        matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    // Escape JSON special characters
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
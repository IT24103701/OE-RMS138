package com.example.demo1.controllers;

import com.example.demo1.models.QuestionModel;
import com.example.demo1.services.QuestionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/questions")
public class QuestionController extends HttpServlet {
    private QuestionService questionService = new QuestionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                QuestionModel question = questionService.getQuestionById(id);
                if (question != null) {
                    out.print("{\"id\":" + question.getId() +
                            ",\"question\":\"" + escapeJson(question.getQuestion()) +
                            "\",\"answer\":\"" + escapeJson(question.getAnswer()) +
                            "\",\"type\":\"" + escapeJson(question.getType()) + "\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Question not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID format\"}");
            }
        } else {
            List<QuestionModel> questions = questionService.getAllQuestions();
            out.print("[");
            for (int i = 0; i < questions.size(); i++) {
                QuestionModel question = questions.get(i);
                out.print("{\"id\":" + question.getId() +
                        ",\"question\":\"" + escapeJson(question.getQuestion()) +
                        "\",\"answer\":\"" + escapeJson(question.getAnswer()) +
                        "\",\"type\":\"" + escapeJson(question.getType()) + "\"}");
                if (i < questions.size() - 1) {
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
        String questionText = extractJsonValue(body, "question");
        String answer = extractJsonValue(body, "answer");
        String type = extractJsonValue(body, "type");

        QuestionModel question = new QuestionModel();
        question.setQuestion(questionText);
        question.setAnswer(answer);
        question.setType(type);

        boolean created = questionService.createQuestion(question);
        if (created) {
            out.print("{\"message\":\"Question created successfully\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to create question\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String body = readBody(req);
        String questionText = extractJsonValue(body, "question");
        String answer = extractJsonValue(body, "answer");
        String type = extractJsonValue(body, "type");

        try {
            if (idParam == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID parameter is required\"}");
                out.flush();
                return;
            }
            int id = Integer.parseInt(idParam);
            QuestionModel question = new QuestionModel();
            question.setId(id);
            question.setQuestion(questionText);
            question.setAnswer(answer);
            question.setType(type);

            boolean updated = questionService.updateQuestion(question);
            if (updated) {
                out.print("{\"message\":\"Question updated successfully\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Question not found\"}");
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
                boolean deleted = questionService.deleteQuestion(id);
                if (deleted) {
                    out.print("{\"message\":\"Question deleted successfully\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Question not found\"}");
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
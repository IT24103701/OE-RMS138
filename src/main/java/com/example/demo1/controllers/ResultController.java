package com.example.demo1.controllers;

import com.example.demo1.models.ResultModel;
import com.example.demo1.services.ResultService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/results")
public class ResultController extends HttpServlet {
    private ResultService resultService = new ResultService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String sortParam = req.getParameter("sort");

        try {
            // Case 1: Retrieve a specific result by ID
            if (idParam != null) {
                int id = Integer.parseInt(idParam);
                ResultModel result = resultService.getResultById(id);
                if (result != null) {
                    out.print("{\"id\":" + result.getId() +
                            ",\"studentName\":\"" + escapeJson(result.getStudentName()) +
                            "\",\"subject\":\"" + escapeJson(result.getSubject()) +
                            "\",\"marks\":" + result.getMarks() + "}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Result not found\"}");
                }
            }

            // Case 2: Sorted results
            else if (sortParam != null) {
                List<ResultModel> sortedResults;
                if ("marks".equalsIgnoreCase(sortParam)) {
                    sortedResults = resultService.getResultsSortedByMarks();
                } else if ("name".equalsIgnoreCase(sortParam)) {
                    sortedResults = resultService.getResultsSortedByStudentName();
                } else {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Invalid sort parameter. Use 'marks' or 'name'.\"}");
                    return;
                }

                out.print("[");
                for (int i = 0; i < sortedResults.size(); i++) {
                    ResultModel result = sortedResults.get(i);
                    out.print("{\"id\":" + result.getId() +
                            ",\"studentName\":\"" + escapeJson(result.getStudentName()) +
                            "\",\"subject\":\"" + escapeJson(result.getSubject()) +
                            "\",\"marks\":" + result.getMarks() + "}");
                    if (i < sortedResults.size() - 1) {
                        out.print(",");
                    }
                }
                out.print("]");
            }

            // Case 3: Return all results
            else {
                List<ResultModel> results = resultService.getAllResults();
                out.print("[");
                for (int i = 0; i < results.size(); i++) {
                    ResultModel result = results.get(i);
                    out.print("{\"id\":" + result.getId() +
                            ",\"studentName\":\"" + escapeJson(result.getStudentName()) +
                            "\",\"subject\":\"" + escapeJson(result.getSubject()) +
                            "\",\"marks\":" + result.getMarks() + "}");
                    if (i < results.size() - 1) {
                        out.print(",");
                    }
                }
                out.print("]");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid ID format\"}");
        }

        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String body = readBody(req);
        String studentName = extractJsonValue(body, "studentName");
        String subject = extractJsonValue(body, "subject");
        String marks = extractJsonValue(body, "marks");

        ResultModel result = new ResultModel();
        result.setStudentName(studentName);
        result.setSubject(subject);
        result.setMarks(Integer.parseInt(marks));

        boolean created = resultService.createResult(result);
        if (created) {
            out.print("{\"message\":\"Result created successfully\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to create result\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String body = readBody(req);
        String studentName = extractJsonValue(body, "studentName");
        String subject = extractJsonValue(body, "subject");
        String marks = extractJsonValue(body, "marks");

        try {
            if (idParam == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID parameter is required\"}");
                out.flush();
                return;
            }
            int id = Integer.parseInt(idParam);
            ResultModel result = new ResultModel();
            result.setId(id);
            result.setStudentName(studentName);
            result.setSubject(subject);
            result.setMarks(Integer.parseInt(marks));

            boolean updated = resultService.updateResult(result);
            if (updated) {
                out.print("{\"message\":\"Result updated successfully\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Result not found\"}");
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
                boolean deleted = resultService.deleteResult(id);
                if (deleted) {
                    out.print("{\"message\":\"Result deleted successfully\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Result not found\"}");
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
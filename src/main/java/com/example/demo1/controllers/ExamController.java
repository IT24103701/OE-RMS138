package com.example.demo1.controllers;

import com.example.demo1.models.ExamModel;
import com.example.demo1.services.ExamService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/exams")
public class ExamController extends HttpServlet {
    private ExamService examService = new ExamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                ExamModel exam = examService.getExamById(id);
                if (exam != null) {
                    out.print("{\"id\":" + exam.getId() + ",\"name\":\"" + escapeJson(exam.getName()) + "\",\"date\":\"" + escapeJson(exam.getDate()) + "\",\"time\":\"" + escapeJson(exam.getTime()) + "\",\"type\":\"" + escapeJson(exam.getType()) + "\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Exam not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID format\"}");
            }
        } else {
            List<ExamModel> exams = examService.getAllExams();
            out.print("[");
            for (int i = 0; i < exams.size(); i++) {
                ExamModel exam = exams.get(i);
                out.print("{\"id\":" + exam.getId() + ",\"name\":\"" + escapeJson(exam.getName()) + "\",\"date\":\"" + escapeJson(exam.getDate()) + "\",\"time\":\"" + escapeJson(exam.getTime()) + "\",\"type\":\"" + escapeJson(exam.getType()) + "\"}");
                if (i < exams.size() - 1) {
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
        String name = extractJsonValue(body, "name");
        String date = extractJsonValue(body, "date");
        String time = extractJsonValue(body, "time");
        String type = extractJsonValue(body, "type");

        ExamModel exam = new ExamModel();
        exam.setName(name);
        exam.setDate(date);
        exam.setTime(time);
        exam.setType(type);

        boolean created = examService.createExam(exam);
        if (created) {
            out.print("{\"message\":\"Exam created successfully\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to create exam\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        String body = readBody(req);
        String name = extractJsonValue(body, "name");
        String date = extractJsonValue(body, "date");
        String time = extractJsonValue(body, "time");
        String type = extractJsonValue(body, "type");

        try {
            if (idParam == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID parameter is required\"}");
                out.flush();
                return;
            }
            int id = Integer.parseInt(idParam);
            ExamModel exam = new ExamModel();
            exam.setId(id);
            exam.setName(name);
            exam.setDate(date);
            exam.setTime(time);
            exam.setType(type);

            boolean updated = examService.updateExam(exam);
            if (updated) {
                out.print("{\"message\":\"Exam updated successfully\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Exam not found\"}");
            }
        } catch (NumberFormatException e) {
            System.out.println(e);
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
                boolean deleted = examService.deleteExam(id);
                if (deleted) {
                    out.print("{\"message\":\"Exam deleted successfully\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Exam not found\"}");
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
        String pattern = "\"" + key + "\"\\s*:\\s*\"([^\"]*)\"";
        java.util.regex.Pattern r = java.util.regex.Pattern.compile(pattern);
        java.util.regex.Matcher m = r.matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    // Escape JSON special characters
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

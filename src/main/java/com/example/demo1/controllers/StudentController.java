package com.example.demo1.controllers;

import com.example.demo1.models.StudentModel;
import com.example.demo1.services.StudentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/students")
public class StudentController extends HttpServlet {
    private StudentService studentService = new StudentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                StudentModel student = studentService.getStudentById(id);
                if (student != null) {
                    out.print("{\"id\":" + student.getId() +
                              ",\"name\":\"" + escapeJson(student.getName()) +
                              "\",\"email\":\"" + escapeJson(student.getEmail()) +
                              "\",\"contactNumber\":\"" + escapeJson(student.getContactNumber()) +
                              "\",\"age\":" + student.getAge() + "}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Student not found\"}");
                }
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID format\"}");
            }
        } else {
            List<StudentModel> students = studentService.getAllStudents();
            out.print("[");
            for (int i = 0; i < students.size(); i++) {
                StudentModel student = students.get(i);
                out.print("{\"id\":" + student.getId() +
                          ",\"name\":\"" + escapeJson(student.getName()) +
                          "\",\"email\":\"" + escapeJson(student.getEmail()) +
                          "\",\"contactNumber\":\"" + escapeJson(student.getContactNumber()) +
                          "\",\"age\":" + student.getAge() + "}");
                if (i < students.size() - 1) {
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
        String email = extractJsonValue(body, "email");
        String contactNumber = extractJsonValue(body, "contactNumber");
        String ageStr = extractJsonValue(body, "age");
        System.out.println(ageStr);
        StudentModel student = new StudentModel();
        student.setName(name);
        student.setEmail(email);
        student.setContactNumber(contactNumber);
        try {
            student.setAge(ageStr != null ? Integer.parseInt(ageStr) : 0);
        } catch (NumberFormatException e) {
            student.setAge(0);
        }

        boolean created = studentService.createStudent(student);
        if (created) {
            out.print("{\"message\":\"Student created successfully\"}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to create student\"}");
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
        String email = extractJsonValue(body, "email");
        String contactNumber = extractJsonValue(body, "contactNumber");
        String ageStr = extractJsonValue(body, "age");

        try {
            if (idParam == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID parameter is required\"}");
                out.flush();
                return;
            }
            int id = Integer.parseInt(idParam);
            StudentModel student = new StudentModel();
            student.setId(id);
            student.setName(name);
            student.setEmail(email);
            student.setContactNumber(contactNumber);
            try {
                student.setAge(ageStr != null ? Integer.parseInt(ageStr) : 0);
            } catch (NumberFormatException e) {
                student.setAge(0);
            }

            boolean updated = studentService.updateStudent(student);
            if (updated) {
                out.print("{\"message\":\"Student updated successfully\"}");
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Student not found\"}");
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
                boolean deleted = studentService.deleteStudent(id);
                if (deleted) {
                    out.print("{\"message\":\"Student deleted successfully\"}");
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Student not found\"}");
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
        // Try to match unquoted number
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
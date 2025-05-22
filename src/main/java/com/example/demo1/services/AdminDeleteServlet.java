package com.earm.admin_mangement.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AdminDeleteServlet")
public class AdminDeleteServlet extends HttpServlet {
    private final String FILE_PATH = System.getProperty("user.home") + File.separator + "examdata" + File.separator + "admin.txt";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empNumber") == null) {
            response.sendRedirect("admin/login.jsp");
            return;
        }

        String empNumber = (String) session.getAttribute("empNumber");

        File file = new File(FILE_PATH);
        List<String> lines = new ArrayList<>();

        // Read all lines except the one to delete
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 1 && !parts[0].trim().equals(empNumber)) {
                    lines.add(line);
                }
            }
        }

        // Overwrite the file with remaining records
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
            for (String l : lines) {
                bw.write(l);
                bw.newLine();
            }
        }

        // End session and redirect
        session.invalidate();
        response.sendRedirect("admin/login.jsp");
    }
}

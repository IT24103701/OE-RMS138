package com.earm.admin_mangement.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AdminUpdateServlet")
public class AdminUpdateServlet extends HttpServlet {
    private final String FILE_PATH = System.getProperty("user.home") + File.separator + "examdata" + File.separator + "admin.txt";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Forward to update form JSP
        request.getRequestDispatcher("admin/update.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empNumber") == null) {
            response.sendRedirect("admin/login.jsp");
            return;
        }

        String empNumber = (String) session.getAttribute("empNumber");
        String newName = request.getParameter("name");
        String newEmail = request.getParameter("email");
        String newPassword = request.getParameter("password");

        File file = new File(FILE_PATH);
        List<String> lines = new ArrayList<>();
        boolean updated = false;

        // Read all admins and update matching empNumber
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5 && parts[0].equals(empNumber)) {
                    // Update this line with new data
                    String updatedLine = empNumber + "," + newName + "," + newEmail + "," + newPassword + "," + parts[4];
                    lines.add(updatedLine);
                    updated = true;

                    // Update session attributes
                    session.setAttribute("name", newName);
                    session.setAttribute("email", newEmail);
                    session.setAttribute("password", newPassword);
                } else {
                    lines.add(line);
                }
            }
        }

        // Write back all lines
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) {
            for (String l : lines) {
                bw.write(l);
                bw.newLine();
            }
        }

        if (updated) {
            response.sendRedirect("admin/dashboard.jsp?msg=Profile updated successfully");
        } else {
            response.getWriter().println("<h3>Update failed. <a href='admin/update.jsp'>Try Again</a></h3>");
        }
    }
}

package com.earm.admin_mangement.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    String FILE_PATH = System.getProperty("user.home") + File.separator + "examdata" + File.separator + "admin.txt";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        File file = new File(FILE_PATH);
        file.getParentFile().mkdirs();

        // Variables for user data
        String empNumber = null;
        String name = null;
        String nic = null;

        boolean success = false;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;

            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length == 5 && parts[2].equals(email) && parts[3].equals(password)) {
                    empNumber = parts[0];
                    name = parts[1];
                    nic = parts[4];
                    success = true;
                    break;
                }
            }
        }

        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("empNumber", empNumber);
            session.setAttribute("name", name);
            session.setAttribute("email", email);
            session.setAttribute("password", password);
            session.setAttribute("nic", nic);

            response.sendRedirect("admin/dashboard.jsp");
        } else {
            response.getWriter().println("<h3>Login failed. <a href='admin/login.jsp'>Try Again</a></h3>");
        }
    }
}

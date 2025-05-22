package com.earm.admin_mangement.servlet;

import com.earm.admin_mangement.model.Admin;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

@WebServlet("/AdminSignupServlet")
public class AdminSignupServlet extends HttpServlet {
    // ✅ Change file name here
    String FILE_PATH = System.getProperty("user.home") + File.separator + "examdata" + File.separator + "admin.txt";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String empNumber = request.getParameter("empNumber");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String NIC = request.getParameter("NIC");


        Admin admin = new Admin(name, email, password, NIC, empNumber);

        // ✅ Create parent directory if it doesn't exist
        File file = new File(FILE_PATH);
        file.getParentFile().mkdirs();

        try (FileWriter fw = new FileWriter(file, true);
             BufferedWriter bw = new BufferedWriter(fw)) {
            // Customize format as needed
            bw.write(admin.getEmpNumber() + "," + admin.getName() + "," + admin.getEmail() + "," + admin.getPassword() + "," + admin.getNIC());

            bw.newLine();
        }

        response.sendRedirect("admin/login.jsp");
    }
}

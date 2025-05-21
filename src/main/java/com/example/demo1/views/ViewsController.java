package com.example.demo1.views;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ViewsController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String jspPath = null;

        switch (path) {
            case "/":
            case "/index":
                jspPath = "index.jsp";
                break;
            case "/create":
                jspPath = "create.jsp";
                break;
            case "/edit":
                jspPath = "edit.jsp";
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
        }

        req.getRequestDispatcher(jspPath).forward(req, resp);
    }
}

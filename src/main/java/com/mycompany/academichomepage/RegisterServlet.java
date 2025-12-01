package com.mycompany.academichomepage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        String major    = request.getParameter("major");

        // Trim so accidental spaces don’t break login
        if (fullName != null) fullName = fullName.trim();
        if (email != null)    email    = email.trim();
        if (password != null) password = password.trim();
        if (major != null)    major    = major.trim();

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "INSERT INTO users (full_name, email, password, major, role) " +
                         "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, fullName);
                stmt.setString(2, email);
                stmt.setString(3, password);              // plain text is fine for this class project
                stmt.setString(4, major.isEmpty() ? null : major);
                stmt.setString(5, "student");             // default role

                int rows = stmt.executeUpdate();

                if (rows > 0) {
                    // success → tell login.jsp to show “Registered successfully”
                    response.sendRedirect("login.jsp?registered=1");
                } else {
                    // insert failed but no exception
                    response.sendRedirect("register.jsp?error=1");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            // any SQL/connection error → generic error banner on register.jsp
            response.sendRedirect("register.jsp?error=1");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}

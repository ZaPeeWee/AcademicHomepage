/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.academichomepage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            try (Connection conn = DBConnection.getConnection()) {

                // EXTRA CREDIT: PreparedStatement to avoid SQL injection
                String sql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, password); // (for a school project, plain text is okay)
                    ps.setString(3, email);

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        out.println("<h2>Registration successful!</h2>");
                        out.println("<a href='login.jsp'>Go to Login</a>");
                    } else {
                        out.println("<h2>Registration failed.</h2>");
                        out.println("<a href='register.jsp'>Try again</a>");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace(out);
            }
        }
    }
}
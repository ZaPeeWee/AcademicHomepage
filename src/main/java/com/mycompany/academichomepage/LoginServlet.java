/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.academichomepage;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author viane
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            try (Connection conn = DBConnection.getConnection()) {

                // EXTRA CREDIT: PreparedStatement and session
                String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, password);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            // EXTRA CREDIT: HttpSession
                            HttpSession session = request.getSession();
                            session.setAttribute("username", username);
                            session.setAttribute("loggedIn", true);

                            // Redirect to dashboard page
                            response.sendRedirect("dashboard.jsp");
                            return;
                        } else {
                            out.println("<h2>Invalid username or password.</h2>");
                            out.println("<a href='login.jsp'>Try again</a>");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace(out);
            }
        }
    }
}
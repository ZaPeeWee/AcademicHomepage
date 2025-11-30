/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.academichomepage;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author viane
 */
@WebServlet("/MessageServlet")
public class MessageServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name    = request.getParameter("name");
        String email   = request.getParameter("email");
        String message = request.getParameter("message");

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            try (Connection conn = DBConnection.getConnection()) {

                // EXTRA CREDIT: PreparedStatement
                String sql = "INSERT INTO messages (name, email, message) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setString(3, message);

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        out.println("<h2>Thank you for your message!</h2>");
                        out.println("<a href='index.html'>Back to Home</a>");
                    } else {
                        out.println("<h2>Something went wrong. Please try again.</h2>");
                        out.println("<a href='contact.jsp'>Back to Contact</a>");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace(out);
            }
        }
    }
}
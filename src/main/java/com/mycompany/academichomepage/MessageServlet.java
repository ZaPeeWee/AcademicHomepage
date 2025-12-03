package com.mycompany.academichomepage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet(name = "MessageServlet", urlPatterns = {"/contact"})
public class MessageServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name        = request.getParameter("name");
        String email       = request.getParameter("email");
        String messageText = request.getParameter("message");
        String recipientIdParam = request.getParameter("recipientId");

        // basic validation
        if (name == null || name.isBlank()
                || email == null || email.isBlank()
                || messageText == null || messageText.isBlank()) {
            response.sendRedirect("contact.jsp?error=1");
            return;
        }

        // Who is sending?
        HttpSession session = request.getSession(false);
        Integer userId = null;
        if (session != null) {
            userId = (Integer) session.getAttribute("userId");
        }

        // Who is receiving?
        Integer recipientId = null;
        if (recipientIdParam != null && !recipientIdParam.isBlank()) {
            try {
                recipientId = Integer.parseInt(recipientIdParam);
            } catch (NumberFormatException e) {
                // ignore bad id, treat as no recipient (admin/general inbox)
                recipientId = null;
            }
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO messages (user_id, recipient_id, name, email, message_text) "
                       + "VALUES (?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);

            // sender
            if (userId != null) {
                stmt.setInt(1, userId);
            } else {
                stmt.setNull(1, java.sql.Types.INTEGER);
            }

            // recipient
            if (recipientId != null) {
                stmt.setInt(2, recipientId);
            } else {
                stmt.setNull(2, java.sql.Types.INTEGER);
            }

            stmt.setString(3, name);
            stmt.setString(4, email);
            stmt.setString(5, messageText);

            stmt.executeUpdate();
            response.sendRedirect("contact.jsp?success=1");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("contact.jsp?error=1");
        }
    }
}

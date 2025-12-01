package com.mycompany.academichomepage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/profile")
@MultipartConfig
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        String sql = "SELECT full_name, email, major, bio, avatar_path FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    request.setAttribute("fullName", rs.getString("full_name"));
                    request.setAttribute("email", rs.getString("email"));
                    request.setAttribute("major", rs.getString("major"));
                    request.setAttribute("bio", rs.getString("bio"));
                    request.setAttribute("avatarPath", rs.getString("avatar_path"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String major = request.getParameter("major");
        String bio = request.getParameter("bio");

        // Handle avatar upload
        Part avatarPart = request.getPart("avatar");
        String avatarPathInApp = null;

        if (avatarPart != null && avatarPart.getSize() > 0) {
            // Where to save on disk
            String uploadsDir = getServletContext().getRealPath("/uploads/avatars");
            File uploadsFolder = new File(uploadsDir);
            if (!uploadsFolder.exists()) {
                uploadsFolder.mkdirs();
            }

            // File name: user_<id>.originalExtension
            String submittedName = avatarPart.getSubmittedFileName();
            String extension = "";
            int dot = submittedName.lastIndexOf('.');
            if (dot != -1) {
                extension = submittedName.substring(dot);
            }

            String fileName = "user_" + userId + extension;
            File fileOnDisk = new File(uploadsFolder, fileName);

            Files.copy(avatarPart.getInputStream(), fileOnDisk.toPath(),
                    StandardCopyOption.REPLACE_EXISTING);

            // Path for <img src="...">
            avatarPathInApp = "uploads/avatars/" + fileName;
        }

        String sql;
        if (avatarPathInApp != null) {
            sql = "UPDATE users SET full_name = ?, major = ?, bio = ?, avatar_path = ? WHERE id = ?";
        } else {
            sql = "UPDATE users SET full_name = ?, major = ?, bio = ? WHERE id = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, fullName);
            stmt.setString(2, major);
            stmt.setString(3, bio);

            if (avatarPathInApp != null) {
                stmt.setString(4, avatarPathInApp);
                stmt.setInt(5, userId);
            } else {
                stmt.setInt(4, userId);
            }

            stmt.executeUpdate();

            // Update session values so dashboard shows new info
            session.setAttribute("userName", fullName);
            session.setAttribute("userMajor", major);
            session.setAttribute("userBio", bio);
            if (avatarPathInApp != null) {
                session.setAttribute("userAvatar", avatarPathInApp);
            }

            response.sendRedirect("dashboard.jsp?profileUpdated=1");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile?error=1");
        }
    }
}

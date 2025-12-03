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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String fullName = request.getParameter("fullName");
        String major    = request.getParameter("major");
        String bio      = request.getParameter("bio");

        if (fullName == null) fullName = "";
        if (major == null)    major = "";
        if (bio == null)      bio = "";

        // ===== NEW: File uploads =====
        Part avatarPart = request.getPart("avatar");
        Part resumePart = request.getPart("resume");

        String avatarFile = null;
        String resumeFile = null;

        // Save avatar
        if (avatarPart != null && avatarPart.getSize() > 0) {
            avatarFile = "avatar_" + userId + ".png";
            String path = getServletContext().getRealPath("/uploads/avatars/");
            new File(path).mkdirs();
            avatarPart.write(path + avatarFile);
        }

        // Save resume
        if (resumePart != null && resumePart.getSize() > 0) {
            resumeFile = "resume_" + userId + ".pdf";
            String path = getServletContext().getRealPath("/uploads/resumes/");
            new File(path).mkdirs();
            resumePart.write(path + resumeFile);
        }

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "UPDATE users SET full_name=?, major=?, bio=?, "
                       + "avatar_path = COALESCE(?, avatar_path), "
                       + "resume_path = COALESCE(?, resume_path) "
                       + "WHERE id=?";

            PreparedStatement stmt = conn.prepareStatement(sql);

            stmt.setString(1, fullName);
            stmt.setString(2, major);
            stmt.setString(3, bio);
            stmt.setString(4, avatarFile);
            stmt.setString(5, resumeFile);
            stmt.setInt(6, userId);

            stmt.executeUpdate();

            // Update session
            session.setAttribute("userName", fullName);
            session.setAttribute("userMajor", major);
            session.setAttribute("userBio", bio);

            if (avatarFile != null)
                session.setAttribute("avatarPath", avatarFile);

            if (resumeFile != null)
                session.setAttribute("resumePath", resumeFile);

            response.sendRedirect("dashboard.jsp?updated=1");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=1");
        }
    }
}

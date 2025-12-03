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
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProjectServlet", urlPatterns = {"/projects"})
@MultipartConfig
public class ProjectServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession s = request.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = (Integer) s.getAttribute("userId");

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "create";
        }

        switch (action) {
            case "delete":
                handleDelete(request, response, userId);
                break;
            case "update":
                handleUpdate(request, response, userId);
                break;
            default: // "create"
                handleCreate(request, response, userId);
                break;
        }
    }

    /* ------------ CREATE ------------ */

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException, ServletException {

        String title       = trimOrNull(request.getParameter("title"));
        String course      = trimOrNull(request.getParameter("course"));
        String description = trimOrNull(request.getParameter("description"));
        String projectUrl  = trimOrNull(request.getParameter("projectUrl"));

        if (title == null || title.isEmpty()) {
            response.sendRedirect("projects?error=1");
            return;
        }

        String imagePath = saveImageFile(request, userId, null);

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO projects " +
                    "(user_id, title, course, description, project_url, image_url) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setString(2, title);
            stmt.setString(3, course);
            stmt.setString(4, description);
            stmt.setString(5, projectUrl);
            stmt.setString(6, imagePath);

            stmt.executeUpdate();

            response.sendRedirect("projects?added=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("projects?error=1");
        }
    }

    /* ------------ UPDATE ------------ */

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException, ServletException {

        String idParam = request.getParameter("projectId");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect("projects?error=1");
            return;
        }
        int projectId = Integer.parseInt(idParam);

        String title       = trimOrNull(request.getParameter("title"));
        String course      = trimOrNull(request.getParameter("course"));
        String description = trimOrNull(request.getParameter("description"));
        String projectUrl  = trimOrNull(request.getParameter("projectUrl"));

        if (title == null || title.isEmpty()) {
            response.sendRedirect("projects?error=1");
            return;
        }

        // If a new image is uploaded, replace; otherwise keep existing
        String newImagePath = saveImageFile(request, userId, null);

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE projects SET " +
                         "title = ?, course = ?, description = ?, project_url = ?, " +
                         "image_url = COALESCE(?, image_url) " +
                         "WHERE id = ? AND user_id = ?";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, title);
            stmt.setString(2, course);
            stmt.setString(3, description);
            stmt.setString(4, projectUrl);
            stmt.setString(5, newImagePath);   // can be null -> COALESCE keeps old
            stmt.setInt(6, projectId);
            stmt.setInt(7, userId);

            stmt.executeUpdate();

            response.sendRedirect("projects?updated=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("projects?error=1");
        }
    }

    /* ------------ DELETE ------------ */

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int userId)
            throws IOException {

        String idParam = request.getParameter("projectId");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect("projects?error=1");
            return;
        }
        int projectId = Integer.parseInt(idParam);

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM projects WHERE id = ? AND user_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, projectId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();

            response.sendRedirect("projects?deleted=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("projects?error=1");
        }
    }

    /* ------------ GET (list + optional edit) ------------ */

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession s = request.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = (Integer) s.getAttribute("userId");

        String editIdParam = request.getParameter("editId");
        Project editProject = null;

        List<Project> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            // If editing: load that one project
            if (editIdParam != null && !editIdParam.isBlank()) {
                int editId = Integer.parseInt(editIdParam);

                String editSql = "SELECT id, user_id, title, course, description, " +
                                 "project_url, image_url, created_at " +
                                 "FROM projects WHERE id = ? AND user_id = ?";

                try (PreparedStatement ps = conn.prepareStatement(editSql)) {
                    ps.setInt(1, editId);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            editProject = mapProject(rs);
                        }
                    }
                }
            }

            // List all projects for this user
            String sql = "SELECT id, user_id, title, course, description, " +
                         "project_url, image_url, created_at " +
                         "FROM projects WHERE user_id = ? ORDER BY created_at DESC";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapProject(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loadError", true);
        }

        request.setAttribute("projects", list);
        request.setAttribute("editProject", editProject);
        request.getRequestDispatcher("projects.jsp").forward(request, response);
    }

    /* ------------ Helpers ------------ */

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    // Save uploaded image; returns relative path like "project-images/file.png" or null
    private String saveImageFile(HttpServletRequest request, int userId, String defaultPath)
            throws IOException, ServletException {

        Part imagePart = null;
        try {
            imagePart = request.getPart("imageFile");
        } catch (IllegalStateException | ServletException e) {
            // no file or wrong enctype – just ignore
        }

        if (imagePart == null || imagePart.getSize() == 0) {
            return defaultPath;
        }

        String uploadDir = request.getServletContext().getRealPath("/project-images/");
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String submitted = imagePart.getSubmittedFileName();
        String ext = "";
        if (submitted != null) {
            int dot = submitted.lastIndexOf('.');
            if (dot != -1) {
                ext = submitted.substring(dot);
            }
        }

        String fileName = "project_" + userId + "_" + System.currentTimeMillis() + ext;
        File file = new File(dir, fileName);
        imagePart.write(file.getAbsolutePath());

        return "project-images/" + fileName;
    }

    private Project mapProject(ResultSet rs) throws SQLException {
        Project p = new Project();
        p.setId(rs.getInt("id"));
        p.setUserId(rs.getInt("user_id"));
        p.setTitle(rs.getString("title"));
        p.setCourse(rs.getString("course"));
        p.setDescription(rs.getString("description"));
        p.setProjectUrl(rs.getString("project_url"));
        p.setImageUrl(rs.getString("image_url"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}

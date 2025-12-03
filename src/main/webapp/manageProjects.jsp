<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (Integer) s.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Projects · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card">
        <div class="card-header">
            <div class="brand-title">My projects 📚</div>
            <div class="brand-tagline">Add little portfolio entries for this academic homepage.</div>
        </div>

        <div class="card-body">
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-error">
                    There was a problem saving your project. Please try again.
                </div>
            <% } %>

            <% if (request.getParameter("saved") != null) { %>
                <div class="alert alert-success">
                    Project saved successfully.
                </div>
            <% } %>

            <form action="projects" method="post">
                <div class="form-group">
                    <label class="form-label">Title</label>
                    <input class="form-input" type="text" name="title"
                           placeholder="AI-powered game bot, battle robot, etc." required>
                </div>

                <div class="form-group">
                    <label class="form-label">Course / context</label>
                    <input class="form-input" type="text" name="course"
                           placeholder="CSE3021, Robotics Club, Personal Project" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea class="form-input" name="description" rows="4"
                              placeholder="What did you build? What tech did you use?"
                              required></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add project</button>
                    <a href="dashboard.jsp" class="btn btn-secondary">Back to dashboard</a>
                </div>
            </form>

            <hr/>

            <div class="section-title">Your project list</div>
            <table class="table">
                <thead>
                <tr>
                    <th>When</th>
                    <th>Title</th>
                    <th>Course / context</th>
                    <th>Description</th>
                </tr>
                </thead>
                <tbody>
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT title, course, description, created_at "
                                   + "FROM projects WHERE user_id = ? ORDER BY created_at DESC";
                        PreparedStatement stmt = conn.prepareStatement(sql);
                        stmt.setInt(1, userId);
                        ResultSet rs = stmt.executeQuery();
                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                %>
                            <tr>
                                <td><%= rs.getTimestamp("created_at") %></td>
                                <td><%= rs.getString("title") %></td>
                                <td><%= rs.getString("course") %></td>
                                <td><%= rs.getString("description") %></td>
                            </tr>
                <%
                        }
                        if (!any) {
                %>
                            <tr>
                                <td colspan="4">No projects yet. Add one above!</td>
                            </tr>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                        <tr>
                            <td colspan="4">Error loading projects.</td>
                        </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>

        <div class="card-footer">
            <span>Academic project board · CSE3021</span>
        </div>
    </div>
</div>
</body>
</html>

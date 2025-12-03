<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.HttpSession"%>
<%@page import="java.sql.*"%>
<%@page import="com.mycompany.academichomepage.DBConnection"%>

<%
    HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) s.getAttribute("userId");

    String name  = null;
    String email = null;
    String major = null;
    String bio   = null;
    String avatarPath = null;
    String resumePath = null;

    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT full_name, email, major, bio, avatar_path, resume_path FROM users WHERE id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);

        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            name        = rs.getString("full_name");
            email       = rs.getString("email");
            major       = rs.getString("major");
            bio         = rs.getString("bio");
            avatarPath  = rs.getString("avatar_path");
            resumePath  = rs.getString("resume_path");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (name == null)  name  = "Student";
    if (email == null) email = "(no email on file)";
    if (major == null || major.isBlank()) major = "Not set yet";
    if (bio == null || bio.isBlank())     bio   = "No bio yet — add one on the profile page.";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card">
        <div class="card-header">
            <div>
                <div class="brand-title">Academic Homepage</div>
                <div class="brand-tagline">A little dark-academia corner of the internet just for you.</div>
            </div>
            <div class="brand-tagline">Student dashboard</div>
        </div>

        <div class="card-body">
            <div class="hero-title">
                Welcome back, <%= name %> 🕯️
            </div>
            <div class="hero-subtitle">
                Use this dashboard to test login, sessions, and database features like a real student portal.
            </div>

            <div class="section-title">Profile snapshot</div>

            <!-- Determine avatar to show (fallback to default) -->
            <%
                String avatarToShow = (avatarPath != null && !avatarPath.isBlank())
                                      ? "uploads/avatars/" + avatarPath
                                      : "uploads/defaults/default-avatar.png";
            %>

            <!-- Circular Avatar -->
            <div style="text-align:center; margin-bottom:20px;">
                <img src="<%= avatarToShow %>"
                     style="
                        width:130px;
                        height:130px;
                        object-fit:cover;
                        border-radius:50%;
                        border:3px solid #dcdcdc;
                        box-shadow:0 3px 10px rgba(0,0,0,0.25);
                     ">
            </div>

            <ul class="stat-list">
                <li>
                    <span class="stat-label">Email</span>
                    <span class="stat-value"><%= email %></span>
                </li>

                <li>
                    <span class="stat-label">Major</span>
                    <span class="stat-value"><%= major %></span>
                </li>

                <li>
                    <span class="stat-label">Bio</span>
                    <span class="stat-value"><%= bio %></span>
                </li>

                <!-- Resume Section -->
                <% if (resumePath != null && !resumePath.isBlank()) { %>
                    <li style="margin-top:10px;">
                        <span class="stat-label">Resume</span>
                        <span class="stat-value">
                            <a href="uploads/resumes/<%= resumePath %>" download
                               class="btn btn-primary"
                               style="padding:6px 10px; font-size:13px;">
                                Download Resume
                            </a>
                        </span>
                    </li>
                <% } else { %>
                    <li style="margin-top:10px;">
                        <span class="stat-label">Resume</span>
                        <span class="stat-value" style="color:#777;">
                            No resume uploaded
                        </span>
                    </li>
                <% } %>
            </ul>

            <p class="form-helper">
                <a href="profile" class="form-helper">Edit profile &amp; bio →</a>
            </p>

            <div class="section-title">Quick actions</div>
            <div class="button-row">
                <a href="contact.jsp" class="btn btn-primary">Send a message</a>
                <a href="viewMessages.jsp" class="btn btn-secondary">View all messages</a>
                <a href="projects" class="btn btn-secondary">Manage projects</a>
                <a href="index.html" class="btn btn-ghost">Back to homepage</a>
            </div>
        </div>

        <div class="card-footer">
            <span>Logged in as <%= name %></span>
            <span><a href="logout" class="form-helper">Log out</a></span>
        </div>
    </div>
</div>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String name  = (String) s.getAttribute("userName");
    String email = (String) s.getAttribute("userEmail");
    String major = (String) s.getAttribute("userMajor");
    String bio   = (String) s.getAttribute("userBio");

    String avatarPath = (String) s.getAttribute("avatarPath");
    String resumePath = (String) s.getAttribute("resumePath");

    if (name == null)  name = "";
    if (email == null) email = "";
    if (major == null) major = "";
    if (bio == null)   bio = "";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit profile · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card card--narrow">
        <div class="form-card-title">Edit your profile 🕯️</div>
        <div class="form-subtitle">
            Update your info for the dashboard.
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">
                Something went wrong while saving your profile. Please try again.
            </div>
        <% } %>

        <form action="profile" method="post" enctype="multipart/form-data">

            <!-- Display current avatar -->
            <% if (avatarPath != null) { %>
                <div style="text-align:center; margin-bottom:12px;">
                    <img src="uploads/avatars/<%= avatarPath %>"
                         style="width:140px; height:auto; border-radius:10px;">
                </div>
            <% } %>

            <div class="form-group">
                <label class="form-label">Full name</label>
                <input class="form-input" type="text" name="fullName"
                       value="<%= name %>" required>
            </div>

            <div class="form-group">
                <label class="form-label">Email (read-only)</label>
                <input class="form-input" type="email" value="<%= email %>" disabled>
            </div>

            <div class="form-group">
                <label class="form-label">Major</label>
                <input class="form-input" type="text" name="major"
                       value="<%= major %>">
            </div>

            <div class="form-group">
                <label class="form-label">Short bio</label>
                <textarea class="form-input" name="bio" rows="4"
                          placeholder="Tell us something academic and dramatic."><%= bio %></textarea>
            </div>

            <!-- New: Upload new avatar -->
            <div class="form-group">
                <label class="form-label">Profile picture</label>
                <input class="form-input" type="file" name="avatar" accept="image/*">
            </div>

            <!-- New: Upload resume -->
            <div class="form-group">
                <label class="form-label">Resume (PDF)</label>
                <input class="form-input" type="file" name="resume" accept=".pdf">
            </div>

            <!-- Display resume download link -->
            <% if (resumePath != null) { %>
                <div class="form-group">
                    <a href="uploads/resumes/<%= resumePath %>" download>
                        Download your current resume
                    </a>
                </div>
            <% } %>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Save changes</button>
                <a href="dashboard.jsp" class="btn btn-secondary">Back to dashboard</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>

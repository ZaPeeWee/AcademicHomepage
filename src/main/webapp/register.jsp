<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card card--narrow">
        <div class="form-card-title">Create your account ✨</div>
        <div class="form-subtitle">
            Sign up to access the student dashboard and save your info.
        </div>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            String registered = request.getParameter("registered");
        %>

        <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                <%= errorMessage %>
            </div>
        <% } else if ("1".equals(registered)) { %>
            <div class="alert alert-success">
                Account created 🎉 You can log in now.
            </div>
        <% } %>

        <form action="register" method="post">
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input class="form-input" type="text" name="fullName" required>
            </div>

            <div class="form-group">
                <label class="form-label">Email</label>
                <input class="form-input" type="email" name="email" required>
            </div>

            <div class="form-group">
                <label class="form-label">Password</label>
                <input class="form-input" type="password" name="password" required>
                <div class="form-helper">
                    It’s for this project only, so it doesn’t need to be fancy 😊
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Major (optional)</label>
                <input class="form-input" type="text" name="major"
                       placeholder="Computer Science, Mechanical Engineering, etc.">
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Sign Up</button>
                <a href="login.jsp" class="btn btn-secondary">Already have an account?</a>
            </div>
        </form>

        <div class="card-footer">
            <span>← <a href="index.html" class="form-helper">Back to homepage</a></span>
            <span>Academic Homepage · CSE3021</span>
        </div>
    </div>
</div>
</body>
</html>

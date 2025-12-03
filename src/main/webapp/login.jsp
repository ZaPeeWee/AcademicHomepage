<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card card--narrow">
        <div class="form-card-title">Welcome back 👋</div>
        <div class="form-subtitle">
            Log in to access your dashboard and see project features in action.
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">
                Invalid email or password. Double-check and try again.
            </div>
        <% } %>

        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success">
                Registration successful! You can log in now.
            </div>
        <% } %>

        <form action="login" method="post">
            <div class="form-group">
                <label class="form-label">Email</label>
                <input class="form-input" type="email" name="email" required>
            </div>

            <div class="form-group">
                <label class="form-label">Password</label>
                <input class="form-input" type="password" name="password" required>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Log In</button>
                <a href="register.jsp" class="btn btn-secondary">Create a new account</a>
            </div>
        </form>

        <div class="card-footer">
            <span>← <a href="index.html" class="form-helper">Back to homepage</a></span>
            <span>Session-based login using HttpSession</span>
        </div>
    </div>
</div>
</body>
</html>

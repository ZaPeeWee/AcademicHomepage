<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
</head>
<body>
<h1>Register</h1>
<form action="RegisterServlet" method="post">
    Username: <input type="text" name="username" required><br><br>
    Email: <input type="email" name="email"><br><br>
    Password: <input type="password" name="password" required><br><br>
    <button type="submit">Register</button>
</form>
<a href="login.jsp">Already have an account? Login</a>
</body>
</html>

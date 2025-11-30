<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Contact</title>
</head>
<body>
<h1>Contact Me</h1>
<form action="MessageServlet" method="post">
    Name: <input type="text" name="name" required><br><br>
    Email: <input type="email" name="email" required><br><br>
    Message:<br>
    <textarea name="message" rows="5" cols="40" required></textarea><br><br>
    <button type="submit">Send</button>
</form>
<a href="index.jsp">Back to Home</a>
</body>
</html>

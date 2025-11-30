<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.mycompany.academichomepage.DBConnection" %>
<%
    // EXTRA CREDIT: Session check (must be logged in)
    String username = (String) session.getAttribute("username");
    Boolean loggedIn = (Boolean) session.getAttribute("loggedIn");
    if (username == null || loggedIn == null || !loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
</head>
<body>
<h1>Welcome, <%= username %>!</h1>

<h2>Your Projects</h2>
<ul>
<%
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT title, description, link FROM projects";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
%>
    <li>
        <strong><%= rs.getString("title") %></strong><br>
        <%= rs.getString("description") %><br>
        <a href="<%= rs.getString("link") %>"><%= rs.getString("link") %></a>
    </li>
<%
            }
        }
    } catch (Exception e) {
        out.println("Error loading projects: " + e.getMessage());
    }
%>
</ul>

<a href="contact.jsp">Contact Me</a> |
<a href="viewMessages.jsp">View Messages</a> |
<a href="logout">Logout</a> |
<a href="index.html">Home</a>
</body>
</html>

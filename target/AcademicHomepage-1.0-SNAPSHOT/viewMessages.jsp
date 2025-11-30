<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.mycompany.academichomepage.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Messages</title>
</head>
<body>
<h1>Messages</h1>
<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Message</th>
        <th>Created</th>
    </tr>
<%
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT * FROM messages ORDER BY created_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("name") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getString("message") %></td>
        <td><%= rs.getTimestamp("created_at") %></td>
    </tr>
<%
            }
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='5'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
</table>
<a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>

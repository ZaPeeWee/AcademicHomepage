<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.mycompany.academichomepage.DBConnection"%>
<%
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) s.getAttribute("userId");
    String userName = (String) s.getAttribute("userName");
    String role = (String) s.getAttribute("role");
    if (role == null) role = "student";

    Connection conn = null;
    PreparedStatement inboxPs = null;
    PreparedStatement sentPs = null;
    ResultSet inboxRs = null;
    ResultSet sentRs = null;

    try {
        conn = DBConnection.getConnection();

        // Inbox
        String inboxSql;
        if ("admin".equalsIgnoreCase(role)) {
            inboxSql =
                "SELECT m.id, m.name, m.email, m.message_text, m.created_at, " +
                "       u.full_name AS sender_name " +
                "FROM messages m " +
                "LEFT JOIN users u ON m.user_id = u.id " +
                "WHERE m.recipient_id IS NULL OR m.recipient_id = ? " +
                "ORDER BY m.created_at DESC";
        } else {
            inboxSql =
                "SELECT m.id, m.name, m.email, m.message_text, m.created_at, " +
                "       u.full_name AS sender_name " +
                "FROM messages m " +
                "LEFT JOIN users u ON m.user_id = u.id " +
                "WHERE m.recipient_id = ? " +
                "ORDER BY m.created_at DESC";
        }

        inboxPs = conn.prepareStatement(inboxSql);
        inboxPs.setInt(1, userId);
        inboxRs = inboxPs.executeQuery();

        // Sent
        String sentSql =
            "SELECT m.id, m.message_text, m.created_at, " +
            "       u.full_name AS recipient_name " +
            "FROM messages m " +
            "LEFT JOIN users u ON m.recipient_id = u.id " +
            "WHERE m.user_id = ? " +
            "ORDER BY m.created_at DESC";

        sentPs = conn.prepareStatement(sentSql);
        sentPs.setInt(1, userId);
        sentRs = sentPs.executeQuery();

%>
<!DOCTYPE html>
<html>
<head>
    <title>Messages · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card">
        <div class="card-header">
            <div class="brand-title">Messages</div>
            <div class="brand-tagline">Inbox and sent messages</div>
        </div>

        <div class="card-body">
            <div class="hero-title">
                Hi, <%= userName %> 🕯️
            </div>
            <div class="hero-subtitle">
                Here’s your little correspondence archive.
            </div>

            <div class="section-title">Inbox</div>
            <table class="table-messages">
                <thead>
                <tr>
                    <th>From</th>
                    <th>Email</th>
                    <th>Message</th>
                    <th>Received</th>
                </tr>
                </thead>
                <tbody>
                <%
                    boolean hasInbox = false;
                    while (inboxRs.next()) {
                        hasInbox = true;
                        String senderName  = inboxRs.getString("sender_name");
                        String name        = inboxRs.getString("name");
                        String fromName    = (senderName != null ? senderName : name);
                %>
                <tr>
                    <td><%= fromName %></td>
                    <td><%= inboxRs.getString("email") %></td>
                    <td><%= inboxRs.getString("message_text") %></td>
                    <td><%= inboxRs.getTimestamp("created_at") %></td>
                </tr>
                <%
                    }
                    if (!hasInbox) {
                %>
                <tr>
                    <td colspan="4" class="table-empty">
                        No messages in your inbox yet.
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <div class="section-title">Sent</div>
            <table class="table-messages">
                <thead>
                <tr>
                    <th>To</th>
                    <th>Message</th>
                    <th>Sent</th>
                </tr>
                </thead>
                <tbody>
                <%
                    boolean hasSent = false;
                    while (sentRs.next()) {
                        hasSent = true;
                        String recipientName = sentRs.getString("recipient_name");
                        if (recipientName == null) {
                            recipientName = ("admin".equalsIgnoreCase(role) ? "Guests / site visitors" : "Admin");
                        }
                %>
                <tr>
                    <td><%= recipientName %></td>
                    <td><%= sentRs.getString("message_text") %></td>
                    <td><%= sentRs.getTimestamp("created_at") %></td>
                </tr>
                <%
                    }
                    if (!hasSent) {
                %>
                <tr>
                    <td colspan="3" class="table-empty">
                        You haven’t sent any messages yet.
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>

            <div class="button-row" style="margin-top: 1.5rem;">
                <a href="contact.jsp" class="btn btn-primary">Write a new message</a>
                <a href="dashboard.jsp" class="btn btn-secondary">Back to dashboard</a>
            </div>
        </div>

        <div class="card-footer">
            <span>Logged in as <%= userName %></span>
            <span><a href="logout" class="form-helper">Log out</a></span>
        </div>
    </div>
</div>
</body>
</html>
<%
    } finally {
        if (inboxRs != null) try { inboxRs.close(); } catch (SQLException ignore) {}
        if (sentRs != null)  try { sentRs.close(); }  catch (SQLException ignore) {}
        if (inboxPs != null) try { inboxPs.close(); } catch (SQLException ignore) {}
        if (sentPs != null)  try { sentPs.close(); }  catch (SQLException ignore) {}
        if (conn != null)    try { conn.close(); }    catch (SQLException ignore) {}
    }
%>

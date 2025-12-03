<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, com.mycompany.academichomepage.DBConnection"%>
<%
    // Session info
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    Integer currentUserId = null;
    String currentName = null;
    String currentEmail = null;
    String role = null;

    if (s != null) {
        currentUserId = (Integer) s.getAttribute("userId");
        currentName   = (String) s.getAttribute("userName");
        currentEmail  = (String) s.getAttribute("userEmail");
        role          = (String) s.getAttribute("role");
    }

    boolean loggedIn = (currentUserId != null);

    // If logged in, load other students as possible recipients
    ResultSet recipientsRs = null;
    Connection conn = null;
    PreparedStatement ps = null;

    if (loggedIn) {
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT id, full_name "
                       + "FROM users "
                       + "WHERE id <> ? "
                       + "ORDER BY full_name";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, currentUserId);
            recipientsRs = ps.executeQuery();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Contact · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card card--narrow">
        <div class="form-card-title">
            <% if (loggedIn) { %>
                Send a message ✉️
            <% } else { %>
                Contact the student · Academic Homepage
            <% } %>
        </div>

        <div class="form-subtitle">
            <% if (loggedIn) { %>
                Choose who you want to message and we’ll keep it inside this little academic universe.
            <% } else { %>
                This form sends a message to the site owner (admin). You don’t need an account to say hi.
            <% } %>
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">
                Something went wrong sending your message. Make sure all fields are filled in.
            </div>
        <% } %>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                Message sent successfully. Thank you 🌙
            </div>
        <% } %>

        <form action="contact" method="post">
            <%-- If logged in, allow choosing another student as recipient --%>
            <% if (loggedIn) { %>
                <div class="form-group">
                    <label class="form-label">Send to</label>
                    <select class="form-input" name="recipientId" required>
                        <option value="">— Select a student —</option>
                        <%
                            if (recipientsRs != null) {
                                while (recipientsRs.next()) {
                                    int uid = recipientsRs.getInt("id");
                                    String uname = recipientsRs.getString("full_name");
                        %>
                            <option value="<%= uid %>"><%= uname %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                    <div class="form-helper">
                        This list shows everyone who has created an account, except you.
                    </div>
                </div>
            <% } else { %>
                <%-- not logged in: no recipientId; goes to admin/general inbox --%>
                <input type="hidden" name="recipientId" value="">
            <% } %>

            <div class="form-group">
                <label class="form-label">Your name</label>
                <input class="form-input" type="text" name="name"
                       value="<%= (currentName != null ? currentName : "") %>"
                       required>
            </div>

            <div class="form-group">
                <label class="form-label">Your email</label>
                <input class="form-input" type="email" name="email"
                       value="<%= (currentEmail != null ? currentEmail : "") %>"
                       required>
            </div>

            <div class="form-group">
                <label class="form-label">Message</label>
                <textarea class="form-input" name="message" rows="5" required
                          placeholder="Write your thoughts, questions, or feedback here."></textarea>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Send message</button>
                <a href="index.html" class="btn btn-secondary">Back to homepage</a>
            </div>
        </form>

        <div class="card-footer">
            <% if (loggedIn) { %>
                <span>Logged in as <%= currentName %></span>
                <span><a href="dashboard.jsp" class="form-helper">← Back to dashboard</a></span>
            <% } else { %>
                <span>Not logged in</span>
                <span><a href="login.jsp" class="form-helper">Log in</a></span>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
<%
    // clean up JDBC objects
    if (recipientsRs != null) try { recipientsRs.close(); } catch (SQLException ignore) {}
    if (ps != null)           try { ps.close(); }         catch (SQLException ignore) {}
    if (conn != null)         try { conn.close(); }       catch (SQLException ignore) {}
%>

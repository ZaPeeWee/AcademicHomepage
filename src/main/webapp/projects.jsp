<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, com.mycompany.academichomepage.Project"%>
<%
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s == null || s.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    if (projects == null) {
        projects = java.util.Collections.emptyList();
    }
    Project editProject = (Project) request.getAttribute("editProject");
    boolean isEditing = (editProject != null);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Projects · Academic Homepage</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="page-wrapper">
    <div class="card">
        <div class="card-header">
            <div class="brand-title">My Projects 📚</div>
            <div class="brand-tagline">
                Add little portfolio entries for this academic homepage.
            </div>
        </div>

        <div class="card-body">
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-error">
                    There was a problem saving your project. Make sure you at least enter a title.
                </div>
            <% } %>
            <% if (request.getParameter("added") != null) { %>
                <div class="alert alert-success">
                    Project added successfully ✅
                </div>
            <% } %>
            <% if (request.getParameter("updated") != null) { %>
                <div class="alert alert-success">
                    Project updated successfully ✏️
                </div>
            <% } %>
            <% if (request.getParameter("deleted") != null) { %>
                <div class="alert alert-success">
                    Project deleted 🗑️
                </div>
            <% } %>

            <!-- CREATE / EDIT FORM -->
            <form action="projects" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="<%= isEditing ? "update" : "create" %>">
                <% if (isEditing) { %>
                    <input type="hidden" name="projectId" value="<%= editProject.getId() %>">
                <% } %>

                <div class="form-group">
                    <label class="form-label">Title</label>
                    <input class="form-input" type="text" name="title"
                           value="<%= isEditing ? editProject.getTitle() : "" %>"
                           placeholder="AI-powered game bot, battle robot, etc." required>
                </div>

                <div class="form-group">
                    <label class="form-label">Course / context</label>
                    <input class="form-input" type="text" name="course"
                           value="<%= isEditing && editProject.getCourse() != null ? editProject.getCourse() : "" %>"
                           placeholder="CSE3021, Robotics Club, Personal Project">
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea class="form-input" name="description" rows="4"
                              placeholder="What did you build? What tech did you use?"><%= isEditing && editProject.getDescription() != null ? editProject.getDescription() : "" %></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label">Project link (optional)</label>
                    <input class="form-input" type="url" name="projectUrl"
                           value="<%= isEditing && editProject.getProjectUrl() != null ? editProject.getProjectUrl() : "" %>"
                           placeholder="https://github.com/username/project or deployed site">
                </div>

                <div class="form-group">
                    <label class="form-label">Project image (optional)</label>
                    <input class="form-input" type="file" name="imageFile" accept="image/*">
                    <div class="form-helper">
                        <% if (isEditing && editProject.getImageUrl() != null) { %>
                            Current image will be kept unless you choose a new one.
                        <% } else { %>
                            Choose a screenshot or thumbnail to visually show your project.
                        <% } %>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%= isEditing ? "Save changes" : "Add project" %>
                    </button>
                    <a href="dashboard.jsp" class="btn btn-secondary">Back to dashboard</a>
                    <% if (isEditing) { %>
                        <a href="projects" class="btn btn-ghost btn-small">Cancel edit</a>
                    <% } %>
                </div>
            </form>

            <hr class="divider"/>

            <div class="section-title">Your project list</div>

            <% if (projects.isEmpty()) { %>
                <p class="form-helper">No projects yet. Add your first one above ✨</p>
            <% } else { %>
                <ul class="project-list">
                    <% for (Project p : projects) {
                           String img = p.getImageUrl();
                           String url = p.getProjectUrl();
                    %>
                        <li>
                            <% if (img != null && !img.isBlank()) { %>
                                <div style="margin-bottom:0.4rem;">
                                    <img src="<%= request.getContextPath() + "/" + img %>"
                                         alt="Project preview"
                                         style="max-width:100%; max-height:180px; border-radius:12px;
                                                border:1px solid rgba(184,147,87,0.6); object-fit:cover;">
                                </div>
                            <% } %>

                            <div class="stat-label"><%= p.getTitle() %></div>

                            <div class="form-helper">
                                <%= (p.getCourse() == null ? "" : p.getCourse()) %>
                            </div>

                            <div class="form-helper">
                                <%= (p.getDescription() == null ? "" : p.getDescription()) %>
                            </div>

                            <% if (url != null && !url.isBlank()) { %>
                                <div class="form-helper" style="margin-top:0.3rem;">
                                    <a href="<%= url %>" target="_blank">View project ↗</a>
                                </div>
                            <% } %>

                            <div class="project-actions">
                                <a href="projects?editId=<%= p.getId() %>" class="btn btn-secondary btn-small">
                                    Edit
                                </a>
                                <form action="projects" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="projectId" value="<%= p.getId() %>">
                                    <button type="submit" class="btn btn-ghost btn-small"
                                            onclick="return confirm('Delete this project?');">
                                        Delete
                                    </button>
                                </form>
                            </div>

                            <div class="form-helper" style="margin-top:0.3rem; font-size:0.75rem;">
                                Added on <%= p.getCreatedAt() %>
                            </div>
                        </li>
                    <% } %>
                </ul>
            <% } %>
        </div>

        <div class="card-footer">
            <span>Projects are stored in the <code>projects</code> table.</span>
        </div>
    </div>
</div>
</body>
</html>

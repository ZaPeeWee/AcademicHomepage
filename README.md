# AcademicHomepage – Backend & Database Milestone

## Overview
This project is a personal Academic Homepage web application built using:
- Java Servlets
- JSP
- MySQL
- Apache Tomcat 11
- NetBeans 22 / Maven

The backend supports user registration, login (with session tracking), a contact form,
and viewing messages stored in the database.

## Database Schema

Database name: `academic_homepage`

Tables:

1. `users`
   - `id` INT AUTO_INCREMENT PRIMARY KEY
   - `username` VARCHAR(50) UNIQUE NOT NULL
   - `password` VARCHAR(255) NOT NULL
   - `email` VARCHAR(100)

2. `projects`
   - `id` INT AUTO_INCREMENT PRIMARY KEY
   - `title` VARCHAR(100) NOT NULL
   - `description` TEXT
   - `link` VARCHAR(255)

3. `messages`
   - `id` INT AUTO_INCREMENT PRIMARY KEY
   - `name` VARCHAR(100)
   - `email` VARCHAR(100)
   - `message` TEXT
   - `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP

SQL script: `academic_homepage.sql`

## How to Run

1. Create the database:
   - Use MySQL Workbench or NetBeans SQL window
   - Run the script in `academic_homepage.sql`

2. Configure database connection:
   - In `DBConnection.java`, set:
     - URL: `jdbc:mysql://localhost:3306/academic_homepage`
     - USER: your MySQL username (e.g., `root`)
     - PASS: your MySQL password

3. Build the project:
   - In NetBeans, right-click the project → **Clean and Build**

4. Run with Tomcat:
   - Right-click the project → **Run**
   - Tomcat will deploy at: `http://localhost:8080/AcademicHomepage/`

## Servlet URLs

- `POST /RegisterServlet`
  - Handles user registration and inserts into `users` table.

- `POST /LoginServlet`
  - Authenticates user against `users` table.
  - On success, creates `HttpSession` with attribute `username`.
  - Redirects to `dashboard.jsp`.

- `POST /MessageServlet`
  - Handles contact form submissions.
  - Inserts into `messages` table.

## Frontend Flow

- `index.jsp` → links to `register.jsp`, `login.jsp`, `contact.jsp`.
- `register.jsp` → `RegisterServlet` → `users` table.
- `login.jsp` → `LoginServlet` → `dashboard.jsp` (session-based).
- `contact.jsp` → `MessageServlet` → `messages` table.
- `viewMessages.jsp` → reads from `messages` and displays all messages.

## CRUD Summary

- **Create**: registration (`users`), contact messages (`messages`).
- **Read**: dashboard project list, viewMessages displays messages.
- **Update/Delete**: could be added later (not required for this milestone).

## Bonus Features

- Uses `PreparedStatement` for all SQL queries to avoid SQL injection.
- Uses `HttpSession` in `LoginServlet` and `dashboard.jsp` to track logged-in user.
- Deployed and tested on Apache Tomcat 11.
- All database queries in servlets and JSP pages use `PreparedStatement` to help prevent SQL injection.
- User login is implemented with `HttpSession` in `LoginServlet` and checked in `dashboard.jsp`.
- A `LogoutServlet` (`/logout`) is provided to invalidate the session and securely log out users.

-- ==========================================================
-- Create Database
-- ==========================================================
CREATE DATABASE IF NOT EXISTS academic_homepage
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_general_ci;

USE academic_homepage;

-- ==========================================================
-- 1) USERS TABLE
-- ==========================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('student','instructor','visitor') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- 2) PROJECTS TABLE (Each project belongs to a user)
-- ==========================================================
CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    link VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_projects_user FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_projects_user (user_id)
);

-- ==========================================================
-- 3) MESSAGES TABLE (Contact form messages)
-- ==========================================================
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_messages_user FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_messages_user (user_id)
);

-- ==========================================================
-- OPTIONAL SAMPLE DATA (BONUS POINTS, SAFE TO LEAVE IN)
-- ==========================================================
INSERT INTO users (full_name,email,password,role) VALUES
('Alice Student','alice@example.com','pass123','student'),
('Dr. Brown','brown@example.com','teach123','instructor');

INSERT INTO projects (user_id,title,description,link) VALUES
(1,'My Portfolio','Website built in Java','https://example.com'),
(1,'Robotics Club','Arduino robot project','https://youtube.com');

INSERT INTO messages (user_id,name,subject,body) VALUES
(1,'Alice','Question','How do I deploy?');

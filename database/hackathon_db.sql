-- ============================================
-- HACKATHON MANAGEMENT SYSTEM
-- DATABASE SCRIPT
-- ============================================

CREATE DATABASE IF NOT EXISTS hackathon_db;
USE hackathon_db;


-- ============================================
-- 1. HACKATHON TABLE
-- ============================================

CREATE TABLE hackathon (
    hackathon_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location VARCHAR(100)
);


-- ============================================
-- 2. PARTICIPANT TABLE
-- ============================================

CREATE TABLE participant (
    participant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    college VARCHAR(100),
    phone VARCHAR(15)
);


-- ============================================
-- 3. TEAM TABLE
-- ============================================

CREATE TABLE team (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    hackathon_id INT NOT NULL,
    FOREIGN KEY (hackathon_id)
        REFERENCES hackathon(hackathon_id)
);


-- ============================================
-- 4. TEAM_MEMBER TABLE
-- ============================================

CREATE TABLE team_member (
    team_id INT,
    participant_id INT,
    role VARCHAR(50),
    PRIMARY KEY (team_id, participant_id),
    FOREIGN KEY (team_id)
        REFERENCES team(team_id),
    FOREIGN KEY (participant_id)
        REFERENCES participant(participant_id)
);


-- ============================================
-- 5. PROJECT TABLE
-- ============================================

CREATE TABLE project (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    technology VARCHAR(200),
    FOREIGN KEY (team_id)
        REFERENCES team(team_id)
);


-- ============================================
-- 6. JUDGE TABLE
-- ============================================

CREATE TABLE judge (
    judge_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    expertise VARCHAR(100)
);


-- ============================================
-- 7. EVALUATION TABLE
-- ============================================

CREATE TABLE evaluation (
    evaluation_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    judge_id INT NOT NULL,
    innovation_score DECIMAL(5,2),
    technical_score DECIMAL(5,2),
    presentation_score DECIMAL(5,2),
    comments TEXT,
    FOREIGN KEY (project_id)
        REFERENCES project(project_id),
    FOREIGN KEY (judge_id)
        REFERENCES judge(judge_id)
);


-- ============================================
-- SAMPLE DATA
-- ============================================

INSERT INTO hackathon
(name, description, start_date, end_date, location)
VALUES
(
    'College Hackathon 2026',
    'A college level hackathon for students to build innovative projects.',
    '2026-10-15',
    '2026-10-16',
    'College Auditorium'
);


INSERT INTO participant
(name, email, college, phone)
VALUES
('Rahul Sharma', 'rahul@gmail.com', 'ABC College', '9876543210'),
('Aman Verma', 'aman@gmail.com', 'ABC College', '9876543211'),
('Priya Singh', 'priya@gmail.com', 'XYZ College', '9876543212'),
('Rohan Mehta', 'rohan@gmail.com', 'XYZ College', '9876543213'),
('Neha Gupta', 'neha@gmail.com', 'ABC College', '9876543214'),
('Arjun Patel', 'arjun@gmail.com', 'PQR College', '9876543215');


INSERT INTO team
(team_name, hackathon_id)
VALUES
('Code Warriors', 1),
('Tech Titans', 1);


INSERT INTO team_member
(team_id, participant_id, role)
VALUES
(1, 1, 'Team Leader'),
(1, 2, 'Developer'),
(1, 5, 'Designer'),
(2, 3, 'Team Leader'),
(2, 4, 'Developer'),
(2, 6, 'Developer');


INSERT INTO project
(team_id, title, description, technology)
VALUES
(
    1,
    'Smart Attendance System',
    'An automated attendance system using face recognition.',
    'Python, OpenCV, MySQL'
),
(
    2,
    'Health Assistant',
    'A system that provides basic health recommendations.',
    'Python, Machine Learning, MySQL'
);


INSERT INTO judge
(name, email, expertise)
VALUES
('Dr. Rajesh Kumar', 'rajesh@gmail.com', 'Artificial Intelligence'),
('Prof. Anjali Sharma', 'anjali@gmail.com', 'Database Systems');


INSERT INTO evaluation
(project_id, judge_id, innovation_score, technical_score, presentation_score, comments)
VALUES
(1, 1, 9, 8, 9, 'Very innovative project with good implementation.'),
(1, 2, 8, 9, 8, 'Good database design and presentation.'),
(2, 1, 8, 9, 9, 'Good idea and strong technical implementation.'),
(2, 2, 9, 8, 8, 'Useful project with good presentation.');


-- ============================================
-- IMPORTANT SQL QUERIES
-- ============================================

-- Display all participants
SELECT * FROM participant;


-- Display all teams
SELECT * FROM team;


-- Display team members
SELECT
    t.team_name,
    p.name AS participant_name,
    tm.role
FROM team t
JOIN team_member tm
    ON t.team_id = tm.team_id
JOIN participant p
    ON tm.participant_id = p.participant_id;


-- Display projects with team names
SELECT
    p.title AS project_name,
    t.team_name,
    p.technology
FROM project p
JOIN team t
    ON p.team_id = t.team_id;


-- Calculate project average scores
SELECT
    p.title,
    AVG(
        e.innovation_score +
        e.technical_score +
        e.presentation_score
    ) AS average_score
FROM project p
JOIN evaluation e
    ON p.project_id = e.project_id
GROUP BY p.project_id, p.title;


-- Display leaderboard
SELECT
    p.title AS project,
    t.team_name,
    AVG(
        e.innovation_score +
        e.technical_score +
        e.presentation_score
    ) AS average_score
FROM project p
JOIN team t
    ON p.team_id = t.team_id
JOIN evaluation e
    ON p.project_id = e.project_id
GROUP BY p.project_id, p.title, t.team_name
ORDER BY average_score DESC;
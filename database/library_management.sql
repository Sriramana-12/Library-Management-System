-- Library Management System - Database Schema
-- DBMS Capstone Project | Aditya University
-- Team: M. Sri Ramana, K. Chandru, G. Suhas, A. Datta Sri Sai

-- Drop existing objects (for clean re-runs)
DROP TABLE IF EXISTS fines CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS members CASCADE;
DROP TABLE IF EXISTS book_copies CASCADE;
DROP TABLE IF EXISTS book_authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP VIEW IF EXISTS current_loans;
DROP INDEX IF EXISTS one_active_loan_per_copy;

-- ============================================
-- CREATE ALL TABLES
-- ============================================

CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(120) NOT NULL
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    publisher_id INT NOT NULL REFERENCES publishers(publisher_id),
    category_id INT NOT NULL REFERENCES categories(category_id),
    publication_year INT CHECK (publication_year BETWEEN 1000 AND 2100)
);

CREATE TABLE book_authors (
    book_id INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES authors(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_copies (
    copy_id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(book_id),
    accession_no VARCHAR(30) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'Available' CHECK (status IN ('Available', 'Issued', 'Lost', 'Damaged'))
);

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    join_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(15) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive'))
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    role VARCHAR(20) CHECK (role IN ('Librarian', 'Admin'))
);

CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    copy_id INT NOT NULL REFERENCES book_copies(copy_id),
    member_id INT NOT NULL REFERENCES members(member_id),
    staff_id INT NOT NULL REFERENCES staff(staff_id),
    issue_date DATE DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    CHECK (due_date >= issue_date),
    CHECK (return_date IS NULL OR return_date >= issue_date)
);

CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(book_id),
    member_id INT NOT NULL REFERENCES members(member_id),
    reservation_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(15) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Fulfilled', 'Cancelled'))
);

CREATE TABLE fines (
    fine_id SERIAL PRIMARY KEY,
    loan_id INT UNIQUE NOT NULL REFERENCES loans(loan_id),
    amount NUMERIC(8,2) NOT NULL CHECK (amount >= 0),
    paid_status BOOLEAN DEFAULT FALSE,
    paid_date DATE,
    CHECK (
        (paid_status = FALSE AND paid_date IS NULL)
        OR (paid_status = TRUE AND paid_date IS NOT NULL)
    )
);

-- Create index and view
CREATE UNIQUE INDEX one_active_loan_per_copy
ON loans(copy_id)
WHERE return_date IS NULL;

CREATE VIEW current_loans AS
SELECT * FROM loans WHERE return_date IS NULL;

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

INSERT INTO publishers(publisher_name) VALUES
('Pearson'),
('OReilly Media');

INSERT INTO categories(category_name) VALUES
('Computer Science'),
('Fiction'),
('Artificial Intelligence');

INSERT INTO authors(author_name) VALUES
('Ramez Elmasri'),
('Robert C. Martin'),
('Stuart Russell');

INSERT INTO books(isbn, title, publisher_id, category_id, publication_year) VALUES
('9780133970777', 'Database Systems', 1, 1, 2016),
('9780132350884', 'Clean Code', 1, 1, 2008),
('9780134610993', 'Artificial Intelligence: A Modern Approach', 2, 3, 2021);

INSERT INTO book_authors VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO book_copies(book_id, accession_no) VALUES
(1, 'ACC-001'),
(1, 'ACC-002'),
(2, 'ACC-003'),
(3, 'ACC-004');

INSERT INTO members(name, email, phone) VALUES
('Anil Kumar', 'anil@example.com', '9876543210'),
('Priya Reddy', 'priya@example.com', '9876501234');

INSERT INTO staff(name, email, role) VALUES
('Library Admin', 'admin@library.edu', 'Admin'),
('S. Lakshmi', 'lakshmi@library.edu', 'Librarian');

INSERT INTO loans(copy_id, member_id, staff_id, due_date)
VALUES (1, 1, 2, CURRENT_DATE + 14);

UPDATE book_copies
SET status = 'Issued'
WHERE copy_id = 1;

INSERT INTO reservations(book_id, member_id) VALUES
(3, 2);
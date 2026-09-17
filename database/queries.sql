-- Library Management System - Sample Queries
-- DBMS Capstone Project | Aditya University

-- Query 1: List all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Query 2: Show all books
SELECT * FROM books;

-- Query 3: Available books
SELECT b.title, bc.accession_no, bc.status
FROM books b
JOIN book_copies bc USING (book_id)
WHERE bc.status = 'Available';

-- Query 4: Active loans
SELECT m.name AS member_name, b.title, l.issue_date, l.due_date
FROM loans l
JOIN members m USING (member_id)
JOIN book_copies bc USING (copy_id)
JOIN books b USING (book_id)
WHERE l.return_date IS NULL;

-- Query 5: Category statistics
SELECT c.category_name, COUNT(b.book_id) AS book_count
FROM categories c
LEFT JOIN books b USING (category_id)
GROUP BY c.category_name
ORDER BY book_count DESC;

-- Query 6: Overdue loans
SELECT * FROM loans 
WHERE return_date IS NULL 
  AND due_date < CURRENT_DATE;

-- Query 7: Member borrowing history
SELECT m.name, b.title, l.issue_date, l.due_date, l.return_date
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
ORDER BY l.issue_date DESC;

-- Query 8: Fine calculation
SELECT
    l.loan_id,
    m.name AS member_name,
    b.title,
    CURRENT_DATE - l.due_date AS overdue_days,
    (CURRENT_DATE - l.due_date) * 5.00 AS calculated_fine
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE;
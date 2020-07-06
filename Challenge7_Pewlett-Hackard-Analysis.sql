-- Creating tables from PH-EmployeeDB
select * from departments;

Create table departments (
	dept_no varchar(4) not null,
	dept_name varchar(40) not null,
	primary key (dept_no),
	unique (dept_name)
);

select * from employees;
create table employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);

select * from dept_manager;
CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

select * from salaries;
CREATE TABLE salaries (
  	emp_no INT NOT NULL,
  	salary INT NOT NULL,
  	from_date DATE NOT NULL,
  	to_date DATE NOT NULL,
  	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  	PRIMARY KEY (emp_no)
);

select * from Dept_Emp;
create table Dept_Emp (
	emp_no int not null, 
	dept_no varchar not null,
	from_date date not null, 
	to_date date not null,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	primary key (dept_no, emp_no)
);

select * from titles;
create table titles (
	emp_no int not null,
	title varchar not null,
	from_date date not null,
	to_date date not null, 
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	primary key (emp_no, title, from_date)
);

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Retirement eligibility
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

select * from retirement_info; 

DROP TABLE retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no, 
	ri.first_name,
	ri.last_name,
	de.from_date,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

select * from current_emp;

-- Employee count by department number (current employee)
SELECT COUNT(ce.emp_no), de.dept_no
-- INTO count_employee_by_dept
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.to_date
INTO emp_info
FROM employees as e
	INNER JOIN salaries as s
		ON (e.emp_no = s.emp_no)
	INNER JOIN dept_emp as de
		ON (e.emp_no = de.emp_no)
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
-- INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name	
-- INTO dept_info
FROM current_emp as ce
	INNER JOIN dept_emp AS de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no);

SELECT e.emp_no,
e.first_name,
e.last_name,
de.dept_no
-- INTO sales_dept_info
from employees as e
left join dept_emp as de
on (e.emp_no = de.emp_no)
where (dept_no = 'd007');

SELECT ri.emp_no,
ri.first_name,
ri.last_name,
de.dept_no
-- INTO mentoring_info_Sales_Develop
from retirement_info as ri
left join dept_emp as de
on (ri.emp_no = de.emp_no)
where dept_no IN ('d007', 'd005');

select * from retirement_info;

--creating table for retiring employees by title
SELECT ri.emp_no, 
	ri.first_name, 
	ri.last_name, 
	t.title,
	t.from_date, 
	s.salary
INTO Retiring_Employees_by_Title
from retirement_info as ri
	inner join titles as t
		on (ri.emp_no = t.emp_no)
	inner join salaries as s
		on (ri.emp_no = s.emp_no)
group by ri.emp_no, 
	ri.first_name, 
	ri.last_name, 
	t.title,
	t.from_date, 
	s.salary	
;

select * from retiring_employees_by_title;

-- Partition the data to show only most recent title per employee
SELECT emp_no,
 first_name,
 last_name,
 from_date,
 salary,
 title
INTO Retiring_employees_by_recentdate
FROM
 	(SELECT emp_no,
 			first_name,
 			last_name,
 			from_date,
	 		title,
 			salary, ROW_NUMBER() OVER
 				(PARTITION BY (emp_no)
					 ORDER BY from_date DESC) rn
 						FROM Retiring_Employees_by_Title
 ) tmp WHERE rn = 1
ORDER BY emp_no;


--Mentorship Eligibility
SELECT e.emp_no, e.first_name, e.last_name, e.birth_date, t.title, t.from_date, t.to_date
INTO Mentorship_Info
FROM employees as e
	INNER JOIN titles as t
		ON (e.emp_no = t.emp_no)
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND (t.to_date = '9999-01-01')
;

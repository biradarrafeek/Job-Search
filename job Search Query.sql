CREATE DATABASE job_search_tool;

use job_search_tool;

/* Beginner-Level */

-- Q1. Find all job titles and their locations.
SELECT title, location
FROM jobs;

-- Q2. List all job seekers located in New York.
SELECT name
FROM job_seekers
WHERE location = 'New York';

-- Q3. Retrieve the count of applications for each job.
SELECT job_id, COUNT(application_id) AS application_count
FROM applications
GROUP BY job_id;

-- Q4. List all unique job locations.
SELECT DISTINCT location
FROM jobs;

-- Q5. Find the names and education levels of job seekers with a "B.Sc. Computer Science" degree.
SELECT name, education
FROM job_seekers
WHERE education = 'B.Sc. Computer Science';


/* Intermediate-Level */

-- Q1. List job titles and the names of the companies offering them.
SELECT j.title, c.name AS company_name
FROM jobs j
JOIN companies c ON j.company_id = c.company_id;

-- Q2. Count the number of job seekers in each location.
SELECT location, COUNT(seeker_id) AS num_seekers
FROM job_seekers
GROUP BY location;

-- Q3. Find jobs with a salary range that starts from at least $80,000.
SELECT title, salary_range
FROM jobs
WHERE CAST(SUBSTRING_INDEX(salary_range, '-', 1) AS UNSIGNED) >= 80000;

-- Q4. List the top 3 job seekers who have applied to the most jobs.
SELECT seeker_id, COUNT(application_id) AS num_applications
FROM applications
GROUP BY seeker_id
ORDER BY num_applications DESC
LIMIT 3;

-- Q5. Retrieve all jobs posted in the last 30 days.
SELECT title, date_posted
FROM jobs
WHERE date_posted >= CURDATE() - INTERVAL 30 DAY;

-- Q6. Find the average salary range for each company.
SELECT c.name AS company_name, AVG(CAST(SUBSTRING_INDEX(salary_range, '-', -1) AS UNSIGNED)) AS avg_salary
FROM jobs j
JOIN companies c ON j.company_id = c.company_id
GROUP BY c.name;

-- Q7. List jobs with more than 5 applications.
SELECT job_id, COUNT(application_id) AS num_applications
FROM applications
GROUP BY job_id
HAVING num_applications > 5;

-- Q8. Find the number of applications for each company.
SELECT c.name AS company_name, COUNT(a.application_id) AS num_applications
FROM companies c
JOIN jobs j ON c.company_id = j.company_id
JOIN applications a ON j.job_id = a.job_id
GROUP BY c.name;


-- Q9. Retrieve jobs that require a degree in Data Science.
SELECT j.title
FROM jobs j
JOIN job_seekers s ON j.location = s.location
WHERE s.education = 'B.A. Data Science';

-- Q10. List each job seeker’s latest application date.
SELECT seeker_id, MAX(application_date) AS latest_application
FROM applications
GROUP BY seeker_id;

-- Q11. Find the job with the highest number of applications.
SELECT job_id, COUNT(application_id) AS num_applications
FROM applications
GROUP BY job_id
ORDER BY num_applications DESC
LIMIT 1;

-- Q12. Calculate the percentage of job applications per location.
SELECT location, (COUNT(application_id) / (SELECT COUNT(*) FROM applications) * 100) AS application_percentage
FROM jobs j
JOIN applications a ON j.job_id = a.job_id
GROUP BY location;

-- Q13. List job seekers who have applied to multiple jobs in different locations.
SELECT seeker_id
FROM applications a
JOIN jobs j ON a.job_id = j.job_id
GROUP BY seeker_id
HAVING COUNT(DISTINCT location) > 1;

-- Q14. Find job seekers with the maximum number of applications using a subquery.
SELECT seeker_id
FROM applications
GROUP BY seeker_id
HAVING COUNT(application_id) = (
    SELECT MAX(application_count)
    FROM (SELECT COUNT(application_id) AS application_count FROM applications GROUP BY seeker_id) AS seeker_counts
);


/* Advanced-Level  */

-- Q1. Find the rank of each job seeker based on the number of applications they submitted, with the highest number of applications ranked first.
SELECT seeker_id,
       COUNT(application_id) AS num_applications,
       RANK() OVER (ORDER BY COUNT(application_id) DESC) AS application_rank
FROM applications
GROUP BY seeker_id;

-- Q2. Retrieve each job’s average salary, as well as the difference between each job’s salary and the average salary across all jobs.
SELECT job_id,
       title,
       job_salary,
       avg_salary_all_jobs,
       (job_salary - avg_salary_all_jobs) AS salary_difference
FROM (
    SELECT job_id,
           title,
           AVG(CAST(SUBSTRING_INDEX(salary_range, '-', -1) AS UNSIGNED)) AS job_salary,
           AVG(AVG(CAST(SUBSTRING_INDEX(salary_range, '-', -1) AS UNSIGNED))) OVER () AS avg_salary_all_jobs
    FROM jobs
    GROUP BY job_id, title
) AS job_salary_data;


-- Q3. Calculate the cumulative number of applications for each job over time, ordered by application date.

SELECT job_id,
       application_date,
       COUNT(application_id) OVER (PARTITION BY job_id ORDER BY application_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_applications
FROM applications
ORDER BY job_id, application_date;

-- Q4. Determine the running total of applications submitted by each job seeker, ordered by application date.
SELECT seeker_id,
       application_date,
       COUNT(application_id) OVER (PARTITION BY seeker_id ORDER BY application_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_applications
FROM applications
ORDER BY seeker_id, application_date;

-- Q5. Rank each job by the number of applications received within each company, with the most-applied-to job ranked first.

SELECT j.job_id,
       j.title,
       c.name AS company_name,
       COUNT(a.application_id) AS num_applications,
       DENSE_RANK() OVER (PARTITION BY c.company_id ORDER BY COUNT(a.application_id) DESC) AS job_rank_within_company
FROM jobs j
JOIN companies c ON j.company_id = c.company_id
JOIN applications a ON j.job_id = a.job_id
GROUP BY j.job_id, j.title, c.company_id, c.name;


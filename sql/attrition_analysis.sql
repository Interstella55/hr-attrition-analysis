-- *************
-- ANALYSIS -- *
-- *************

-- ATTRITION RATE

-- Overall attrition rate
SELECT
	Attrition,
	COUNT(*) AS 'Count of Employees',
	FORMAT(
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (),
    'P2'
) AS 'Percentage of Attrition'
FROM FactEmployee
GROUP BY Attrition

-- Conclude that in a total of 1470 employees, 237 employees left the company, in a total of 16.12%

-- Attrition by Department v1
SELECT
	dd.Department,
	COUNT(*) AS 'Count of Employees',
	FORMAT(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(), 'P') AS 'Percentage of Attrition'
FROM FactEmployee AS fe
JOIN DimDepartment AS dd
	ON dd.DepartmentID = fe.DepartmentID
WHERE Attrition = 1
GROUP BY dd.Department
ORDER BY COUNT(*)

-- The majority of employees are hired to Research & Development, so the total of Attrition in this Department is high, compared to other departments

-- v2
SELECT
	dd.Department,
	COUNT(*) AS 'Count of Employees',
	SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) AS EmployeesLeft,
    FORMAT((SUM(
	CASE 
		WHEN fe.Attrition = 1 THEN 1 
		ELSE 0 END) * 100.0) / COUNT(*), 'N2') + '%' AS AttritionRate
FROM FactEmployee AS fe
JOIN DimDepartment AS dd
	ON dd.DepartmentID = fe.DepartmentID
GROUP BY dd.Department
ORDER BY (SUM(
	CASE 
		WHEN fe.Attrition = 1 THEN 1 
		ELSE 0 END) * 100.0) / COUNT(*) DESC

-- Now, comparing Attrition by each Department. Sales has the highest attrition rate. 


-- Attrition by gender

SELECT
	dg.Gender,
	COUNT(*) AS 'Total of employees'
FROM FactEmployee AS fe
JOIN DimGender AS dg
	ON dg.GenderID = fe.GenderID
WHERE Attrition = 1
GROUP BY Gender
ORDER BY COUNT(*)

-- 882 employees are males while 588 are females. 
-- From 882 male employees, 150 have Attrition while from 588 females, 87 have attrition.

SELECT
	dg.Gender,
	COUNT(*) AS 'Total of employees',
	SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) AS EmployeesLeft,
	FORMAT(SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P') 
FROM FactEmployee AS fe
JOIN DimGender AS dg
	ON dg.GenderID = fe.GenderID
GROUP BY Gender
ORDER BY COUNT(*);

-- Calculating the total of each gender, we conclude that male has an rate of 17.01% while females have 14.80%. 


-- Average salary by job role

SELECT
	djr.JobRole,
	FORMAT(AVG(fe.MonthlyIncome), 'c', 'pt-PT') AS 'Average salary'
FROM FactEmployee AS fe
JOIN DimJobRole AS djr
	ON djr.JobRoleID = fe.JobRoleID
GROUP BY djr.JobRole
ORDER BY AVG(fe.MonthlyIncome) DESC;

-- Top 2 with highest average salary: Manager - 17.181€, Research Director - 16.033€
-- Top 2 with lowest average salary: Sales Representative - 2.626€, Laboratory Technician - 3.237€

-- Employee distribution by job level
SELECT	
	CASE 
		WHEN JobLevel = 1 THEN 'Entry'
		WHEN JobLevel = 2 THEN 'Intermediate'
		WHEN JobLevel = 3 THEN 'Experienced'
		WHEN JobLevel = 4 THEN 'Advanced'
		ELSE 'Expert'
	END AS 'JobLevelRating',
	COUNT(*) AS 'Total of Employees',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeesAttrition',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P') AS 'AttritionRate'
FROM FactEmployee
GROUP BY JobLevel
ORDER BY SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC

-- We confirm that the Entry level(26.34%) has the highest rate of Attrition while Advanced level(4.72%) has the lowest rate.


-- Attrition vs years at company
SELECT
	CASE
	WHEN YearsAtCompany <= 1 THEN '0–1 year'
    WHEN YearsAtCompany <= 3 THEN '2–3 years'
    WHEN YearsAtCompany <= 5 THEN '4–5 years'
    ELSE '6+ years'
END AS 'YearsAtCompany',
	COUNT(*) AS 'Total of employees',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeesLeft'
FROM FactEmployee
GROUP BY YearsAtCompany
ORDER BY SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) DESC;

-- We confirm that most of employees leave the company during their 1st and 2nd year.

-- Attrition by overtime

SELECT
	CASE 
		WHEN OverTime = 0 THEN 'No'
		ELSE 'Yes'
	END AS 'Overtime',
	COUNT(*) AS 'Total of employees',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeesLeft',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P') AS 'AttritionPercentage'
FROM FactEmployee
GROUP BY OverTime
ORDER BY SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC;


-- The rate of employees who do overtime are higher than the ones that don't do it. The ratio is Yes:30.53% vs No:10.44%.

-- Salary vs attrition

SELECT
	djr.JobRole,
	MAX(fe.MonthlyIncome) AS 'Max',
	AVG(fe.MonthlyIncome) AS 'AVG',
	MIN(fe.MonthlyIncome) AS 'MIN',
	COUNT(*) AS 'TotalEmployee',
	SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeesLeft',
	FORMAT(SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P') AS 'AttritionRate'
FROM FactEmployee AS fe
JOIN DimJobRole AS djr
	ON djr.JobRoleID = fe.JobRoleID
GROUP BY djr.JobRole
ORDER BY SUM(CASE WHEN fe.Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC


-- Sales Representative has the higher AttritionRate. It also has the lowest MIN, MAX and AVG of the company


-- Job satisfaction vs attrition
SELECT
	CASE 
		WHEN JobSatisfaction = 1 THEN 'Very dissatisfied'
		WHEN JobSatisfaction = 2 THEN 'Dissatisfied'
		WHEN JobSatisfaction = 3 THEN 'Satisfied'
		ELSE 'Very Satisfied'
	END AS 'JobsatisfactionRating',
	COUNT(*) AS 'EmployeeNumber',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeeLeft',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P2') AS 'AttritionRate'
FROM FactEmployee
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction


-- We confirm that the most of employees with Very Dissatisfied ratings are the ones with highest Attrition rate.

-- Attrition by business travel

SELECT
	dbt.BusinessTravel,
	COUNT(*) AS 'EmployeeNumber',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeeLeft',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'P2') AS 'AttritionRate'
FROM FactEmployee AS fe
JOIN DimBusinessTravel AS dbt
	ON dbt.BusinessTravelID = fe.BusinessTravelID
GROUP BY BusinessTravel
ORDER BY SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)DESC;

-- Employees who travel frequently have a higher attrition rate. Travel_Frequently may influence the AttritionRate

-- High-risk employee profile

SELECT
	djr.Jobrole,
	CASE 
		WHEN fe.YearsAtCompany <= 2 THEN '1-2 Years'
		WHEN fe.YearsAtCompany > 2 AND fe.YearsAtCompany < 4 THEN '2-4 Years'
		WHEN fe.YearsAtCompany > 4 AND fe.YearsAtCompany < 6 THEN '4-6 Years'
		ELSE '6+ Years'
	END AS 'YearsAtCompanyRating',
	CASE 
		WHEN fe.JobSatisfaction = 1 THEN 'Very dissatisfied'
		WHEN fe.JobSatisfaction = 2 THEN 'Dissatisfied'
		WHEN fe.JobSatisfaction = 3 THEN 'Satisfied'
		ELSE 'Very Satisfied'
	END AS 'JobsatisfactionRating',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeeLeft',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'p') AS 'AttritionRate'
	FROM FactEmployee AS fe
JOIN DimJobRole AS djr
	ON djr.JobRoleID = fe.JobroleID
GROUP BY djr.Jobrole, 
	CASE 
		WHEN fe.YearsAtCompany <= 2 THEN '1-2 Years'
		WHEN fe.YearsAtCompany > 2 AND fe.YearsAtCompany < 4 THEN '2-4 Years'
		WHEN fe.YearsAtCompany > 4 AND fe.YearsAtCompany < 6 THEN '4-6 Years'
		ELSE '6+ Years'
	END,
	CASE 
		WHEN fe.JobSatisfaction = 1 THEN 'Very dissatisfied'
		WHEN fe.JobSatisfaction = 2 THEN 'Dissatisfied'
		WHEN fe.JobSatisfaction = 3 THEN 'Satisfied'
		ELSE 'Very Satisfied'
	END
HAVING SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) > 1
ORDER BY  djr.JobRole DESC;

SELECT
	djr.JobRole,
	COUNT(*)
FROM FactEmployee AS fe
JOIN DimJobRole AS djr
	ON djr.JobRoleID = fe.JobRoleID
GROUP BY djr.JobRole
order by count(*) desc

SELECT
	djr.Jobrole,
	CASE
		WHEN fe.JobSatisfaction = 1 THEN 'Very dissatisfied'
		WHEN fe.JobSatisfaction = 2 THEN 'Dissatisfied'
		WHEN fe.JobSatisfaction = 3 THEN 'Satisfied'
		ELSE 'Very Satisfied'
	END AS 'JobsatisfactionRating',
	SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) AS 'EmployeeLeft',
	FORMAT(SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 'p') AS 'AttritionRate'
	FROM FactEmployee AS fe
JOIN DimJobRole AS djr
	ON djr.JobRoleID = fe.JobroleID
GROUP BY djr.Jobrole, 
	CASE 
		WHEN fe.JobSatisfaction = 1 THEN 'Very dissatisfied'
		WHEN fe.JobSatisfaction = 2 THEN 'Dissatisfied'
		WHEN fe.JobSatisfaction = 3 THEN 'Satisfied'
		ELSE 'Very Satisfied'
	END
HAVING SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) > 1
ORDER BY  SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) DESC;

-- Following this analysis, we can see that Laboratory Technician has the highest attrition with both Satisfied and Very Dissatisfied employees. 
-- It indicates that satisfied employees leaving the company during their first ans second year could be intership while very dissatisfied are employees who couldn't adapt the role.  



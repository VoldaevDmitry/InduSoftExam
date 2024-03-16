-- Создание базы данных
CREATE DATABASE CompanyDB;

-- Использование созданной базы данных
\c CompanyDB;

--Создание схемы данных
CREATE SCHEMA CompanySchema;

-- Создание таблицы DEPARTMENT
CREATE TABLE CompanySchema.DEPARTMENT (
    ID INT PRIMARY KEY,
    NAME VARCHAR(100)
);

-- Создание таблицы EMPLOYEE
CREATE TABLE CompanySchema.EMPLOYEE (
    ID INT PRIMARY KEY,
    DEPARTMENT_ID INT REFERENCES CompanySchema.DEPARTMENT(ID),
    CHIEF_ID INT REFERENCES CompanySchema.EMPLOYEE(ID),
    NAME VARCHAR(100),
    SALARY NUMERIC
);


-- Вставка данных в таблицу DEPARTMENT
INSERT INTO CompanySchema.DEPARTMENT (ID, NAME)
VALUES
    (1, 'Отдел продаж'),
    (2, 'Отдел разработки'),
    (3, 'Отдел маркетинга'),
    (4, 'Отдел кадров'),
    (5, 'Финансовый отдел'),
    (6, 'Отдел логистики'),
    (7, 'Отдел качества'),
    (8, 'Отдел IT'),
    (9, 'Отдел закупок'),
    (10, 'Отдел производства');

-- Вставка данных в таблицу EMPLOYEE
INSERT INTO CompanySchema.EMPLOYEE (ID, DEPARTMENT_ID, CHIEF_ID, NAME, SALARY)
VALUES
    (1, 1, NULL, 'Иванов Иван', 60000),
    (2, 1, 1, 'Петров Петр', 55000),
    (3, 1, 1, 'Сидорова Анна', 52000),
    (4, 2, NULL, 'Смирнов Алексей', 70000),
    (5, 2, 4, 'Козлова Елена', 65000),
    (6, 2, 4, 'Морозов Дмитрий', 62000),
    (7, 3, NULL, 'Новикова Ольга', 58000),
    (8, 3, 7, 'Васильева Мария', 55000),
    (9, 3, 7, 'Павлова Екатерина', 53000),
	(10, 4, NULL, 'Григорьев Андрей', 62000),
    (11, 4, 10, 'Соколова Ольга', 58000),
    (12, 4, 10, 'Федоров Иван', 55000),
    (13, 5, NULL, 'Ковалева Екатерина', 70000),
    (14, 5, 13, 'Максимов Денис', 65000),
    (15, 5, 13, 'Антонова Мария', 62000),
    (16, 6, NULL, 'Петрова Анна', 58000),
    (17, 6, 16, 'Сидоров Дмитрий', 55000),
    (18, 6, 16, 'Иванова Елена', 53000),
    (19, 7, NULL, 'Козлов Денис', 62000),
    (20, 7, 19, 'Морозова Анна', 58000),
    (21, 7, 19, 'Новиков Дмитрий', 55000),
	(22, 8, NULL, 'Соколов Дмитрий', 62000),
    (23, 8, 22, 'Иванова Елена', 58000),
    (24, 8, 22, 'Петров Андрей', 55000),
    (25, 9, NULL, 'Максимова Ольга', 70000),
    (26, 9, 25, 'Антонов Денис', 65000),
    (27, 9, 25, 'Сидорова Анна', 62000),
    (28, 10, NULL, 'Новиков Дмитрий', 58000),
    (29, 10, 28, 'Козлов Денис', 55000),
    (30, 10, 28, 'Морозова Анна', 53000)
	
	
	
	
-- 1. Вывести список сотрудников, которые получают заработную плату ниже, чем у непосредственного руководителя.
SELECT E1.NAME AS EmployeeName, E1.SALARY AS EmployeeSalary, E2.NAME AS ManagerName, E2.SALARY AS ManagerSalary
FROM CompanySchema.EMPLOYEE E1
JOIN CompanySchema.EMPLOYEE E2 ON E1.CHIEF_ID = E2.ID
WHERE E1.SALARY < E2.SALARY;

-- 2. Вывести список сотрудников, которые получают в отделе минимальную заработную плату в своем отделе.
SELECT E.NAME AS EmployeeName, E.SALARY AS EmployeeSalary, D.NAME AS DepartmentName
FROM CompanySchema.EMPLOYEE E
JOIN CompanySchema.DEPARTMENT D ON E.DEPARTMENT_ID = D.ID
WHERE E.SALARY = (SELECT MIN(SALARY) FROM CompanySchema.EMPLOYEE WHERE DEPARTMENT_ID = E.DEPARTMENT_ID);

-- 3. Вывести список ID отделов, количество сотрудников в которых не превышает трех человек.
SELECT DEPARTMENT_ID
FROM CompanySchema.EMPLOYEE
GROUP BY DEPARTMENT_ID
HAVING COUNT(*) <= 3;

-- 4. Вывести список сотрудников, не имеющих назначенного руководителя, который работал бы в том же отделе.
SELECT E.NAME AS EmployeeName, D.NAME AS DepartmentName
FROM CompanySchema.EMPLOYEE E
JOIN CompanySchema.DEPARTMENT D ON E.DEPARTMENT_ID = D.ID
WHERE E.CHIEF_ID IS NULL;

-- 5. Найти список ID отделов с максимальной суммарной заработной платой сотрудников.
SELECT DEPARTMENT_ID
FROM CompanySchema.EMPLOYEE
GROUP BY DEPARTMENT_ID
ORDER BY SUM(SALARY) DESC
LIMIT 1;

--6. Составить SQL-запрос, вычисляющий сумму всех значений всех ЗП в конкретном столбце таблицы.
SELECT SUM(SALARY) AS TotalSalary
FROM CompanySchema.EMPLOYEE


-- Создание хранимой процедуры UPDATESALARYFORDEPARTMENT
CREATE OR REPLACE FUNCTION companyschema.updatesalaryfordepartment(IN department_id_param integer, IN percent_param numeric)
RETURNS TABLE (ID_R INT, DEPARTMENT_ID_R INT, CHIEF_ID_R INT, NAME_R VARCHAR, SALARY_R NUMERIC)

LANGUAGE 'plpgsql'
AS $$
DECLARE
    chief_salary NUMERIC;
    new_salary NUMERIC;
BEGIN
    -- Получение ЗП начальника отдела
    SELECT SALARY INTO chief_salary
    FROM CompanySchema.EMPLOYEE
    WHERE DEPARTMENT_ID = department_id_param AND CHIEF_ID IS NULL;

    -- Повышение ЗП сотрудников в отделе
    UPDATE CompanySchema.EMPLOYEE
    SET SALARY = SALARY * (1 + percent_param / 100)
    WHERE DEPARTMENT_ID = department_id_param AND CHIEF_ID IS NOT NULL;
	
	-- Получение новой ЗП начальника отдела
    SELECT MAX(SALARY) INTO new_salary
    FROM CompanySchema.EMPLOYEE
    WHERE DEPARTMENT_ID = department_id_param AND CHIEF_ID IS NOT NULL AND SALARY > chief_salary;

    -- Повышение ЗП начальника, если необходимо
    IF new_salary is not null THEN
        UPDATE CompanySchema.EMPLOYEE
        SET SALARY = new_salary
        WHERE ID = (SELECT CHIEF_ID FROM CompanySchema.EMPLOYEE WHERE DEPARTMENT_ID = department_id_param AND CHIEF_ID IS NOT NULL AND SALARY = new_salary); 
    END IF;


    -- Возврат перечня сотрудников с обновленной и старой ЗП
    RETURN QUERY SELECT * FROM CompanySchema.EMPLOYEE WHERE DEPARTMENT_ID = department_id_param;
END;
$$;

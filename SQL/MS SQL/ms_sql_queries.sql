-- Создание базы данных
CREATE DATABASE MyCompanyDB;

-- Использование созданной базы данных
USE MyCompanyDB;

-- Создание таблицы DEPARTMENT
CREATE TABLE DEPARTMENT (
    ID INT PRIMARY KEY,
    NAME VARCHAR(100)
);

-- Создание таблицы EMPLOYEE
CREATE TABLE EMPLOYEE (
    ID INT PRIMARY KEY,
    DEPARTMENT_ID INT,
    CHIEF_ID INT,
    NAME VARCHAR(100),
    SALARY DECIMAL(10,2),
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT(ID),
    FOREIGN KEY (CHIEF_ID) REFERENCES EMPLOYEE(ID)
);

-- Вставка данных в таблицу DEPARTMENT
INSERT INTO DEPARTMENT (ID, NAME)
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
INSERT INTO EMPLOYEE (ID, DEPARTMENT_ID, CHIEF_ID, NAME, SALARY)
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



-- Запрос для вывода списка сотрудников, чья зарплата ниже, чем у непосредственного руководителя
SELECT E1.NAME AS EmployeeName, E1.SALARY AS EmployeeSalary, E2.NAME AS ChiefName, E2.SALARY AS ChiefSalary
FROM EMPLOYEE E1
JOIN EMPLOYEE E2 ON E1.CHIEF_ID = E2.ID
WHERE E1.SALARY < E2.SALARY

-- Запрос для вывода списка сотрудников, получающих в отделе минимальную заработную плату
SELECT E.NAME AS EmployeeName, E.SALARY AS EmployeeSalary, D.NAME AS DepartmentName
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.ID
WHERE E.SALARY = (
    SELECT MIN(SALARY)
    FROM EMPLOYEE
    WHERE DEPARTMENT_ID = E.DEPARTMENT_ID
)

-- Запрос для вывода списка ID отделов, количество сотрудников в которых не превышает трех человек
SELECT DEPARTMENT_ID
FROM (
    SELECT DEPARTMENT_ID, COUNT(*) AS EmployeeCount
    FROM EMPLOYEE
    GROUP BY DEPARTMENT_ID
) AS DepartmentEmployeeCount
WHERE EmployeeCount <= 3

-- Запрос для вывода списка сотрудников, не имеющих назначенного руководителя, который работал бы в том же отделе
SELECT E.NAME AS EmployeeName, D.NAME AS DepartmentName
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT_ID = D.ID
WHERE E.CHIEF_ID IS NULL

-- Запрос для вывода списка ID отделов с максимальной суммарной заработной платой сотрудников
SELECT E.DEPARTMENT_ID, SUM(E.SALARY) AS TotalSalary
FROM EMPLOYEE E
GROUP BY E.DEPARTMENT_ID
HAVING SUM(E.SALARY) = (
    SELECT MAX(TotalSalary)
    FROM (
        SELECT DEPARTMENT_ID, SUM(SALARY) AS TotalSalary
        FROM EMPLOYEE
        GROUP BY DEPARTMENT_ID
    ) AS DepartmentTotalSalary
)

--Этот запрос вернет общую сумму всех значений в столбце SALARY таблицы EMPLOYEE. Результат будет отображен в столбце TotalSalary.
SELECT SUM(SALARY) AS TotalSalary
FROM EMPLOYEE




-- Создание хранимой процедуры UPDATESALARYFORDEPARTMENT
CREATE OR ALTER PROCEDURE UPDATESALARYFORDEPARTMENT (
    @p_department_id INT,
    @p_percent DECIMAL(5, 2)
) AS
BEGIN
	DECLARE @v_old_employee_table table(ID INT, DEPARTMENT_ID INT, CHIEF_ID INT, NAME VARCHAR(100), SALARY DECIMAL(10,2));
    DECLARE @v_chief_salary DECIMAL(10, 2);
	
	insert into @v_old_employee_table 
	SELECT * FROM [dbo].[EMPLOYEE]

    -- Получение ЗП начальника отдела
    SELECT @v_chief_salary = SALARY
    FROM EMPLOYEE
    WHERE DEPARTMENT_ID = @p_department_id AND CHIEF_ID IS NULL;

    -- Повышение ЗП сотрудников в отделе
    UPDATE EMPLOYEE
    SET SALARY = SALARY * (1 + @p_percent / 100)
    WHERE DEPARTMENT_ID = @p_department_id AND CHIEF_ID IS NOT NULL;

	
    DECLARE @v_new_salary DECIMAL(10, 2);
	
    -- Получение новой ЗП начальника отдела
    SELECT @v_new_salary = MAX(SALARY)
    FROM EMPLOYEE
    WHERE DEPARTMENT_ID = @p_department_id AND CHIEF_ID IS NOT NULL AND SALARY > @v_chief_salary;

    -- Повышение ЗП начальника, если необходимо
    IF @v_new_salary is not null
    BEGIN
        UPDATE EMPLOYEE
        SET SALARY = @v_new_salary
        WHERE ID = (
            SELECT CHIEF_ID
            FROM EMPLOYEE
            WHERE DEPARTMENT_ID = @p_department_id AND CHIEF_ID IS NOT NULL AND SALARY = @v_new_salary
        );
    END;

    -- Вывод перечня сотрудников с обновленной и старой ЗП
    SELECT E.ID, E.NAME, E.SALARY AS NewSalary, OLD.SALARY AS OldSalary
    FROM EMPLOYEE E
    LEFT JOIN @v_old_employee_table OLD ON E.ID = OLD.ID
    WHERE E.DEPARTMENT_ID = @p_department_id;
END;


-- Выполнение хранимой процедуры UPDATESALARYFORDEPARTMENT для отдела с ID = 42 и повышением на 23%
EXEC UPDATESALARYFORDEPARTMENT @p_department_id = 42, @p_percent = 23;
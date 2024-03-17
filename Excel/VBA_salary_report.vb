Sub GenerateReport()
    Dim conn As Object
    Dim rs As Object
    Dim rsOld As Object
    Dim strSQL As String
    Dim ws As Worksheet
    Dim rng As Range
    Dim i As Long

    ' Чтение данных с листа ввода данных
    departmentId = Sheets("Input").Range("B1").Value
    percentIncrease = Sheets("Input").Range("B2").Value

    ' Создание подключения
    Set conn = CreateObject("ADODB.Connection")
    conn.ConnectionString = "Provider=SQLOLEDB;Data Source=DESKTOP-8O7MJMF\SQLEXPRESS14;Initial Catalog=CompanyDB;Trusted_connection=yes;"
    conn.Open

    ' Далее по хорошему должен быть вызов процедуры, которая вернет перечень сотрудников с обновленной и старой ЗП
    ' Но при попытке обхода результаьов запроса выходит ошибка: Run-Time Error '3704' Operation is not allowed when the object is closed.
    ' С обычным SELECT таких проблем не возникло, поэтому я создал 2 recordSet, в один я записал данные из таблицы EMPLOYEE до выполнения ХП, во второй - после выполнения ХП.
    
        ' Сохранение данных до выполнения процедуры
    strSQL = "SELECT ID, NAME, SALARY FROM EMPLOYEE WHERE DEPARTMENT_ID = " & departmentId
    Set rsOld = conn.Execute(strSQL)
    
    ' Запуск хранимой процедуры
    strSQL = "EXEC UPDATESALARYFORDEPARTMENT @p_department_id = " & departmentId & ", @p_percent = " & percentIncrease
    conn.Execute strSQL
    
        ' Получение обновленных данных из БД
    strSQL = "SELECT ID, NAME, SALARY FROM EMPLOYEE WHERE DEPARTMENT_ID = " & departmentId
    Set rs = conn.Execute(strSQL)

    ' Ищем лист для вывода данных, если его нет, то создаем
        On Error Resume Next
    
        Set ws = Worksheets("Salary Report")
        
        If Err.Number <> 0 Then
            'действия, если листа нет
            Set ws = ThisWorkbook.Sheets.Add
            ws.Name = "Salary Report"
        End If
        
    On Error GoTo 0

    ' Отрисовка шапки
    ws.Cells(1, 1).Value = "ID"
    ws.Cells(1, 2).Value = "Name"
    ws.Cells(1, 3).Value = "Old Salary"
    ws.Cells(1, 4).Value = "New Salary"

   ' Запись данных
    i = 2
    Do While Not rs.EOF
        ws.Cells(i, 1).Value = rs("ID")
        ws.Cells(i, 2).Value = rs("NAME")
        ws.Cells(i, 4).Value = rs("SALARY")
        i = i + 1
        rs.MoveNext
    Loop
    ' Вывод старой ЗП
    i = 2
    Do While Not rsOld.EOF
        ws.Cells(i, 3).Value = rsOld("SALARY")
        i = i + 1
        rsOld.MoveNext
    Loop

    ' Форматирование таблицы
    Set rng = ws.Range("A1:D" & i - 1)
    rng.Borders.LineStyle = xlContinuous
    rng.Font.Bold = True

    ' Освобождение ресурсов
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
End Sub



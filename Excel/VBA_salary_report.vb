Sub GenerateReport()
    Dim conn As Object
    Dim rs As Object
    Dim strSQL As String
    Dim ws As Worksheet
    Dim rng As Range
    Dim i As Long

    ' Read input data from cells (adjust cell references as needed)
    departmentId = Sheets("Input").Range("A1").Value
    percentIncrease = Sheets("Input").Range("B1").Value

    ' Create a new connection to the database (adjust connection string as needed)
    Set conn = CreateObject("ADODB.Connection")
    conn.ConnectionString = "Provider=SQLOLEDB;Data Source=DESKTOP-8O7MJMF\SQLEXPRESS14;Initial Catalog=MyCompanyDB;Trusted_connection=yes;"
    conn.Open

    ' Execute the stored procedure to update salaries
    strSQL = "EXEC UPDATESALARYFORDEPARTMENT @p_department_id = " & departmentId & ", @p_percent = " & percentIncrease
    conn.Execute strSQL
    
        ' Retrieve data from the database
    strSQL = "SELECT ID, NAME, SALARY FROM EMPLOYEE WHERE DEPARTMENT_ID = " & departmentId
    Set rs = conn.Execute(strSQL)

    ' Create a new worksheet for the report
    Set ws = ThisWorkbook.Sheets.Add
    ws.Name = "Salary Report"

    ' Write headers
    ws.Cells(1, 1).Value = "ID"
    ws.Cells(1, 2).Value = "Name"
    ws.Cells(1, 3).Value = "Old Salary"
    ws.Cells(1, 4).Value = "New Salary"

   ' Write data
    i = 2
    Do While Not rs.EOF
        ws.Cells(i, 1).Value = rs("ID")
        ws.Cells(i, 2).Value = rs("NAME")
        ws.Cells(i, 3).Value = rs("SALARY")
        TempString = "C" & i & "*(1+" & percentIncrease / 100 & ")"
        ws.Cells(i, 4).Formula = TempString
        i = i + 1
        rs.MoveNext
    Loop

    ' Format the table
    Set rng = ws.Range("A1:D" & i - 1)
    rng.Borders.LineStyle = xlContinuous
    rng.Font.Bold = True

    ' Clean up
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
End Sub


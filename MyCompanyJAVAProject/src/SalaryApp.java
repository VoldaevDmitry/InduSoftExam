import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class SalaryApp extends JFrame {
	private JTable table;
    private JButton fetchButton;

    public SalaryApp() {
        setTitle("Salary App");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Создаем компоненты
        table = new JTable();
        fetchButton = new JButton("Fetch Data");

        // добавляем на форму
        setLayout(new BorderLayout());
        add(new JScrollPane(table), BorderLayout.CENTER);
        add(fetchButton, BorderLayout.SOUTH);

        // добавляем обработчик событий на кнопку
        fetchButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {

                String dbUrl = "jdbc:sqlserver://DESKTOP-8O7MJMF\\SQLEXPRESS14;"
                		+ "databasename=MyCompanyDB;integratedSecurity=true;"
                		+ "encrypt=true;trustServerCertificate=true";
                
                
                String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
                String dbUser = "";
                String dbPassword = "";

                try {
                    // Establish a connection to the database
                	Class.forName(driver);//.newInstance();
                	
                    Connection connection = DriverManager.getConnection(dbUrl);

                    // Prepare the call to the stored procedure
                    String callProcedure = "{call UPDATESALARYFORDEPARTMENT(?, ?)}";
                    CallableStatement callableStatement = connection.prepareCall(callProcedure);

                    // Set the input parameters
                    int departmentId = 123; // Replace with the actual department ID
                    double percentIncrease = 10.0; // Replace with the desired percentage increase

                    callableStatement.setInt(1, departmentId);
                    callableStatement.setDouble(2, percentIncrease);

                    // Execute the stored procedure
                    callableStatement.execute();

                    // Retrieve the result set (if needed)
                    ResultSet resultSet = callableStatement.getResultSet();
                    while (resultSet.next()) {
                        int employeeId = resultSet.getInt("ID");
                        String employeeName = resultSet.getString("NAME");
                        double newSalary = resultSet.getDouble("NewSalary");
                        double oldSalary = resultSet.getDouble("OldSalary");

                        System.out.println("Employee ID: " + employeeId);
                        System.out.println("Employee Name: " + employeeName);
                        System.out.println("New Salary: " + newSalary);
                        System.out.println("Old Salary: " + oldSalary);
                        System.out.println("--------------------------");
                    }

                    // Close resources
                    resultSet.close();
                    callableStatement.close();
                    connection.close();
                } catch (SQLException | ClassNotFoundException ex) {
                    ex.printStackTrace();
                }
            }
        });

        setVisible(true);
    }

    public static void main(String[] args) {
        new SalaryApp();
    }
}

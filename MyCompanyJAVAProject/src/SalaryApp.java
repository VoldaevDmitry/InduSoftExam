import javax.swing.*;
import javax.swing.table.DefaultTableModel;

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
    private JTextField departmentIdField;
    private JTextField percentIncreaseField;

    public SalaryApp() {
        setTitle("Salary App");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Создаем компоненты
        table = new JTable();
        fetchButton = new JButton("Fetch Data");
        departmentIdField = new JTextField();
        percentIncreaseField = new JTextField();

        // добавляем на форму
        setLayout(new BorderLayout());
        add(new JScrollPane(table), BorderLayout.CENTER);

        JPanel inputPanel = new JPanel();
        inputPanel.setLayout(new GridLayout(3, 2));
        inputPanel.add(new JLabel("Department ID:"));
        inputPanel.add(departmentIdField);
        inputPanel.add(new JLabel("Percent Increase:"));
        inputPanel.add(percentIncreaseField);
        inputPanel.add(fetchButton);

        add(inputPanel, BorderLayout.SOUTH);

        // добавляем обработчик событий на кнопку
        fetchButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {

                String dbUrl = "jdbc:sqlserver://DESKTOP-8O7MJMF\\SQLEXPRESS14;databasename=CompanyDB;encrypt=true;trustServerCertificate=true";               
                String dbUser = "testUser";
                String dbPassword = "1234";
               
                
                try (Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPassword); Statement stmt = con.createStatement();) {

                    // Считываем параметры
                	int departmentId = Integer.parseInt(departmentIdField.getText());
                    double percentIncrease = Double.parseDouble(percentIncreaseField.getText());

                    String SQL = "EXECUTE [dbo].[UPDATESALARYFORDEPARTMENT]"+String.valueOf(departmentId)+", "+String.valueOf(percentIncrease);
                    
                    // Запускаем процедуру и сохраняем данные в resultSet
                    ResultSet resultSet = stmt.executeQuery(SQL);
                                      
                 // Выводим данные в таблицу на форме
                    DefaultTableModel model = new DefaultTableModel(new String[]{"Employee ID", "Employee Name", "New Salary", "Old Salary"}, 0);
                    while (resultSet.next()) {
                        int employeeId = resultSet.getInt("ID");
                        String employeeName = resultSet.getString("NAME");
                        double newSalary = resultSet.getDouble("NewSalary");
                        double oldSalary = resultSet.getDouble("OldSalary");

                        model.addRow(new Object[]{employeeId, employeeName, newSalary, oldSalary});
                    }
                    table.setModel(model);
                    
                    // Освобождаем ресурсы
                    resultSet.close();
                    
                } catch (SQLException ex) {
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

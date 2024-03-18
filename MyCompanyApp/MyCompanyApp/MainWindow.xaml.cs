using System;
using System.Windows;
using System.Data;
using System.Data.SqlClient;

namespace MyCompanyApp
{
    public partial class MainWindow : Window
    {
        private readonly string connectionString = "Data Source=DESKTOP-8O7MJMF\\SQLEXPRESS14;Initial Catalog=CompanyDB;Integrated Security=True";

        public MainWindow()
        {
            InitializeComponent();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // Load initial data or perform any other setup
        }

        private void btnExecuteQuery_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                int departmentId = int.Parse(txtDepartmentId.Text);
                double percentIncrease = double.Parse(txtPercentIncrease.Text);

                // Execute the stored procedure to update salaries
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand("UPDATESALARYFORDEPARTMENT", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@p_department_id", departmentId);
                        command.Parameters.AddWithValue("@p_percent", percentIncrease);
                        command.ExecuteNonQuery();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            DataTable dataTable = new DataTable();
                            dataTable.Load(reader);
                            dgvResults.ItemsSource = dataTable.DefaultView;
                        }

                    }                    
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}

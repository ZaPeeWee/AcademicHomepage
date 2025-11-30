package com.mycompany.academichomepage;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL  = "jdbc:mysql://localhost:3306/academic_homepage";
    private static final String USER = "root";              // <-- your MySQL username
    private static final String PASS = "YOUR_PASSWORD_HERE"; // <-- your MySQL password

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}

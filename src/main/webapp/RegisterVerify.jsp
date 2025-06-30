<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ page import="java.sql.*, java.io.*, java.util.*, javax.mail.*, javax.mail.internet.*"%>

<%@ page import="org.mindrot.jbcrypt.BCrypt" %>  
<!DOCTYPE html>  
<html lang="en">  
<head>  
    <meta charset="UTF-8">  
    <title>MSX Cricket Arena</title>
</head>  
<body>  
<%  
    // Retrieve the OTP entered by the user  
    String otp = request.getParameter("otp");  
    String expectedOtp = (String) session.getAttribute("generatedOtp");  
    String email = (String) session.getAttribute("emailid");  
    String password = (String) session.getAttribute("password");  
    String name = (String) session.getAttribute("name");  
    String phone = (String) session.getAttribute("phone");  
	String role = "user";
    Connection con = null;  
    String errorMessage = "";  
    
    try {  
        // Verify the OTP  
        if (otp != null && otp.equals(expectedOtp)) {  
            // Using a context variable for database connection information  
            Class.forName("com.mysql.cj.jdbc.Driver");  
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");  
            
            // Making use of try-with-resources to automatically manage resources  
            try (PreparedStatement ps = con.prepareStatement("INSERT INTO user_details (email, password, name, phone) VALUES (?, ?, ?, ?)")) {  
                ps.setString(1, email);  
                String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());  
                ps.setString(2, hashedPassword);  
                ps.setString(3, name);  
                ps.setString(4, phone); 
                int i = ps.executeUpdate();  
                
                if (i > 0) {  
                    // Successful account creation  
                    response.sendRedirect("Login_Form.html?toast=registersuccess");  
                } else {  
                    // Account creation failed  
                    errorMessage = "Error occurred during account creation.";  
                    response.sendRedirect("Register.html?toast=error");  
                }  
            }  
            // Clear the OTP after successful verification  
            session.removeAttribute("generatedOtp");  
        } else {  
            // OTP verification failed  
            errorMessage = "Invalid OTP. Please try again.";  
            response.sendRedirect("RegisterVerify.html?toast=otperror");  
        }  
    } catch (SQLException e) {  
        errorMessage = "Database error: " + e.getMessage();  
        e.printStackTrace();  
        response.sendRedirect("Register.html?toast=error");  
    } catch (ClassNotFoundException e) {  
        errorMessage = "JDBC Driver not found: " + e.getMessage();  
        e.printStackTrace();  
        response.sendRedirect("Register.html?toast=error");  
    } catch (Exception e) {  
        errorMessage = "An unexpected error occurred: " + e.getMessage();  
        e.printStackTrace();  
        response.sendRedirect("Register.html?toast=error");  
    } finally {  
        // Close the database connection  
        if (con != null) {  
            try {  
                con.close();  
            } catch (SQLException e) {  
                e.printStackTrace();  
            }  
        }  
    }  
%>  
</body>  
</html>  
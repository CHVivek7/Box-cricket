<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>  
<%
    response.setContentType("text/html");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    String email = (String) session.getAttribute("transferemail");
    Connection con = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "");


        if (newPassword.equals(confirmPassword)) {
        	String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());  
            String query = "UPDATE user_details SET password = ? WHERE email = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, hashedPassword); // Use hashed password if required
            ps.setString(2, email);

            int i = ps.executeUpdate();
            if (i > 0) {
                response.sendRedirect("Login_Form.html?toast=updatesuccess");
            } else {
                response.sendRedirect("updatePassword.html?toast=errorpass");
            }
        } else {
            response.sendRedirect("updatePassword.html?toast=updateerror");
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (con != null) {
            try {
                con.close();
            } catch (SQLException ex) {
                out.println("Error closing connection: " + ex.getMessage());
            }
        }
    }
%>

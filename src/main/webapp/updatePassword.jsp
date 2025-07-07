<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<%
    response.setContentType("text/html");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    String email = (String) session.getAttribute("transferemail");
    Connection con = null;

    try {
        Dotenv dotenv = Dotenv.configure().load();

        String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
        String user = dotenv.get("DB_USER");
        String pass = dotenv.get("DB_PASSWORD");


        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);

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

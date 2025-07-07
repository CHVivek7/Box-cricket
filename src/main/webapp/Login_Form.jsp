<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ page import="java.sql.*" %>  
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<%  
    response.setContentType("text/html");  
    String email = request.getParameter("email");  
    String password = request.getParameter("password"); 
    String userType = request.getParameter("userType"); 
    Connection con = null;  
    PreparedStatement ps = null;  
    ResultSet rs = null;  
	session.setAttribute("loginemail", email);

    try {
        Dotenv dotenv = Dotenv.configure().load();

    	String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
        String user = dotenv.get("DB_USER");
        String pass = dotenv.get("DB_PASSWORD");

            
            	Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(url, user, pass);


        String sql = "SELECT * FROM user_details WHERE email = ? AND role = ?";  
        ps = con.prepareStatement(sql);  
        ps.setString(1, email);   
        ps.setString(2, userType);
        rs = ps.executeQuery(); 
            // Check if a matching record is found  
        if (rs.next()) {  
            String hashedPassword = rs.getString("password");
            if (BCrypt.checkpw(password, hashedPassword)) { // Verify password  
            	if(userType.equals("user")){
                	response.sendRedirect("Home.html?toast=loginsuccess");
            	}else{
                	response.sendRedirect("AdminHome.html?toast=loginsuccess");
            	}
            } else {  
                response.sendRedirect("Login_Form.html?toast=loginerror");  
            }
        } else {  
                // Invalid credentials provided  
            response.sendRedirect("Login_Form.html?toast=loginerror");
        } 
       
    } catch (Exception e) {  
        out.println("<h3>Error: " + e.getMessage() + "</h3>");  
    } 
%>
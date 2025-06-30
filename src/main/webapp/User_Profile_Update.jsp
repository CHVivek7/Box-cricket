<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>  

<%
    String email = (String) session.getAttribute("loginemail");
    String name = request.getParameter("name").trim();
    String phone = request.getParameter("phone").trim();
    String pass = request.getParameter("pass");
    String cpass = request.getParameter("cpass");
    
    if (phone.length()!=10) {
        response.sendRedirect("UserDashboard.html?toast=updateerror");
        return;
    }

    if(pass.equals(cpass)){
    	Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");

            String updateQuery;
                updateQuery = "UPDATE user_details SET name=?, phone=?, password=? WHERE email=?";
            

            pstmt = conn.prepareStatement(updateQuery);
            pstmt.setString(1, name);
            pstmt.setString(2, phone);
        	String hashedPassword = BCrypt.hashpw(pass, BCrypt.gensalt());  

            if (pass != null && !pass.isEmpty()) {
                pstmt.setString(3, hashedPassword);
                pstmt.setString(4, email);
            } else {
                pstmt.setString(3, email);
            }

            int updatedRows = pstmt.executeUpdate();

            if (updatedRows > 0) {
                response.sendRedirect("UserDashboard.html?toast=updatesuccess");
                
            } else {
                response.sendRedirect("UserDashboard.html?toast=updateerror");
            }
        } catch (Exception e) {
            response.sendRedirect("UserDashboard.html?toast=updateerror");
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }else{
    	response.sendRedirect("UserDashboard.html?toast=errorpass");
    }

    
%>
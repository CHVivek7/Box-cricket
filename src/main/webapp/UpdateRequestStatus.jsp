<%@ page import="java.sql.*" %>

<%
    String requestId = request.getParameter("requestId");
    String action = request.getParameter("action");

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");

        String updateQuery = "UPDATE join_teams SET request_status = ? WHERE booking_id = ?";
        
        ps = con.prepareStatement(updateQuery);
        ps.setString(1, action);
        ps.setString(2, requestId);
        ps.executeUpdate();

        response.sendRedirect("UserDashboard.html?autoClick=true");

    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>

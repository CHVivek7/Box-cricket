<%@ page import="java.sql.*" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>

<%
    String requestId = request.getParameter("requestId");
    String action = request.getParameter("action");

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Dotenv dotenv = Dotenv.configure().load();

        String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
        String user = dotenv.get("DB_USER");
        String pass = dotenv.get("DB_PASSWORD");


        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);
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

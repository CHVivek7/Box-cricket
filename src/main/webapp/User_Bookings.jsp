<%@ page import="java.sql.*,  java.text.SimpleDateFormat" %>
<%
    String userEmail = (String)session.getAttribute("loginemail") ;
    if (userEmail == null) {
        out.println("<p style='color:red;'>User not logged in.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
    	Class.forName("com.mysql.cj.jdbc.Driver");
    	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");
        
        String query = "SELECT booking_id, booking_date, start_time, end_time, price, reserve_date, email FROM booking_details WHERE email = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();
        SimpleDateFormat dbDateFormat = new SimpleDateFormat("yyyy-MM-dd"); // MySQL default date format
        SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd-MM-yyyy"); // Desired format
        
%>	
        <table>
            <tr>
            	<th>Booking Id</th>
                <th>Date of Booking </th>
                <th>Start Time</th>
                <th>End Time</th>
                <th>Slot Date</th>
            </tr>
<%
        while (rs.next()) {
        	String bookingid = rs.getString("booking_id");
            String bookingDate = rs.getString("booking_date");
            Time startTime = rs.getTime("start_time");
            Time endTime = rs.getTime("end_time");
            String reservedate = rs.getString("reserve_date");
            int price = rs.getInt("price");
            String booking_email = rs.getString("email");
            // Convert end time by subtracting 30 minutes
            long endTimeMillis = endTime.getTime() - (30 * 60 * 1000);
            Time adjustedEndTime = new Time(endTimeMillis);
            
            // Format times in 12-hour format
            String formattedStartTime = new java.text.SimpleDateFormat("hh:mm a").format(startTime);
            String formattedEndTime = new java.text.SimpleDateFormat("hh:mm a").format(adjustedEndTime);
            String formattedBookingDate = (bookingDate != null) ? displayDateFormat.format(dbDateFormat.parse(bookingDate)) : "N/A";
            String formattedReserveDate = (reservedate != null) ? displayDateFormat.format(dbDateFormat.parse(reservedate)) : "N/A";
            
            
%>
            <tr>
            	<td><%= bookingid %></td>
                <td><%= formattedBookingDate %></td>
                <td><%= formattedStartTime %></td>
                <td><%= formattedEndTime %></td>
                <td><%= formattedReserveDate %></td>
            </tr>
<%
        }
%>
        </table>
<%
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error fetching booking history.</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
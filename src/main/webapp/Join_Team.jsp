<%-- Join_Team.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>

<%@ page import="java.sql.*, java.util.Properties, javax.mail.*, javax.mail.internet.*" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Calendar, java.util.TimeZone, java.util.Date" %>
<%
    String date = request.getParameter("date");
    String userEmail = (String) session.getAttribute("loginemail");

    Connection con = null;
    PreparedStatement ps = null, checkPs = null, statusPs = null;
    ResultSet rs = null, checkRs = null, statusRs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");


        String query = "SELECT booking_id, start_time, end_time, reserve_date, email " +
                "FROM booking_details " +
                "WHERE email != ? " + // Parameter 1
                "AND reserve_date = ? " + // Parameter 2
                "AND ( " +
                "      ? > CURDATE() " + // Parameter 3
                "      OR " +
                "      (? = CURDATE() AND start_time > CURTIME()) " + // Parameter 4
                "    )";
		ps = con.prepareStatement(query);
        ps.setString(2, date);
        ps.setString(1,userEmail);
        ps.setString(3, date);
        ps.setString(4, date);
        rs = ps.executeQuery();

        SimpleDateFormat dbDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd-MM-yyyy");

        out.println("<table border='1'>");
        out.println("<tr><th>Booking ID</th><th>Start Time</th><th>End Time</th><th>Action</th><th>Request Status</th><th>Price</th></tr>");

        while (rs.next()) {
            String bookingId = rs.getString("booking_id");
            Time startTime = rs.getTime("start_time");
            Time endTime = rs.getTime("end_time");
            String reserveDate = rs.getString("reserve_date");
            String bookingEmail = rs.getString("email");
            String requestStatus = "Not Requested";

            long endTimeMillis = endTime.getTime() - (30 * 60 * 1000);
            Time adjustedEndTime = new Time(endTimeMillis);

            String formattedStartTime = new SimpleDateFormat("hh:mm a").format(startTime);
            String formattedEndTime = new SimpleDateFormat("hh:mm a").format(adjustedEndTime);
            String formattedReserveDate = displayDateFormat.format(dbDateFormat.parse(reserveDate));

            String checkQuery = "SELECT * FROM join_teams WHERE booking_id = ? AND requester_email = ?";
            checkPs = con.prepareStatement(checkQuery);
            checkPs.setString(1, bookingId);
            checkPs.setString(2, userEmail);
            checkRs = checkPs.executeQuery();

            boolean requestExists = checkRs.next(); // Store the result

            if(requestExists) {
                String statusQuery = "SELECT request_status FROM join_teams WHERE booking_id = ? AND requester_email = ?";
                statusPs = con.prepareStatement(statusQuery);
                statusPs.setString(1, bookingId);
                statusPs.setString(2, userEmail);
                statusRs = statusPs.executeQuery();

                if(statusRs.next()){
                    requestStatus = statusRs.getString("request_status");
                }
            }

            out.println("<tr>");
            out.println("<td>" + bookingId + "</td>");
            out.println("<td>" + formattedStartTime + "</td>");
            out.println("<td>" + formattedEndTime + "</td>");
            out.println("<td>");

            if (requestExists) { // Use the stored result
%>
                <button disabled style="background-color: gray; color: white; cursor:not-allowed">Sent</button>
<%
            } else {
%>
                <button class="join-btn"
                        data-booking-id="<%= bookingId %>"
                        data-start-time="<%= startTime %>"
                        data-end-time="<%= endTime %>"
                        data-reserve-date="<%= date %>"
                        data-owner-email="<%= bookingEmail %>">
                    Join
                </button>
<%
            }
            out.println("</td>");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); // Assuming database date format
            SimpleDateFormat timeFormat12 = new SimpleDateFormat("hh:mm a");
            SimpleDateFormat timeFormat24 = new SimpleDateFormat("HH:mm:ss"); // Assuming time comes in 24-hour format
			
            String emailTimeZone = "Asia/Kolkata"; // Replace with the desired time zone
            timeFormat12.setTimeZone(TimeZone.getTimeZone(emailTimeZone));
            timeFormat24.setTimeZone(TimeZone.getTimeZone(emailTimeZone));
            java.util.Date reserveDateDate = dateFormat.parse(reserveDate);

            String startTimeStr = startTime.toString();  // "HH:mm:ss"
            String endTimeStr = endTime.toString();      // "HH:mm:ss"

            // Now parse it using SimpleDateFormat
            java.util.Date startTimeDate = timeFormat24.parse(startTimeStr);
            java.util.Date endTimeDate = timeFormat24.parse(endTimeStr);

            // Subtract 30 minutes from endTime
            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone(emailTimeZone));
            calendar.setTime(endTimeDate);
            calendar.add(Calendar.MINUTE, -30);
            java.util.Date adjustedEndTimeDate = calendar.getTime();

            formattedStartTime = timeFormat12.format(startTimeDate);
            formattedEndTime = timeFormat12.format(adjustedEndTimeDate);
            
            Date startDate = timeFormat24.parse(startTime + ":00");  
            Date endDate = timeFormat24.parse(endTime + ":00");  
            long durationInMinutes = (endDate.getTime() - startDate.getTime()) / (1000 * 60); 
            durationInMinutes -= 30;
            double price = (durationInMinutes / 60.0) * 250;  
            int roundedPrice = (int) Math.round(price); 
            
            out.println("<td>" + requestStatus + "</td>");
            out.println("<td>" + roundedPrice + "/-</td>");
            out.println("</tr>");
        }
        out.println("</table>");

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (statusRs != null) statusRs.close();
        if (statusPs != null) statusPs.close();
        if (checkRs != null) checkRs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>
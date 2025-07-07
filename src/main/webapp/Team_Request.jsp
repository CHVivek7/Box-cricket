<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>

<html>
<head>
    <title>MSX Cricket Arena</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #121212;
            color: white;
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
            text-align: center;
        }
        .container {
            width: 90%;
            background: #1e1e1e;
            padding: 20px;
            box-shadow: 0px 0px 10px #444;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            border: 1px solid #444;
            padding: 10px;
            text-align: center;
        }
        th {
            color: white;
        }
        .accept-btn {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }
        .accept-btn:hover {
            background-color: #218838;
        }
        .reject-btn {
            margin-left: 10px;
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s ease;
        }
        .reject-btn:hover {
            background-color: #c82333;
        }
        .disabled-btn {
            height: 40px;
            border-radius: 5px;
            width: 100px;
            color: white;
            background-color: gray;
            cursor: not-allowed;
        }
        .form-bt {
            display: flex;
            justify-content: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Team Join Requests</h2>

        <%
            String userEmail = (String) session.getAttribute("loginemail");

            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                Dotenv dotenv = Dotenv.configure().load();

                String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
                String user = dotenv.get("DB_USER");
                String pass = dotenv.get("DB_PASSWORD");


                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(url, user, pass);
                String query = "SELECT jt.booking_id, jt.requester_email, jt.request_status, "+
                	       "bd.start_time, bd.end_time, bd.reserve_date "+
                	       "FROM join_teams jt "+
                	       "JOIN booking_details bd ON jt.booking_id = bd.booking_id "+
                	       "WHERE bd.email = ?"+
                	         " AND ( bd.reserve_date > CURDATE() OR (bd.reserve_date = CURDATE() AND bd.start_time > CURTIME()))";

				
                ps = con.prepareStatement(query);
                ps.setString(1, userEmail);
                rs = ps.executeQuery();

                out.println("<table>");
                out.println("<tr><th>Booking ID</th><th>Requester</th><th>Start Time</th><th>End Time</th><th>Date</th><th>Status</th><th>Action</th></tr>");

                while (rs.next()) {
                    String bookingId = rs.getString("booking_id");
                    String requesterEmail = rs.getString("requester_email");
                    session.setAttribute("requesteremail", requesterEmail);
                    Time startTime = rs.getTime("start_time");
                    Time endTime = rs.getTime("end_time");
                    String reserveDate = rs.getString("reserve_date");
                    String requestStatus = rs.getString("request_status");

                    long endTimeMillis = endTime.getTime() - (30 * 60 * 1000);
                    Time adjustedEndTime = new Time(endTimeMillis);

                    SimpleDateFormat dbDateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd-MM-yyyy");
                    String formattedStartTime = new SimpleDateFormat("hh:mm a").format(startTime);
                    String formattedEndTime = new SimpleDateFormat("hh:mm a").format(adjustedEndTime);
                    String formattedReserveDate = displayDateFormat.format(dbDateFormat.parse(reserveDate));

                    out.println("<tr>");
                    out.println("<td>" + bookingId + "</td>");
                    out.println("<td>" + requesterEmail + "</td>");
                    out.println("<td>" + formattedStartTime + "</td>");
                    out.println("<td>" + formattedEndTime + "</td>");
                    out.println("<td>" + formattedReserveDate + "</td>");
                    out.println("<td>" + requestStatus + "</td>");
                    out.println("<td>");

                    session.setAttribute("formatstarttime", formattedStartTime);
                    session.setAttribute("formatendtime", formattedEndTime);
                    session.setAttribute("formatreservedate", formattedReserveDate);

                    if ("Pending".equalsIgnoreCase(requestStatus)) {
        %>
                        <form method="post" action="UpdateRequestStatus.jsp" class="form-bt">
                            <input type="hidden" name="requestId" value="<%= bookingId %>">
                            <button type="submit" name="action" value="Accepted" class="accept-btn">Accept</button>
                            <button type="submit" name="action" value="Rejected" class="reject-btn">Reject</button>
                        </form>
        <%
                    } else {
                        out.println("<button class='disabled-btn' disabled>" + requestStatus + "</button>");
                    }

                    out.println("</td>");
                    out.println("</tr>");
                }
                out.println("</table>");

            } catch (Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            }
        %>
    </div>
</body>
</html>

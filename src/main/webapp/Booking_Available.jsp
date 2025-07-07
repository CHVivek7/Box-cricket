<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date, java.util.Random, java.util.Calendar" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<%
    String date = request.getParameter("date");
    Connection conn = null;
    PreparedStatement psCheck = null;
    ResultSet rsCheck = null;
%>

<h2 style="text-align:center;">Slots Reserved on <%= date %></h2>
<div id="bookingInfo">
    <table>
        <tr>
            <th>Start Time</th>
            <th>End Time</th>
        </tr>
        <%
            try {
                Dotenv dotenv = Dotenv.configure().load();

                String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
                String user = dotenv.get("DB_USER");
                String pass = dotenv.get("DB_PASSWORD");


                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, pass);String sql = "SELECT start_time, end_time FROM booking_details WHERE reserve_date = ?";
                psCheck = conn.prepareStatement(sql);
                psCheck.setString(1, date);
                rsCheck = psCheck.executeQuery();

                while (rsCheck.next()) {
                    String bookedStartTime = rsCheck.getString("start_time");
                    String bookedEndTime = rsCheck.getString("end_time");
                    
                    SimpleDateFormat sdf24 = new SimpleDateFormat("HH:mm");
                    SimpleDateFormat sdf12 = new SimpleDateFormat("hh:mm a");

                    Date date1 = sdf24.parse(bookedStartTime);
                    String stime12 = sdf12.format(date1);

                    Date date2 = sdf24.parse(bookedEndTime);
                    String etime12 = sdf12.format(date2);
        %>
                    <tr>
                        <td><%= stime12 %></td>
                        <td><%= etime12 %></td>
                    </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error retrieving bookings: " + e.getMessage() + "</p>");
            } finally {
                if (rsCheck != null) rsCheck.close();
                if (psCheck != null) psCheck.close();
                if (conn != null) conn.close();
            }
        %>
    </table>
</div>

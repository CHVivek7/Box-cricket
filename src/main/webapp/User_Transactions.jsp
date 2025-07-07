<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<%
    String userEmail = (String)session.getAttribute("loginemail");
    if (userEmail == null) {
        out.println("<p style='color:red;'>User not logged in.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Dotenv dotenv = Dotenv.configure().load();

        String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
        String user = dotenv.get("DB_USER");
        String pass = dotenv.get("DB_PASSWORD");


        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, pass);
        String query = "SELECT booking_id, booking_date, start_time, end_time, price, reserve_date FROM booking_details WHERE email = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, userEmail);
        rs = pstmt.executeQuery();
        
        // Define date formatter
        SimpleDateFormat dbDateFormat = new SimpleDateFormat("yyyy-MM-dd"); // MySQL default date format
        SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd-MM-yyyy"); // Desired format
%>
        <table border="1">
            <tr>
                <th>Booking Id</th>
                <th>Date of booking</th>
                <th>Slot Date</th>
                <th>Price</th>
            </tr>
<%
        while (rs.next()) {
            String bookingid = rs.getString("booking_id");
            String bookingDate = rs.getString("booking_date");
            String reservedate = rs.getString("reserve_date");
            int price = rs.getInt("price");

            // Convert and format dates
            String formattedBookingDate = (bookingDate != null) ? displayDateFormat.format(dbDateFormat.parse(bookingDate)) : "N/A";
            String formattedReserveDate = (reservedate != null) ? displayDateFormat.format(dbDateFormat.parse(reservedate)) : "N/A";
%>
            <tr>
                <td><%= bookingid %></td>
                <td><%= formattedBookingDate %></td>
                <td><%= formattedReserveDate %></td>
                <td><%= price %></td>
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

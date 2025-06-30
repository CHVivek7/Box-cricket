<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date, java.util.Random, java.util.Calendar" %>  
<%  
    String email = (String) session.getAttribute("loginemail"); 
    String date = request.getParameter("date");  
    String startTime = request.getParameter("start_time");  
    String endTime = request.getParameter("end_time");  

    Connection conn = null;  
    PreparedStatement psCheck = null, psInsert = null, psUser = null;  
    ResultSet rsCheck = null, rsUser = null;  
    boolean isAvailable = true;  

    try {  
        Class.forName("com.mysql.cj.jdbc.Driver");  
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  
        Date selectedDate = sdf.parse(date);  
        Date today = new Date();  
        if (selectedDate.before(sdf.parse(sdf.format(today)))) {  
            out.println("<h3 style='color:red;'>Error: You cannot book slots for past dates!</h3>");  
            return;  
        }  

        // Define time formats  
        SimpleDateFormat timeFormat24 = new SimpleDateFormat("HH:mm:ss");  
        SimpleDateFormat timeFormat12 = new SimpleDateFormat("hh:mm a");  

        Date startDate = timeFormat24.parse(startTime + ":00");  
        Date endDate = timeFormat24.parse(endTime + ":00");  
		
        Date now = new Date();
        String currentDate = sdf.format(now);
        if (date.equals(currentDate)) { // If booking for today
            String currentTime24 = timeFormat24.format(now);
            Date currentTime = timeFormat24.parse(currentTime24);
            if (startDate.before(currentTime)) {  
            	response.sendRedirect("Booking.html?error=Invalid Time entered");  
                out.println("<h3 style='color:red;'>Error: You cannot book slots for past times!</h3>");  
                return;  
            }
        }
        Calendar cal = Calendar.getInstance();  
        cal.setTime(endDate);  
        cal.add(Calendar.MINUTE, 30);  
        Date modifiedEndDate = cal.getTime();  

        String startTime24 = timeFormat24.format(startDate);  
        String endTime24 = timeFormat24.format(endDate);  
        String modifiedEndTime24 = timeFormat24.format(modifiedEndDate);  

        String startTime12 = timeFormat12.format(startDate);  
        String endTime12 = timeFormat12.format(endDate);  
        String modifiedEndTime12 = timeFormat12.format(modifiedEndDate);  

        String checkQuery = "SELECT * FROM booking_details WHERE reserve_date = ? AND ("  
                + "(start_time < ? AND end_time > ?) OR " // If existing booking starts before and ends after requested start  
                + "(start_time >= ? AND start_time < ?) OR " // If requested start time is within an existing booking  
                + "(end_time > ? AND end_time <= ?))"; // If requested end time is within an existing booking  

        psCheck = conn.prepareStatement(checkQuery);  
        psCheck.setString(1, date);  
        psCheck.setString(2, endTime24); // Requested end time  
        psCheck.setString(3, startTime24); // Requested start time  
        psCheck.setString(4, startTime24); // Requested start time  
        psCheck.setString(5, endTime24); // Requested end time  
        psCheck.setString(6, startTime24); // Requested start time  
        psCheck.setString(7, endTime24); // Requested end time  

        rsCheck = psCheck.executeQuery();  
        if (rsCheck.next()) {  
            isAvailable = false; // Slot is already booked  
        }  
        if (isAvailable) {  
            String userQuery = "SELECT name, phone FROM user_details WHERE email = ?";  
            psUser = conn.prepareStatement(userQuery);  
            psUser.setString(1, email);  
            rsUser = psUser.executeQuery();  

            String name = "", phone = "";  
            if (rsUser.next()) {  
                name = rsUser.getString("name");  
                phone = rsUser.getString("phone");  
            } else {  
                out.println("<h3>User not found. Please register first.</h3>");  
                return;  
            }  

            String bookingId = "";  
            boolean unique = false;  
            Random rand = new Random();  
            while (!unique) {  
                bookingId = String.format("%07d", rand.nextInt(10000000));  
                PreparedStatement psCheckId = conn.prepareStatement("SELECT * FROM booking_details WHERE booking_id = ?");  
                psCheckId.setString(1, bookingId);  
                ResultSet rsCheckId = psCheckId.executeQuery();  
                if (!rsCheckId.next()) { unique = true; }  
                rsCheckId.close();  
                psCheckId.close();  
            }  

            long durationInMinutes = (endDate.getTime() - startDate.getTime()) / (1000 * 60);  
            double price = (durationInMinutes / 60.0) * 700;  
            int roundedPrice = (int) Math.round(price);  

            String insertQuery = "INSERT INTO booking_details (booking_id, email, name, phone, booking_date, start_time, end_time, price,reserve_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?)";  
            psInsert = conn.prepareStatement(insertQuery);  
            psInsert.setString(1, bookingId);  
            psInsert.setString(2, email);  
            psInsert.setString(3, name);  
            psInsert.setString(4, phone);  
            SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String formattedToday = sdfDateTime.format(today);
            psInsert.setString(5, formattedToday);
            psInsert.setString(6, startTime24);  
            psInsert.setString(7, modifiedEndTime24);  
            psInsert.setInt(8, roundedPrice); 
            psInsert.setString(9, date);  
            psInsert.executeUpdate();  

            // Style for print button and receipt table
            out.println("<style>");
            out.println("body { display: flex; flex-direction: column; align-items: center; background: #f4f4f4; font-family: Arial, sans-serif; }");
            out.println("#receipt { background: white; padding: 30px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); border-radius: 5px; width: 60%; }");
            out.println("table { width: 100%; border-collapse: collapse; font-size: 20px; top:30%;}");
            out.println("th, td { padding: 15px; border: 2px solid #ddd; text-align: left; }");
            out.println("th { background: #007bff; color: white; }");
            out.println("button { margin-top: 20px; padding: 15px 30px; font-size: 18px; cursor: pointer; background: #007bff; color: white; border: none; border-radius: 5px; }");
            out.println("button:hover { background: #0056b3; }");
            out.println("h2 { text-align: center; font-size: 28px; margin-bottom: 10px; }");
            out.println(".logo { position: absolute; top: 30px; right: 40px; width: 80px; height: 80px; border-radius: 50%; }"); // Circular logo
            out.println("@media print {");
            out.println("  @page { margin: 0; }"); // Removes browser header/footer
            out.println("  body { margin: 0; padding: 0; }");
            out.println("  button { display: none; }"); // Hide print button
            out.println("}");
            out.println("</style>");

            // Receipt Content
            out.println("<br><br><h2>MSX Cricket Arena</h2>");
            out.println("<img src='Home.png' class='logo'>");
            out.println("<br><br><div id='receipt'>");
            out.println("<br><table>");
            out.println("<tr><th colspan='2' style='text-align:center; font-size: 24px;'>Booking Receipt</th></tr>");
            out.println("<tr><td>Booking ID:</td><td>" + bookingId + "</td></tr>");
            out.println("<tr><td>Name:</td><td>" + name + "</td></tr>");
            out.println("<tr><td>Email:</td><td>" + email + "</td></tr>");
            out.println("<tr><td>Phone:</td><td>" + phone + "</td></tr>");
            out.println("<tr><td>Date:</td><td>" + date + "</td></tr>");
            out.println("<tr><td>Start Time:</td><td>" + startTime12 + "</td></tr>");
            out.println("<tr><td>End Time:</td><td>" + endTime12 + "</td></tr>");
            out.println("<tr><td>Price:</td><td>" + roundedPrice + "</td></tr>");
            out.println("</table>");
            out.println("</div>");

            // Print Button
            out.println("<button onclick='window.print()'>Print Receipt</button>");

        } else {  
        	response.sendRedirect("Booking.html?toast=slotreserved");  
        }  
    } catch (Exception e) {  
        out.println("<h3>Error: " + e.getMessage() + "</h3>");  
    } finally {  
        if (conn != null) conn.close();  
    }  
%>

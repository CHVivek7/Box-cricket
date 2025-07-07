<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.Properties, javax.mail.*, javax.mail.internet.*" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Calendar, java.util.TimeZone, java.util.Date" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>


<%
    String bookingId = request.getParameter("booking_id");
    String startTime = request.getParameter("start_time");
    String endTime = request.getParameter("end_time");
    String reserveDate = request.getParameter("reserve_date");
    String ownerEmail = request.getParameter("email");
	
    String userEmail = (String) session.getAttribute("loginemail"); // Logged-in user email

    Connection con = null;
    PreparedStatement ps = null;

    try {
        if (userEmail == null) {
            out.println("You must be logged in to send a join request.");
            return;
        }

        Dotenv dotenv = Dotenv.configure().load();

        String url = dotenv.get("DB_URL"); // e.g., jdbc:mysql://localhost:3306/users
        String user = dotenv.get("DB_USER");
        String pass = dotenv.get("DB_PASSWORD");


        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, user, pass);

        // Insert request into join_teams table
        String insertQuery = "INSERT INTO join_teams (booking_id, requester_email, accepter_email, start_time, end_time, reserve_date, request_status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')";
        ps = con.prepareStatement(insertQuery);
        ps.setString(1, bookingId);
        ps.setString(2, userEmail);
        ps.setString(3, ownerEmail);
        ps.setString(4, startTime);
        ps.setString(5, endTime);
        ps.setString(6, reserveDate);

        
        int rowsInserted = ps.executeUpdate();

        if (rowsInserted > 0) {
            // Send email notification to ownerEmail
            final String senderEmail = "msxcricketarena@gmail.com";  // Change this to your email
            final String senderPassword = "mrdisilaxalrqtum"; // Change this to your email password

            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session mailSession = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(senderEmail, senderPassword);
                }
            });

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(ownerEmail));
            message.setSubject("New Join Team Request – Booking ID: " + bookingId);


            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); // Assuming database date format
            SimpleDateFormat displayDateFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat timeFormat12 = new SimpleDateFormat("hh:mm a");
            SimpleDateFormat timeFormat24 = new SimpleDateFormat("HH:mm:ss"); // Assuming time comes in 24-hour format
			
            String emailTimeZone = "Asia/Kolkata"; // Replace with the desired time zone
            timeFormat12.setTimeZone(TimeZone.getTimeZone(emailTimeZone));
            timeFormat24.setTimeZone(TimeZone.getTimeZone(emailTimeZone));
            java.util.Date reserveDateDate = dateFormat.parse(reserveDate);
            String formattedReserveDate = displayDateFormat.format(reserveDateDate);

            java.util.Date startTimeDate = timeFormat24.parse(startTime);
            java.util.Date endTimeDate = timeFormat24.parse(endTime);

            // Subtract 30 minutes from endTime
            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone(emailTimeZone));
            calendar.setTime(endTimeDate);
            calendar.add(Calendar.MINUTE, -30);
            java.util.Date adjustedEndTimeDate = calendar.getTime();

            String formattedStartTime = timeFormat12.format(startTimeDate);
            String formattedEndTime = timeFormat12.format(adjustedEndTimeDate);
            
            Date startDate = timeFormat24.parse(startTime + ":00");  
            Date endDate = timeFormat24.parse(endTime + ":00");  
            long durationInMinutes = (endDate.getTime() - startDate.getTime()) / (1000 * 60); 
            durationInMinutes -= 30;
            double price = (durationInMinutes / 60.0) * 250;  
            int roundedPrice = (int) Math.round(price); 
            
            String emailBody = "<html>" +
                "<body style='font-family: Times New Roman;'>" +
                "<h3 style='font-size: 24px;'>Dear Sir / Madam,</h3>" +
                "<p style='font-size: 18px;'>You have received a new <strong>Join Team Request</strong> on your account.</p>" +
                "<p style='font-size: 18px;'>Booking ID: <strong>" + bookingId + "</strong></p>" +
                "<p style='font-size: 18px;'>Date: <strong>" + formattedReserveDate + "</strong></p>" +
                "<p style='font-size: 18px;'>Time: <strong>" + formattedStartTime  + " - " + formattedEndTime + "</strong></p>" +
                "<p style='font-size: 18px;'>To accept or reject the request, please visit your <strong>User Dashboard</strong>.</p>" +
                "<p style='font-size: 18px;'>In your dashboard, click on <strong>Join Requests</strong>, then choose to <strong>Accept</strong> or <strong>Reject</strong> the request.</p>" +
                "<p style='font-size: 18px; color: green;'><strong>Note:</strong> If you <strong>accept</strong> the request, "+roundedPrice+"/- will be credited to your <strong>MSX Wallet.</strong>.</p>" +
                "<p style='font-size: 18px;'>If you have any questions, feel free to contact us.</p>" +
                "<h4 style='font-size: 18px;'>Best wishes,</h4>" +
                "<p style='font-size: 18px;'>MSXCricketArena Team</p>" +
                "</body></html>";

            message.setContent(emailBody, "text/html");

            Transport.send(message);

            out.println("Success"); // Only print success, JS will handle the button change.
        } else {
            out.println("Failure");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>

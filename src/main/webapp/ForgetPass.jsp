<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Random" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import="java.sql.*" %> <!-- Import for SQL -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MSX Cricket Arena</title>
</head>
<body>

<%
    // Retrieve email from request
    String email = request.getParameter("email");
    // Database connection variables
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    if (email != null && !email.isEmpty()) {
        // Database check: Verify if email exists
        try {
            
            
            // Load database driver (for MySQL, adjust accordingly)
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "Boxcric", "Boxcric@123");

            stmt = conn.createStatement();

            // SQL query to check if email exists
            String sql = "SELECT * FROM user_details WHERE email = '" + email + "'";
            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                // Email found, proceed with OTP generation and sending
                String fromName = "MSXCricketArena";
                String otp = generateOTP(4); 
                String subject = "One Time Password (OTP) Confirmation for MSXCricketArena";
                String body = "<html>" +
                    "<body style='Times New Roman ;'>" +
                        "<h3 font-size: 24px;'>Dear Sir / Madam,</h3>" +
                        "<p font-size: 18px;>You got a new message from <strong>" + fromName + "</strong>:</p>" +
                        "<p font-size: 16px;>Please use the following One Time Password (OTP) <span style='font-size: 21px; color: black;'>" + otp + "</span> to complete the verification.</p>" +
                        "<p>Do not share this OTP with anyone.</p>" +
                        "<h4 font-size: 18px;>Best wishes,</p><br/><p font-size: 18px;>MSXCricketArena team.</h4>" +
                    "</body>" +
                "</html>";

                try {
                    // Send email
                    session.setAttribute("generatedOtp", otp);
                    session.setAttribute("transferemail", email);
                    sendEmail(email, subject, body);
                    response.sendRedirect("Verify.html?toast=verifysuccess"); // Redirect to verification page
                } catch (Exception e) {
                    out.println("<p>Error sending email: " + e.getMessage() + "</p>");

                    // Log stack trace for debugging
                    StringWriter sw = new StringWriter();
                    PrintWriter pw = new PrintWriter(sw);
                    e.printStackTrace(pw);
                    out.println("<pre>" + sw.toString() + "</pre>");
                }
            } else {
                // Email not found, redirect to OTP form with an error message
                response.sendRedirect("ForgetPass.html?toast=emailerror");
            }
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");

            // Log stack trace for debugging
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            out.println("<pre>" + sw.toString() + "</pre>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                out.println("<p>Error closing database resources: " + ex.getMessage() + "</p>");
            }
        }
    } else {
        out.println("<p>Please provide a valid email address.</p>");
    }
%>

<%!
    // Class-level variables for email credentials
    private static final String FROM_EMAIL = "msxcricketarena@gmail.com"; 
    private static final String EMAIL_PASSWORD = "mrdisilaxalrqtum";

    // Method to generate OTP
    public String generateOTP(int length) {
        String numbers = "0123456789";
        Random random = new Random();
        StringBuilder otp = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            otp.append(numbers.charAt(random.nextInt(numbers.length())));
        }
        return otp.toString();
    }

    // Method to send email
    public void sendEmail(String to, String subject, String body) throws MessagingException {
        String host = "smtp.gmail.com"; // SMTP host

        Properties properties = new Properties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2"); // Explicitly set the TLS protocol

        // Create a session with an authenticator
        Session session = Session.getInstance(properties, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, EMAIL_PASSWORD);
            }
        });

        // Create the message
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject(subject);
        message.setContent(body, "text/html");

        // Send the email
        Transport.send(message);
    }
%>

</body>
</html>

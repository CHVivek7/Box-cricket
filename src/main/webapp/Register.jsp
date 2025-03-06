<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>5
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.io.*" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import="java.sql.*" %> <!-- Import for SQL -->

<%
	response.setContentType("text/html");
	String email = request.getParameter("email");
	String password = request.getParameter("password");
	String cpassword = request.getParameter("cpassword");
	String name = request.getParameter("name");
	String phone = request.getParameter("phone");
	Connection con = null;
	String errorMessage = "";
	
	// Validate phone number length
	if (phone!= null && phone.length()!= 10) {
		errorMessage="phone not contain 10digits";
		response.sendRedirect("Register.html?toast=errorphone");
		
	}
	
	if(errorMessage.isEmpty()){
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "");
			
			PreparedStatement ps1 = con.prepareStatement("SELECT * FROM user_details WHERE email =?");
			ps1.setString(1, email);
			ResultSet rs = ps1.executeQuery(); 
			if (rs.next()) {
				errorMessage="Acoount already exist";
				response.sendRedirect("Register.html?toast=accountexist");
			} 
			else {
				if (password.equals(cpassword)) {
					session.setAttribute("emailid", email);
					session.setAttribute("password", password);
					session.setAttribute("cpassword", cpassword);
					session.setAttribute("name", name);
					session.setAttribute("phone", phone);
					
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
		                    response.sendRedirect("RegisterVerify.html?toast=verifysuccess"); // Redirect to verification page
		                } catch (Exception e) {
		                    out.println("<p>Error sending email: " + e.getMessage() + "</p>");

		                    // Log stack trace for debugging
		                    StringWriter sw = new StringWriter();
		                    PrintWriter pw = new PrintWriter(sw);
		                    e.printStackTrace(pw);
		                    out.println("<pre>" + sw.toString() + "</pre>");
		                }
		                
					
					
				} 
				if(!password.equals(cpassword)) {
					errorMessage="pass and cpass not equal";
					response.sendRedirect("Register.html?toast=errorpass");
					
				}
			}
		} 
		catch (Exception e) {
			errorMessage = "Error: " + e.getMessage();
		} 
		finally {
			try {
				if (con!= null) con.close();
			}
			catch (SQLException e) {
				errorMessage = "Error closing connection: " + e.getMessage();
			}
		}
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

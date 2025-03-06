<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OTP Verification</title>
</head>
<body>
    <%
        // Retrieve the OTP entered by the user
        String otp = request.getParameter("otp");

        // Retrieve the OTP stored in the session
        String expectedOtp = (String) session.getAttribute("generatedOtp");
        String email = (String) session.getAttribute("transferemail");
        // Verify the OTP
        
        if (otp != null && otp.equals(expectedOtp)) {
            response.sendRedirect("updatePassword.html?toast=otpsuccess");
             // Clear the OTP after successful verification
        } else {
            response.sendRedirect("Verify.html?toast=otperror");
        }
    %>
</body>
</html>

<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    response.setContentType("text/html");
    HttpSession sessionObj = request.getSession(false);
    String email = (String) sessionObj.getAttribute("loginemail");

    if (email != null) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "");
            String query = "SELECT name, phone FROM user_details WHERE email = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                String name = rs.getString("name");
                
                String phone = rs.getString("phone");

                // Output in the format: name|email|phone
                out.print(name + "|" + email + "|" + phone);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }
%>

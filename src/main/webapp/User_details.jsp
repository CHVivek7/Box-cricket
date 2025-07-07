<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<%
    response.setContentType("text/html");
    HttpSession sessionObj = request.getSession(false);
    String email = (String) sessionObj.getAttribute("loginemail");

    if (email != null) {
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
            String query = "SELECT name, phone FROM user_details WHERE email = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                String name = rs.getString("name");
                
                String phone = rs.getString("phone");

                // Output in the format: name|email|phone
                out.print("Name    : "+ name + "|Email ID : " + email + "|Phone no : +91 " + phone);
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

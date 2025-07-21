# Box Cricket

Box Cricket is a comprehensive Java web application designed to streamline the organization and management of box cricket tournaments. Running on Apache Tomcat, this platform empowers users to oversee teams, players, matches, payments, and more, providing a seamless experience for both administrators and participants.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Create and Manage Teams and Players:** Effortlessly add, edit, and organize teams and players within the tournament.
- **Schedule Matches and Record Scores:** Plan fixtures, automate scheduling, and enter live match results for real-time tracking.
- **Payment Integration:** Securely collect participation or registration fees using integrated Razorpay payment gateway.
- **Admin Modules:** Robust admin panels for managing users, overseeing tournament progress, and customizing event settings.
- **Share Tournament Box:** Instantly share tournament details, team stats, or match results with participants or on social media.
- **Comprehensive Statistics:** Generate player leaderboards, team rankings, and insightful match analytics.
- **User Authentication and Roles:** Secure login for players, admins, and organizers with role-based access control.
- **Responsive Design:** Intuitive, mobile-friendly user interface for easy access on any device.
- **Notifications and Updates:** Automated alerts for upcoming matches, score updates, and important announcements.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CHVivek7/Box-cricket.git
   cd Box-cricket
   ```

2. **Configure Database:**
   - Install MySQL and create a new database (e.g., `box_cricket`).
   - Import the provided SQL schema from `/db/schema.sql` or similar location.

3. **Set Up Environment Variables:**
   - Edit `src/main/resources/db.properties` (or your config file) with your MySQL credentials.
   - Add Razorpay API keys and other sensitive configurations as environment variables or in a `.env` file.

4. **Build the Project:**
   ```bash
   # If using Maven
   mvn clean package
   ```

5. **Deploy to Tomcat:**
   - Copy the generated `.war` file from `target/` to your Apache Tomcat `webapps/` directory.
   - Start/restart the Tomcat server.

6. **Access the Application:**
   - Open your browser and visit [http://localhost:8080/Box-cricket](http://localhost:8080/Box-cricket) (adjust path as needed).

## Usage

- Register as an admin or player.
- Set up teams and players from the admin dashboard.
- Schedule matches and manage fixtures through the calendar interface.
- Record match scores and view live updates.
- Handle payments securely via Razorpay integration.
- Share tournament progress and results easily with participants.

## Project Structure

```
Box-cricket/
│
├── src/                   # Java source code (Servlets, Controllers, Models)
├── WebContent/            # JSP files, HTML, CSS, JS, static assets
├── db/                    # Database schema and sample data
├── lib/                   # External libraries (JARs)
├── .env.example           # Example environment variables (if used)
├── pom.xml                # Maven project file
├── README.md              # Project documentation
└── ...
```

## Technologies Used

- **Java** (JSP, Servlets)
- **HTML**, **CSS**, **JavaScript**
- **MySQL** (Database)
- **Razorpay** (Payment Integration)
- **Apache Tomcat Server**
- **Bootstrap** (for responsive UI, if used)
- **JDBC** (for database connectivity)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

Created and maintained by [CHVivek7](https://github.com/CHVivek7).

For questions or suggestions, please open an issue or contact via GitHub.

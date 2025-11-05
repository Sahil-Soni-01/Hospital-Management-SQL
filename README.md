🏥 Hospital Management System (MySQL Project)
📘 Overview

The Hospital Management System is a database project developed using MySQL to manage hospital operations efficiently.
It automates patient registration, doctor management, appointments, treatments, and billing using a relational database design with proper foreign key relationships.

⚙️ Technologies Used:-
Database: MySQL 8.0+
Language: SQL
Tools: MySQL Workbench / CLI
Data Import: CSV files
Engine: InnoDB

🧩 Database Structure
The database HospitalDB contains five main tables:

Table	Description
Patients	Stores patient information
Doctors	Contains doctor details and specialization
Appointments	Links patients with doctors
Treatments	Stores treatment details and costs
Billing	Handles payments and billing info

Relationships:
One patient → many appointments
One doctor → many appointments
One appointment → many treatments
One treatment → one billing record

🧠 Key SQL Operations

Create and Import: Tables created via CREATE TABLE and data loaded with LOAD DATA INFILE.

Reports and Analysis:
Total number of doctors per specialization
Upcoming appointments
Total hospital revenue
Patients with unpaid bills
Doctor with highest appointments
Average treatment cost

💡 Example Query
SELECT specialization, COUNT(*) AS total_doctors
FROM Doctors
GROUP BY specialization;

👨‍💻 Developer:-

Sahil Soni
Master of Computer Applications (MCA)

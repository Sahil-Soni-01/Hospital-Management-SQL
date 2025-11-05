DROP DATABASE IF EXISTS HospitalDB;
CREATE DATABASE HospitalDB
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE HospitalDB;

-- STEP 2: CREATE TABLES (match CSV column names & types)

CREATE TABLE Patients (
  patient_id VARCHAR(20) PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  gender VARCHAR(10),
  date_of_birth DATE,
  contact_number VARCHAR(20),
  address VARCHAR(255),
  registration_date DATE,
  insurance_provider VARCHAR(100),
  insurance_number VARCHAR(100),
  email VARCHAR(150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Doctors (
  doctor_id VARCHAR(20) PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  specialization VARCHAR(100),
  phone_number VARCHAR(20),
  years_experience INT,
  hospital_branch VARCHAR(100),
  email VARCHAR(150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Appointments (
  appointment_id VARCHAR(20) PRIMARY KEY,
  patient_id VARCHAR(20),
  doctor_id VARCHAR(20),
  appointment_date DATE,
  appointment_time TIME,
  reason_for_visit VARCHAR(255),
  status VARCHAR(50),
  CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
  CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Treatments (
  treatment_id VARCHAR(20) PRIMARY KEY,
  appointment_id VARCHAR(20),
  treatment_type VARCHAR(100),
  description TEXT,
  cost DECIMAL(12,2),
  treatment_date DATE,
  CONSTRAINT fk_treatments_appointment FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Billing (
  bill_id VARCHAR(20) PRIMARY KEY,
  patient_id VARCHAR(20),
  treatment_id VARCHAR(20),
  bill_date DATE,
  amount DECIMAL(12,2),
  payment_method VARCHAR(50),
  payment_status VARCHAR(50),
  CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
  CONSTRAINT fk_billing_treatment FOREIGN KEY (treatment_id) REFERENCES Treatments(treatment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Import Patients
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patients.csv'
INTO TABLE Patients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(patient_id, first_name, last_name, gender, date_of_birth, contact_number, address, registration_date, insurance_provider, insurance_number, email);

-- Import Doctors
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/doctors.csv'
INTO TABLE Doctors
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(doctor_id, first_name, last_name, specialization, phone_number, years_experience, hospital_branch, email);

-- Import Appointments
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/appointments.csv'
INTO TABLE Appointments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status);

-- Import Treatments
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/treatments.csv'
INTO TABLE Treatments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(treatment_id, appointment_id, treatment_type, description, cost, treatment_date);

-- Import Billing
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/billing.csv'
INTO TABLE Billing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status);

SELECT 'Patients' AS table_name, COUNT(*) AS `rows` FROM Patients
UNION ALL
SELECT 'Doctors' AS table_name, COUNT(*) AS `rows` FROM Doctors
UNION ALL
SELECT 'Appointments' AS table_name, COUNT(*) AS `rows` FROM Appointments
UNION ALL
SELECT 'Treatments' AS table_name, COUNT(*) AS `rows` FROM Treatments
UNION ALL
SELECT 'Billing' AS table_name, COUNT(*) AS `rows` FROM Billing;

-- Show a few patients
SELECT patient_id, CONCAT(first_name,' ',last_name) AS full_name, contact_number, email FROM Patients LIMIT 10;

-- Show a few appointments
SELECT appointment_id, patient_id, doctor_id, appointment_date, appointment_time, status FROM Appointments LIMIT 10;

-- STEP 5: ADJUSTED / CORRECTED QUERIES (use correct CSV column names)

-- 1. Show total number of doctors in each specialization
SELECT specialization, COUNT(*) AS total_doctors 
FROM Doctors 
GROUP BY specialization;

-- 2. Show all upcoming appointments (today or later)
--    Uses appointment_date and appointment_time columns
SELECT 
  a.appointment_id,
  CONCAT(p.first_name, ' ', p.last_name) AS Patient,
  CONCAT(d.first_name, ' ', d.last_name) AS Doctor,
  a.appointment_date,
  a.appointment_time AS time_slot,
  a.status
FROM Appointments a 
JOIN Patients p ON a.patient_id = p.patient_id 
JOIN Doctors d ON a.doctor_id = d.doctor_id 
WHERE a.appointment_date >= CURDATE() 
ORDER BY a.appointment_date, a.appointment_time;

-- 3. Calculate total revenue earned from paid bills
--    Billing.amount is the column name in CSV
SELECT SUM(amount) AS Total_Revenue 
FROM Billing 
WHERE LOWER(payment_status) = 'paid';

-- 4. Show names of patients who were treated by Dr. Meena Rao
--    This attempts to match common variations (with or without 'Dr.' prefix)
SELECT DISTINCT CONCAT(p.first_name,' ',p.last_name) AS Patient_Name
FROM Patients p 
JOIN Appointments a ON p.patient_id = a.patient_id 
JOIN Doctors d ON a.doctor_id = d.doctor_id 
WHERE 
  -- strip 'Dr. ' if present and match full name
  REPLACE(CONCAT_WS(' ', d.first_name, d.last_name), 'Dr. ', '') LIKE '%Meena Rao%'
  OR (d.first_name LIKE '%Meena%' AND d.last_name LIKE '%Rao%');

-- 5. Show list of patients with unpaid bills and their bill dates
SELECT CONCAT(p.first_name,' ',p.last_name) AS Patient_Name, b.amount AS total_amount, b.bill_date
FROM Billing b 
JOIN Patients p ON b.patient_id = p.patient_id 
WHERE LOWER(b.payment_status) IN ('unpaid', 'pending', 'due');

-- 6. Show total number of visits made by each patient (frequency of appointments)
SELECT CONCAT(p.first_name,' ',p.last_name) AS Patient_Name, COUNT(a.appointment_id) AS total_visits 
FROM Appointments a 
JOIN Patients p ON a.patient_id = p.patient_id 
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY total_visits DESC;

-- 7. Show each doctor’s average treatment cost
--    join Treatments -> Appointments -> Doctors using appointment_id
SELECT CONCAT(d.first_name,' ',d.last_name) AS Doctor, 
       ROUND(AVG(t.cost),2) AS Avg_Treatment_Cost
FROM Treatments t 
JOIN Appointments a ON t.appointment_id = a.appointment_id 
JOIN Doctors d ON a.doctor_id = d.doctor_id 
GROUP BY d.doctor_id, d.first_name, d.last_name;

-- 8. Find patients who have spent more than ₹2000 in total (paid bills)
SELECT CONCAT(p.first_name,' ',p.last_name) AS Patient_Name, 
       SUM(b.amount) AS Total_Spent
FROM Billing b
JOIN Patients p ON b.patient_id = p.patient_id
WHERE LOWER(b.payment_status) = 'paid'
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING SUM(b.amount) > 2000;

-- 9. Show doctor with the highest number of appointments
SELECT CONCAT(d.first_name,' ',d.last_name) AS Doctor_Name, COUNT(a.appointment_id) AS Total_Appointments
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY Total_Appointments DESC
LIMIT 1;

-- 10. Show treatment types with their average cost
SELECT treatment_type AS diagnosis, ROUND(AVG(cost),2) AS Average_Cost
FROM Treatments
GROUP BY treatment_type
ORDER BY Average_Cost DESC;

-- OPTIONAL: Helpful views to simplify repeated queries

CREATE OR REPLACE VIEW vw_patient_full AS
SELECT patient_id, CONCAT(first_name,' ',last_name) AS full_name, contact_number, email FROM Patients;

CREATE OR REPLACE VIEW vw_doctor_full AS
SELECT doctor_id, CONCAT(first_name,' ',last_name) AS full_name, specialization, phone_number, hospital_branch FROM Doctors;
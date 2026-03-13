# Check-in & Learning Mood App

---

## Problem Statement

- Universities need a reliable way to confirm that students are physically present in class and actively participating in the learning session. Traditional attendance methods such as manual sign-in cannot guarantee that students are actually in the classroom.

- This project proposes a mobile application that allows students to check in before class and submit a learning reflection after class. The system verifies attendance using GPS location and QR code scanning, while also collecting student feedback about the learning experience.

---

## Target Users

- Primary Users
    - University students who attend the class.

- Secondary Users
    - Instructors who want to verify student attendance and understand student learning feedback.

---


## Feature List

1. Class Check-in
- Students check in before class by:
    - Pressing the Check-in button
    - Scanning the classroom QR code
    - Automatically recording GPS location and timestamp
    - Filling a short form about:
        - Previous class topic
        - Expected topic for today
        - Mood before class

2. Class Completion
- After the class session, students must:
    - Press Finish Class
    - Scan the QR code again
    - Record GPS location
    - Submit a short reflection about:
        - What they learned today
        - Feedback about the class or instructor

3. Attendance Data Storage
- The system stores check-in and class completion data for each student session in the database.

---


## User Flow

- Before Class
    - Student opens the mobile application
    - Student presses Check-in
    - System records GPS location and timestamp
    - Student scans the class QR code
    - Student fills in the form:
        - Previous class topic
        - Expected topic today
        - Mood before class
    - Data is saved to the database

- After Class
    - Student presses Finish Class
    - Student scans the QR code again
    - System records GPS location
    - Student fills reflection form:
        - What they learned today
        - Feedback about the class
    - Data is saved

---


## Data Fields

- Check-in Data
    - student_id
    - class_id
    - timestamp
    - gps_location
    - previous_class_topic
    - expected_topic_today
    - mood_score

- Finish Class Data
    - student_id
    - class_id
    - timestamp
    - gps_location
    - learned_today
    - feedback

- mood_score (1-5)
    - 1 = Very negative
    - 2 = Negative
    - 3 = Neutral
    - 4 = Positive
    - 5 = Very positive
---

## Tech Stack

- Frontend
    - Flutter (Mobile Application)

- Backend / Database
    - Firebase (Firestore or Realtime Database)

- Device Features
    - GPS Location service
    - QR Code Scanner

- Deployment
    - Firebase Hosting (for demo or web version)

---
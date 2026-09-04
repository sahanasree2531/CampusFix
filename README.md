CampusFix

## Smart Campus Issue Reporting & Maintenance Management System

CampusFix is a mobile-based campus issue reporting and maintenance management system designed to make it easier for students to report problems around campus and for administrators and maintenance staff to manage and resolve them efficiently.

Instead of depending on manual complaints or verbal communication, CampusFix provides a simple digital platform where an issue can be reported, assigned to the appropriate maintenance staff, tracked, and eventually marked as resolved.



## 🎯 Project Objective

The main goal of CampusFix is to create a centralized system for handling common campus issues such as:

*  Classroom lights or electrical problems
*  Water and plumbing issues
*  Damaged furniture
*  Classroom or infrastructure problems
*  Cleanliness and maintenance issues
*  Other campus-related complaints

The system helps ensure that reported issues are not lost and that their progress can be tracked from **Report → Assignment → Work in Progress → Resolution**.



## 👥 User Roles

CampusFix has three main types of users:

### 👨‍🎓 Student

Students can:

* Create an account and log in
* Report a campus issue
* Enter the issue title and description
* Select a category
* Provide the location
* Set the priority
* View the status of reported issues

### 👨‍💼 Admin

Administrators can:

* Log in securely
* View reported issues
* Monitor issue details
* Assign issues to maintenance staff
* Track the progress of complaints
* Manage the overall issue workflow

### 👷 Maintenance Staff

Maintenance staff can:

* View issues assigned to them
* Work on assigned issues
* Update the issue status
* Mark completed issues as resolved



## 🔄 Issue Workflow

Each reported issue follows a simple workflow:


Student Reports Issue
        ↓
     Reported
        ↓
      Assigned
        ↓
   In Progress
        ↓
     Resolved


This makes it easier for both administrators and students to understand the current status of an issue.



## 🛠️ Technology Stack

CampusFix was developed using the following technologies:

### Frontend

* Flutter
* Dart

### Backend

* Python
* FastAPI
* REST API
* SQLAlchemy

### Database

* PostgreSQL

### API Testing

* Swagger / OpenAPI
* Postman

### Development & Version Control

* Git
* GitHub
* Visual Studio Code

### Containerization

* Docker
* Docker Compose



## 🏗️ Project Architecture

CampusFix follows a basic client-server architecture:


┌──────────────────────┐
│      Flutter App     │
│   Student / Admin    │
└──────────┬───────────┘
           │
           │ REST API
           ↓
┌──────────────────────┐
│      FastAPI         │
│       Backend        │
└──────────┬───────────┘
           │
           │ SQLAlchemy
           ↓
┌──────────────────────┐
│     PostgreSQL       │
│       Database       │
└──────────────────────┘


The Flutter application communicates with the FastAPI backend through REST APIs, while PostgreSQL is used for persistent data storage.



## 🔐 Authentication

CampusFix uses authentication to control access to the system.

The backend provides:

* User registration
* User login
* JWT-based authentication
* Authenticated API requests
* Role-based access for different users

This ensures that students, administrators, and maintenance staff have access to the functionality relevant to their roles.



## 📱 Main Features

### Student Issue Reporting

A student can report an issue by providing information such as:

* Issue title
* Category
* Description
* Location
* Priority

The submitted issue is stored in the backend database.

### Admin Dashboard

The admin dashboard provides an overview of reported issues and allows the administrator to manage them.

The administrator can assign an issue to a maintenance staff member and monitor its progress.

### Issue Status Tracking

Issues can move through different stages:

| Status      | Meaning                                      |
| ----------- | -------------------------------------------- |
| Reported    | Issue has been submitted by a student        |
| Assigned    | Issue has been assigned to maintenance staff |
| In Progress | Maintenance work has started                 |
| Resolved    | Issue has been completed                     |



## 📂 Project Structure

A simplified structure of the project is:


CampusFix/
│
├── backend/
│   ├── main.py
│   ├── models/
│   ├── routes/
│   ├── database/
│   ├── services/
│   └── requirements.txt
│
├── frontend/
│   └── Flutter Application
│       ├── lib/
│       │   ├── screens/
│       │   ├── services/
│       │   └── main.dart
│       └── pubspec.yaml
│
├── docker-compose.yml
├── README.md
└── .gitignore


## 🚀 How to Run the Project

### 1. Clone the Repository


git clone <your-github-repository-url>
cd CampusFix


### 2. Start PostgreSQL

If using Docker:


docker compose up -d


### 3. Start the FastAPI Backend

Navigate to the backend folder:


cd backend


Activate the virtual environment and install dependencies:


pip install -r requirements.txt


Start the FastAPI server:


uvicorn main:app --reload


The API will be available at:

http://127.0.0.1:8000


Swagger API documentation can be accessed through:


http://127.0.0.1:8000/docs


### 4. Run the Flutter Application

Navigate to the Flutter project and run:


flutter pub get
flutter run

For an Android emulator, the application communicates with the local FastAPI server through the appropriate emulator localhost address.



## 🧪 API Testing

The backend APIs can be tested using:

* Swagger UI
* Postman

Some of the important API operations include:


POST   /auth/register
POST   /auth/login
GET    /auth/me

POST   /issues/
GET    /admin/issues/


The APIs handle authentication, issue creation, issue retrieval, and administrative issue management.



## 💡 Why CampusFix?

In a typical campus environment, maintenance complaints can be reported through different channels, making them difficult to track.

CampusFix brings these complaints into one centralized platform.

It helps:

* Students report problems easily
* Administrators monitor complaints
* Maintenance staff receive assigned work
* Everyone gets better visibility into issue progress
* Campus maintenance become more organized and accountable



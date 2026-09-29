![DAVS Logo](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/davs_logo.jpg)
# 1. Project Title

A Flutter-based mobile application for secure and reliable attendance verification. The DAVS frontend provides separate interfaces for Admin, Teachers and Students and communicates with the Laravel backend through REST APIs.

## 2. Problem Statement
Traditional attendance systems may allow proxy attendance, inaccurate attendance records and attendance marking without verifying classroom or campus presence.
The DAVS frontend addresses these problems by providing interfaces for location verification, active attendance sessions, teacher verification, student confirmation, and attendance reporting.
## 3. Application Workflow

    Application Start

       |
       v
    Login Screen

       |
       v
    Authentication

       |
       v
    Check User Role

       |
    +---+---+

    |       |       |

    Admin  Teacher  Student
 
 
    |       |       |
    v       v       v

    Dashboard  Dashboard  Dashboard

           |
           v

    Create Attendance Session
           |
           v
    Location Verification
           |
           v
    Active Session
           |
           v
    Student Marks Attendance
           |
           v
    Teacher Verification
           |
           v
    Attendance Record
           |
           v
    Reports   

## Project Structure


    minahilfrontendattendance/
    │
    ├── android/                         
    │
    ├── ios/                             
    │
    ├── linux/                           
    │
    ├── macos/                           
    │
    ├── windows/                         
    │
    ├── web/                             
    │
    ├── assets/                          
    │   └── images/
    │
    ├── lib/                             
    │   ├── core/
    │   │   └── config/
    │   │       └── environment.dart
    │   │
    │   ├── models/                      
    │   │
    │   ├── services/                  
    │   │
    │   ├── screens/                 
    │   │   ├── Admin/
    │   │   ├── Teacher/
    │   │   ├── Student/
    │   │   └── Authentication/               
    │   │
    │   ├── widgets/                     
    │   │
    │   └── main.dart......

## 5. Installation

    git clone
 https://github.com/Minahilgul/minahilfrontendattendance.git

    cd minahilfrontendattendance

    flutter pub get

    flutter run
##  6. Screenshots


### Splash Screen

![Splash Screen](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/splash.jpeg)

### Login Screen

![Login Screen](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/login.jpeg)

### Admin Dashboard

![Admin Dashboard](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/adminDashboard.jpeg)

### Teacher Dashboard

![Teacher Dashboard](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/teacherDashboard.jpeg)

### Student Dashboard

![Student Dashboard](https://raw.githubusercontent.com/Minahilgul/minahilfrontendattendance/main/assets/images/studentDashboard.jpeg)



## 7. License

This project is developed for educational purposes as a Final Year Project (FYP).

Distributed Attendance Verification System (DAVS)
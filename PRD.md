flutter build web --release# Product Requirement Document

## Product Name
Smart Class Check-in & Learning Reflection App

## Problem Statement
Universities need a simple way to confirm that students are physically present in class and actively participated in the session. Manual attendance alone is easy to fake and does not capture whether students engaged with the lesson. This MVP solves that by combining GPS location, QR code verification, and short learning reflections before and after class.

## Target User
- Primary user: university students attending scheduled classes
- Secondary stakeholder: instructors who want more reliable attendance and participation evidence

## Feature List
- Home screen with entry points for Check-in and Finish Class
- Pre-class check-in flow that records timestamp and GPS location
- QR code scanning to verify the student is in the correct class session
- Pre-class reflection form for previous topic, expected topic, and mood before class
- Post-class completion flow with QR code scan and GPS capture
- Post-class reflection form for what the student learned and feedback
- Local data storage for MVP using SQLite so records remain available on the device
- Validation to prevent incomplete submissions and require both scan and location before saving

## User Flow
1. Student opens the app and lands on the Home screen.
2. Student taps Check-in.
3. App requests location permission, captures GPS coordinates, and records the current timestamp.
4. Student scans the classroom QR code.
5. Student fills in the pre-class form: previous class topic, expected learning topic, and mood score from 1 to 5.
6. App validates required inputs and saves the check-in record locally.
7. At the end of class, the student taps Finish Class from the Home screen.
8. App captures GPS location again and the student scans the QR code again.
9. Student enters what they learned and optional feedback about the class or instructor.
10. App saves the completion record locally and shows a success message.

## Data Fields
| Field | Description |
|---|---|
| recordId | Unique local ID for each attendance record |
| studentId | Student identifier entered or preconfigured in app |
| sessionDate | Date of the class session |
| checkInTime | Timestamp when check-in is submitted |
| checkInLatitude | GPS latitude during check-in |
| checkInLongitude | GPS longitude during check-in |
| checkInQrValue | QR content captured during check-in |
| previousTopic | Topic covered in the previous class |
| expectedTopic | Topic expected in the current class |
| moodScore | Integer from 1 to 5 |
| finishTime | Timestamp when class completion is submitted |
| finishLatitude | GPS latitude during finish flow |
| finishLongitude | GPS longitude during finish flow |
| finishQrValue | QR content captured during finish flow |
| learnedToday | Short reflection on what the student learned |
| feedback | Student feedback about the class or instructor |

## Tech Stack
- Frontend: Flutter with Dart
- Navigation and UI: Flutter Material widgets
- GPS: geolocator or location package
- QR scanning: mobile_scanner or qr_code_scanner package
- Local storage: SQLite using sqflite package
- Deployment: Firebase Hosting for a Flutter Web build or landing/demo page
- Version control: GitHub repository

## MVP Scope Notes
For the MVP, the app focuses on one student role and stores data locally on the device. GPS and QR code are used as proof signals, while learning reflection provides lightweight evidence of participation. Instructor dashboards, authentication, and cloud sync are out of scope for the first version.
# TrueNeighbour

> Your community, your responsibility.
---

## About

TrueNeighbour is a real-time, hyper-local mutual aid platform that connects people facing immediate challenges with verified volunteers in their neighborhood.

---

## How It Works

- A user submits a help request, writes a description, selects a category, and sets an urgency level
- The request instantly appears on the live volunteer feed, powered by Firebase Firestore's persistent stream connections
- A volunteer claims the request with a single tap, locking it across the entire network to prevent duplicate efforts
- Once help is delivered, the volunteer marks it done and the requester confirms, closing the loop and updating both users' merit scores

---

## Technical Highlights

- **Real-Time Sync:** Firebase Firestore live-syncs all requests and status changes across devices without a page refresh
- **Single-Claim Accountability:** Only one volunteer can hold a request at a time, keeping commitments focused and reliable
- **OTP-Verified Identities:** Every user is verified through phone-based OTP, so the community stays trusted and accountable
- **Community Feed:** A social layer for daily neighborhood updates, with likes, comments, and reporting built in

---

## Core Features

### Real-Time Categorized Aid
Requests are classified into one of four aid streams, making it easy for volunteers to find relevant needs at a glance:

| Category | Description |
|---|---|
| Medical | Urgent health support, medication pickup, hospital transport |
| Food & Essentials | Grocery runs, meal delivery, and supply sourcing |
| Transport & Logistics | Rides, errand runs, and local deliveries |
| General Support / Education | Tutoring, home repairs, companionship |

### Dynamic Urgency Levels
Each request is assigned a priority tier to help volunteers triage their attention effectively:

- **Normal** — Non-time-sensitive assistance
- **Urgent** — Requires prompt action
- **Critical** — Immediate response needed

### Volunteer Claim System
A single-active-claim policy ensures focused, accountable volunteering. A volunteer must fulfill their current commitment before taking on a new one, preventing request hoarding and ensuring genuine follow-through.

### Merit & Badge System
Altruism is encouraged and celebrated through a structured reward framework:

- Points awarded for every completed claim
- Badge tiers unlocked as merit accumulates
- Global leaderboard to recognize top community contributors

| Tier | Badge | Description |
|---|---|---|
| 1 | Newcomer | Just getting started |
| 2 | Helper | Consistently showing up |
| 3 | Contributor | Trusted, high-impact volunteer |
| 4 | Champion | Community cornerstone |

---

## What Makes TrueNeighbour Different

**Operational Accountability:** Unlike broad social platforms, TrueNeighbour enforces a strict one-claim-at-a-time limit, ensuring every commitment leads to real, focused help.

**Hyper-Local Focus:** Optimized for neighborhood-level interactions, reducing the overhead common to larger, generalized volunteer organizations.

**Verifiable Altruism:** The merit system provides a transparent, structured record of community impact, fostering mutual trust and a culture of recognition.

---

## Getting Started

### Prerequisites

Make sure you have the following installed before proceeding:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10.8 or higher)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with the Flutter and Dart extensions
- Git
- A Firebase project with Firestore and Auth enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tanmayxswain/TrueNeighbour.git
   cd TrueNeighbour
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**

   This project uses FlutterFire. You will need to add the Firebase config files for your environment:
   - Android: Place `google-services.json` inside `android/app/`
   - iOS: Place `GoogleService-Info.plist` inside `ios/Runner/`

   > These files are not included in the repository for security reasons. Reach out to the team if you need access to the Firebase project.

4. **Run the app:**
   ```bash
   flutter devices       # Check connected devices
   flutter run           # Run on default device
   flutter run -d chrome # Run on browser
   ```

---

## Project Structure

```
TrueNeighbour/
├── android/
├── ios/
├── assets/
│   └── images/
│       └── logo.png
├── lib/
│   ├── models/
│   │   └── request_model.dart
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   ├── signup_page.dart
│   │   ├── otp_verification_page.dart
│   │   ├── main_shell.dart
│   │   ├── post_need_page.dart
│   │   ├── my_requests_page.dart
│   │   ├── my_claims_page.dart
│   │   ├── merit_page.dart
│   │   ├── history_page.dart
│   │   ├── profile_page.dart
│   │   ├── settings_page.dart
│   │   ├── faq_page.dart
│   │   ├── privacy_policy_page.dart
│   │   ├── terms_of_service_page.dart
│   │   └── specification_safety_page.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── merit_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   ├── widgets/
│   │   ├── app_drawer.dart
│   │   └── request_card.dart
│   ├── firebase_options.dart
│   └── main.dart
├── test/
├── firestore.rules
├── firebase.json
└── pubspec.yaml
```

---

## Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Database | Firebase Firestore (real-time) |
| Authentication | Firebase Auth + OTP |

---

## Future Scope

### Community ID Groups
Private, membership-restricted communities with:
- Unique Community IDs for each group
- Fixed resident capacity per ID
- Exclusive feeds restricted to verified members, enhancing trust and security

### Community-Specific Analytics
Data-driven dashboards for community leads, surfacing local need patterns and volunteer engagement metrics within their specific ID groups.

---

## Team

| Name | Role |
|---|---|
| Tanmay | Ideation, Product Planning, Development |
| Madhav | Firebase Integration & App Development |
| Mushkan | UI/UX Design & Feature Execution |
| Aditi | Strategic Direction & Advisory |

---

*Your community, your responsibility.*

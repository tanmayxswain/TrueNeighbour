# TrueNeighbour

> Unite Locally, Grow Globally


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
| Food | Grocery runs, meal delivery, and supply sourcing |
| Emergency | Rides, errand runs, and local deliveries |
| General | Tutoring, home repairs, companionship |

### Dynamic Urgency Levels
Each request is assigned a priority tier to help volunteers triage their attention effectively:

- **Normal** — Non-time-sensitive assistance
- **Urgent** — Requires prompt action
- **Critical** — Immediate response needed

### Volunteer Claim System
A single-active-claim policy ensures focused, accountable volunteering. A volunteer must fulfil their current commitment before taking on a new one, preventing request hoarding and ensuring genuine follow-through.

### Merit & Badge System
Altruism is encouraged and celebrated through a structured reward framework:

- Points awarded for every completed claim
- Badge tiers unlocked as merit accumulates
- Global leaderboard to recognize top community contributors

| Tier | Badge | Description |
|---|---|---|
| 1 | Starter | Just getting started |
| 2 | Helper | Consistently showing up |
| 3 | Champion | Trusted, high-impact volunteer |
| 4 | Legend | Community cornerstone |

---

## What Makes TrueNeighbour Different

**Operational Accountability:** Unlike broad social platforms, TrueNeighbour enforces a strict one-claim-at-a-time limit, ensuring every commitment leads to real, focused help.

**Hyper-Local Focus:** Optimized for neighbourhood-level interactions, reducing the overhead common to larger, generalized volunteer organizations.

**Verifiable Altruism:** The merit system provides a transparent, structured record of community impact, fostering mutual trust and a culture of recognition.

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

*Unite Locally, Grow Globally*

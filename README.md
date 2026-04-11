# HabitForge 🔨
### Forge powerful habits one day at a time.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.25.0-blue.svg)](https://flutter.dev)
[![Submission](https://img.shields.io/badge/Submission-8th%20Attempt-orange.svg)](docs/submission_history.md)
[![Aesthetics](https://img.shields.io/badge/UI%2FUX-Premium-emerald.svg)](#)

HabitForge is a high-performance habit tracking application engineered for consistency. It leverages behavioral psychology, loss-aversion mechanics (streaks), and high-fidelity data visualization to help users transform their routines into their identity.

---

## 🚀 Product Strategy (8th Attempt Overhaul)

We have rebuilt the core user experience to meet the highest Google Play standards. The "8th Attempt" focuses on **Visual Dopamine** and **Legal Sovereignty**:
- **Forging Engine**: Micro-animations (shake/scale) on completion for immediate reinforcement.
- **Glassmorphic UI**: A modern, clean aesthetic using the `#F8FAFC` slate palette.
- **Data Sovereignty**: Implemented mandatory Play Store "Delete Account" flows with cascading Firestore deletion.
- **Legal Hub**: Centralized compliance for Privacy, Terms, and Medical Disclaimers.

---

## ✨ Core Feature Set

- **Forging Engine**: Create and manage daily/weekly habits with custom icons and colors.
- **Consistency Heatmap**: A detailed 30-day grid visualizing your discipline.
- **Analytics Dashboard**: Comprehensive breakdown of completion rates, active fire (streaks), and historical bests.
- **Smart Reminders**: Precision-timed notifications to ensure a habit is never missed.
- **Premium Tier**: Unlocks unlimited forging and advanced behavior insights.

---

## 🛠 Tech Stack & Architecture

### Mobile App (Flutter)
- **State Management**: Riverpod (Domain-driven providers)
- **Local Cache**: Hive & SharedPreferences
- **Animations**: `flutter_animate`, `Lottie`
- **Charts**: `fl_chart`
- **Routing**: `go_router` (Declarative navigation)

### Backend (Firebase)
- **Auth**: Firebase Authentication (Email/Password & Social)
- **Database**: Cloud Firestore (Real-time sync)
- **Logic**: Node.js Cloud Functions (Recursive data purging on user delete)
- **Messaging**: Firebase Cloud Messaging (FCM)

---

## 📂 Project Structure

```text
habitforge/
├── mobile_app/           # Production-ready Flutter Application
│   ├── lib/core/         # Layouts, Themes, Constants, Global Services
│   ├── lib/features/     # Modular features (Auth, Habits, Analytics)
│   ├── lib/models/       # Type-safe Data Models (JSON Serialized)
│   └── lib/widgets/      # Reusable UI Atoms and Molecules
├── backend/              # Firebase Infrastructure
│   └── functions/        # Node.js purgers and auth triggers
├── landing_page/         # Modern Next.js 15 presence (Vercel)
├── legal/                # Google Play Compliant Legal Documentation
└── assets/               # Branding, Logo, and Animation files
```

---

## 💰 Monetization & Growth
HabitForge utilizes a **Freemium Model ($4.99/mo)**.
- **Free**: Up to 5 habits, basic streaks.
- **Premium**: Unlimited forging, historical heatmaps, and priority cloud sync.

---

## 🛡 License & Compliance
**Proprietary Commercial Software.** All rights reserved.
HabitForge is fully compliant with Google Play Data Safety and User Data policies, including mandatory account deletion and transparent legal hub.

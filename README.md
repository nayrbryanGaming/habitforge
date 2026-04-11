# HabitForge: Forge powerful habits one day at a time.

<p align="center">
  <img src="assets/logo/logo-placeholder.png" alt="HabitForge Logo" width="150" />
</p>

## 🚀 Product Description
HabitForge is a modern habit tracking mobile application designed to help users build consistent daily routines through behavioral psychology, streak tracking, smart reminders, and visual progress analytics. 

While most habit trackers suffer from overly complex UIs or lack of analytics, HabitForge simplifies the experience while providing deep behavioral insights and streak-based motivation systems.

## 🎯 Target Market
- Students
- Remote Workers
- Productivity Enthusiasts
- Startup Founders
- Self-Improvement Community (Ages: 18-40)

## ✨ Core Features
- **Habit Creation:** Create daily or weekly routines easily.
- **Habit Tracking:** Effortless one-tap completion logs.
- **Streak System:** Visual streak counters leveraging loss-aversion psychology.
- **Smart Reminders:** Hyper-local push notifications via FCM.
- **Analytics Dashboard:** Weekly/Monthly charts computing completion rates automatically.
- **Freemium Model:** 5 free habits. Premium unlocks unlimited tracking.

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart), Riverpod (State Management)
- **Backend:** Firebase (Auth, Firestore DB, Cloud Functions)
- **Landing Page:** Next.js, Tailwind CSS
- **Deployment:** Android Play Store / iOS App Store target.

## 📂 Project Architecture
We utilize a Feature-Based Modular Architecture for the Flutter app.

```
habitforge/
├── mobile_app/         # Flutter application
│   ├── lib/core/       # App-wide constants, themes, layout wrappers
│   ├── lib/features/   # Feature modules (Auth, Habit tracking, Analytics)
│   ├── lib/models/     # Data shape modeling (Habit, Log, User, Analytics)
│   └── lib/widgets/    # Reusable UI components
├── backend/            # Firebase Cloud Functions (Node.js)
├── landing_page/       # Next.js web presence
├── legal/              # Google Play compliant legal documents
└── docs/               # Technical specs and strategy
```

## ⚙️ Installation Guide

### Prerequisites
- Flutter SDK (v3.25.0+)
- Node.js (v18+)
- Firebase CLI (`npm install -g firebase-tools`)

### Mobile App Setup
1. `cd mobile_app`
2. `flutter pub get`
3. Setup Firebase using FlutterFire CLI: `flutterfire configure`
4. `flutter run`

### Landing Page Setup
1. `cd landing_page`
2. `npm install`
3. `npm run dev`

### Backend Setup
1. `cd backend/functions`
2. `npm install`
3. `firebase deploy --only functions`

## 💰 Monetization Strategy
**Freemium Model ($4.99/month)**
Free tier acts as a powerful acquisition funnel with a 5 habit cap. The premium tier unlocks unlimited habits, deep historical analytics, and priority support.

## 🛡 License
Proprietary / Commercial. All rights reserved.

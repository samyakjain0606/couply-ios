# Couply iOS App - Implementation Plan

## Overview
A couples-focused photo sharing app where partners can instantly capture and send photos to each other in 2-3 taps, with push notifications and home screen widgets.

---

## Key Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Backend** | Firebase | Fast MVP, real-time sync, built-in push notifications |
| **Auth** | Phone Number | Simple like BeReal/Locket, familiar to users |
| **Storage** | Keep Forever | Photos are memories, core value for couples |
| **Monetization** | Freemium (later) | Free MVP first, add premium features later |

---

## What Makes Couply Different

### The Core Promise
**"Feel connected in 2 seconds"** - Not another messaging app, but a window into your partner's world.

---

## Signature Features (The Crazy Stuff)

### 1. "Sync Moment" (Like BeReal, But Together)
- Random notification goes to BOTH partners at same time
- "Sync Moment! Show each other what you're doing RIGHT NOW"
- Both photos appear side-by-side in a split view
- Creates shared spontaneous memories
- Optional: Can decline if in a meeting (limited skips per week)

### 2. "Digital Touch"
- **Heartbeat**: Hold finger on screen → partner feels your heartbeat through haptics
- **Poke**: Quick tap → partner's phone vibrates with a playful animation
- **Squeeze Hug**: Squeeze phone (pressure sensors) → partner gets a warm hug animation + haptic
- These work even from lock screen widget!

### 3. "Live Glimpse"
- Tap and hold on partner's widget → see their LIVE camera for 3 seconds
- They get notified "Your partner is peeking"
- Opt-in feature with privacy controls
- Like a digital window into their world

### 4. "Ugly Selfie Wars"
- Challenge mode: Who can take the ugliest selfie?
- Voting/rating system between the couple
- Leaderboard and trophies
- "Hall of Shame" gallery
- Weekly winner gets to set the other's profile pic

### 5. "Mood Ring" Status
- Quick mood check-in (3 taps max)
- Partner always sees your current mood
- Moods: Great | Meh | Need a hug | Missing you | Tired | Excited
- Auto-prompts: "Your partner is feeling sad, send them something sweet?"

### 6. "Countdown Together"
- Shared countdown timers: "Next date in 3 days 14 hours"
- "Days until vacation: 47"
- Widget shows countdown with both your photos
- Celebration animation when countdown hits zero

### 7. "Doodle Notes"
- Quick draw on blank canvas or on photos
- Partner receives animated drawing (shows stroke by stroke)
- Great for quick love notes, silly drawings
- "Draw on their face" mode

### 8. "Distance Hug"
- When far apart, shows distance between you
- "You're 847 km apart"
- Optional daily tracking: "Closest today: 0.5 km (11:30 AM)"
- Anniversary of first time at 0 km

### 9. "Secret Photo Drops"
- Schedule a photo to arrive at specific time
- "This photo will unlock at 8:00 AM tomorrow"
- Great for surprise good morning photos
- Can set location triggers: "Opens when you arrive at work"

### 10. "Our Song" Integration
- Connect Spotify/Apple Music
- Set "your song" - plays when viewing memories together
- "What's playing" - see what partner is listening to
- Send song snippets with photos

---

## Gamification & Engagement

### Streak System
- Daily photo exchange keeps streak alive
- Streak counter visible everywhere
- Milestone rewards: 7 days, 30 days, 100 days, 365 days
- "Streak freeze" - 1 free pass per month

### Achievements & Badges
- "Early Bird" - Send photo before 7 AM
- "Night Owl" - Exchange photos after midnight
- "Globe Trotter" - Photos from 5+ different cities
- "Sync Master" - Complete 10 Sync Moments
- "Ugly Champion" - Win 5 Ugly Selfie Wars

### Relationship XP
- Level up your relationship
- XP for: photos sent, streaks, sync moments, reactions
- Unlock: new themes, special filters, premium features
- Leaderboard? (opt-in, anonymous)

---

## Memory & Nostalgia Features

### "On This Day"
- Morning notification: "1 year ago today..."
- Shows old photos with option to recreate
- Side-by-side comparison: Then vs Now

### Auto-Generated Memories
- Weekly recap video (auto-compiled)
- Monthly "Best Of" gallery
- Anniversary slideshow with your song
- Year-in-review at relationship anniversary

### Relationship Timeline
- Visual timeline of your photos
- Key milestones marked
- First photo, 100th photo, special moments
- Can add manual milestones: "First trip together"

### Photo Capsule
- Create a time capsule with photos
- Set unlock date: 1 year, 5 years, etc.
- Both partners contribute, neither can peek
- Notification when it's time to open

---

## Communication Features

### Quick Reactions (Instagram-style but cuter)
- Double-tap: heart animation
- Swipe reactions: various love emojis
- Custom couple reactions you create together
- Reaction stats: "Most used: fire"

### Voice Notes
- Hold to record (up to 15 sec)
- Cute waveform visualization
- Partner can replay infinite times
- "Voice of the day" feature

### Photo Replies
- Reply to a photo with another photo
- Creates conversation threads
- "Show me yours" prompts

---

## Customization

### Themes & Aesthetics
- Unlock themes through XP
- Seasonal themes (Valentine's, Halloween, etc.)
- Custom theme creator (pick colors, fonts)
- Matching themes synced between both phones

### Couple Profile
- Joint profile with both photos
- Relationship status, anniversary date
- "About us" bio you write together
- Shareable couple card

### Widget Customization
- Multiple widget styles
- Choose what to show: latest photo, streak, mood, countdown
- Custom backgrounds and frames
- Photo of the day rotation

---

## Core User Flow (2-3 Taps)
```
App Opens → Camera Ready → Tap Capture → Photo Sent!
```

---

## App Structure & Navigation

### Main Tabs (Bottom Navigation)
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│              [MAIN CONTENT AREA]                    │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Camera    Chat     Feed     Connect   Profile      │
└─────────────────────────────────────────────────────┘
```

### Tab 1: Camera (Default Landing)
- Full-screen camera (front camera default)
- Big capture button at bottom
- Flip camera button (top right)
- Gallery picker (bottom left)
- Flash toggle
- After capture: Quick send with optional caption/doodle

### Tab 2: Chat
- Photo-first conversation thread
- Voice notes
- Doodle messages
- Quick reactions
- "Thinking of you" poke button

### Tab 3: Feed / Memories
- Timeline of all photos (yours + theirs)
- Filter: All | Sent | Received | Favorites
- "On This Day" section at top
- Search by date
- Auto-generated memory collections

### Tab 4: Connect (The Fun Stuff)
- **Mood Ring** - Set your mood
- **Digital Touch** - Heartbeat, Poke, Hug
- **Sync Moment** - Start a sync challenge
- **Ugly Selfie Wars** - Challenge mode
- **Countdowns** - Manage shared timers
- **Our Song** - Music integration
- **Distance** - See how far apart you are

### Tab 5: Profile / Settings
- Couple profile (both photos)
- Streak counter & achievements
- Relationship stats
- Settings (notifications, privacy)
- Theme customization
- Account management

---

## Widget Designs

### Small Widget (2x2)
```
┌─────────────┐
│  [Partner's │
│   Latest    │
│   Photo]    │
│   Streak 47 │
└─────────────┘
```

### Medium Widget (4x2)
```
┌───────────────────────────┐
│ [Photo]  │  Partner Name  │
│          │  Feeling       │
│          │  great!        │
│          │  47 days       │
└───────────────────────────┘
```

### Large Widget (4x4)
```
┌───────────────────────────┐
│  [Latest Photo - Big]     │
│                           │
│  ─────────────────────    │
│  [Thumb] [Thumb] [Thumb]  │
│  47 days  Tap to send     │
└───────────────────────────┘
```

### Lock Screen Widget
- Circular photo of partner
- Tap: Quick send photo
- Hold: Feel heartbeat

---

## Onboarding Flow

### Step 1: Welcome
- Beautiful animation
- "The simplest way to stay connected"
- Sign up with phone number

### Step 2: Phone Verification
- Enter phone → Receive OTP → Verify

### Step 3: Profile Setup
- Add your name
- Take your first selfie (becomes profile pic)

### Step 4: Connect with Partner
**Option A: Send Invite**
- Generate unique link/code
- Share via Messages, WhatsApp, etc.
- "Waiting for [Partner] to join..."

**Option B: Enter Code**
- Partner shared a code with you
- Enter code → Instantly connected

### Step 5: First Photo
- "Send your first photo to [Partner]!"
- Camera opens, ready to capture
- Celebration animation when sent

### Step 6: Enable Features
- Allow notifications (important!)
- Add widget to home screen (guided)
- Tutorial: "Hold here to send heartbeat"

---

## Tech Stack
- **UI**: SwiftUI (iOS 17+)
- **Backend**: Firebase
  - Authentication (Phone Auth)
  - Firestore (Database)
  - Storage (Photos)
  - Cloud Messaging (Push Notifications)
  - Cloud Functions (Triggers)
- **Widgets**: WidgetKit
- **Camera**: AVFoundation + PhotosUI
- **Images**: Kingfisher (caching & loading)

---

## Phase 1: Project Setup & Firebase Integration

### 1.1 Create Xcode Project
- New SwiftUI App project named "Couply"
- Bundle ID: `com.couply.app`
- iOS 17+ deployment target
- Enable capabilities:
  - Push Notifications
  - Background Modes (Remote notifications)
  - App Groups (for widget data sharing)

### 1.2 Firebase Setup
1. Create Firebase project at console.firebase.google.com
2. Add iOS app with bundle ID `com.couply.app`
3. Download `GoogleService-Info.plist`
4. Enable services:
   - Authentication → Phone sign-in
   - Firestore Database
   - Storage
   - Cloud Messaging

### 1.3 Add Dependencies (Swift Package Manager)
```
https://github.com/firebase/firebase-ios-sdk
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseStorage
  - FirebaseMessaging

https://github.com/onevcat/Kingfisher
```

### 1.4 Project Structure
```
Couply/
├── App/
│   ├── CouplyApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Models/
│   ├── Services/
│   └── Extensions/
├── Features/
│   ├── Onboarding/
│   ├── Camera/
│   ├── Feed/
│   ├── Chat/
│   └── Settings/
├── Widgets/
│   └── CouplyWidget/
└── Resources/
    └── Assets.xcassets
```

---

## Phase 2: Authentication & Partner Pairing

### 2.1 Data Models
```swift
struct User {
    let id: String
    let phoneNumber: String
    let displayName: String
    let avatarURL: String?
    let partnerID: String?
    let coupleID: String?
    let createdAt: Date
}

struct Couple {
    let id: String
    let user1ID: String
    let user2ID: String
    let createdAt: Date
    let streakCount: Int
    let lastPhotoDate: Date?
}
```

### 2.2 Pairing Flow
1. User signs up with phone number (Firebase Auth)
2. User gets unique invite code OR enters partner's code
3. Once paired, both users see shared feed
4. Deep link support: `couply://pair?code=ABC123`

---

## Phase 3: Quick Photo Capture (Core Feature)

### 3.1 Camera View (Default Landing Screen)
- Opens directly to camera when app launches
- Front camera by default (selfie-focused)
- Large capture button at bottom
- Flip camera button
- Gallery picker (for existing photos)

### 3.2 Send Flow (2 Taps)
```
Tap 1: Capture photo
Tap 2: Send (with optional quick reaction/caption)
```

### 3.3 Photo Model
```swift
struct Photo {
    let id: String
    let senderID: String
    let coupleID: String
    let imageURL: String
    let thumbnailURL: String
    let caption: String?
    let reaction: String?
    let viewedAt: Date?
    let createdAt: Date
}
```

### 3.4 Upload Service
- Compress image before upload
- Upload to Firebase Storage
- Create Firestore document
- Trigger push notification to partner

---

## Phase 4: Photo Feed & Viewing

### 4.1 Feed View
- Scrollable grid/list of received photos
- Tap to view full screen
- Show unviewed photos prominently
- Heart/react button on each photo

### 4.2 Photo Detail View
- Full screen photo display
- Swipe to navigate between photos
- Quick reaction buttons
- Reply with photo option

---

## Phase 5: Push Notifications

### 5.1 Setup
- Configure APNs in Apple Developer Portal
- Add Firebase Cloud Messaging
- Request notification permissions on first launch

### 5.2 Notification Types
- New photo received (with thumbnail)
- Partner started typing/capturing
- Daily reminder if no photos exchanged
- Streak milestone notifications

### 5.3 Rich Notifications
- Show photo thumbnail in notification
- Quick reply actions (heart, reply with photo)

---

## Phase 6: Home Screen Widget

### 6.1 Widget Types
- **Small**: Latest photo from partner
- **Medium**: Latest photo + streak counter
- **Large**: Photo grid (last 4 photos)

### 6.2 Implementation
- WidgetKit extension
- Shared App Group for data access
- Timeline provider for updates
- Deep link to app on tap

---

## Phase 7: Couply Features (Chat & Engagement)

### 7.1 Reactions & Responses
- Heart reactions (double-tap)
- Quick emoji reactions
- Voice notes (short clips)
- Drawing on photos

### 7.2 Streak System
- Daily photo exchange streak
- Streak counter in app and widget
- Milestone celebrations (7 days, 30 days, etc.)

### 7.3 Mood Sharing
- "How's your day?" quick check-in
- Mood status visible to partner
- Mood-based photo prompts

### 7.4 Special Dates
- Anniversary reminders
- Countdown to next date
- Memory "On this day" feature

### 7.5 Mini Games (Future)
- Question of the day
- Would you rather
- Love language quiz

---

## File Structure to Create

```
/Users/sjain/couply-ios/
├── Couply.xcodeproj
├── Couply/
│   ├── App/
│   │   ├── CouplyApp.swift
│   │   └── AppDelegate.swift
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── User.swift
│   │   │   ├── Couple.swift
│   │   │   └── Photo.swift
│   │   ├── Services/
│   │   │   ├── AuthService.swift
│   │   │   ├── PhotoService.swift
│   │   │   ├── NotificationService.swift
│   │   │   └── PairingService.swift
│   │   └── Extensions/
│   │       └── View+Extensions.swift
│   ├── Features/
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift
│   │   │   ├── PhoneAuthView.swift
│   │   │   └── PairingView.swift
│   │   ├── Camera/
│   │   │   ├── CameraView.swift
│   │   │   ├── CameraViewModel.swift
│   │   │   └── PhotoPreviewView.swift
│   │   ├── Feed/
│   │   │   ├── FeedView.swift
│   │   │   └── PhotoDetailView.swift
│   │   ├── Chat/
│   │   │   ├── ChatView.swift
│   │   │   └── ReactionPicker.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── GoogleService-Info.plist
│   └── Info.plist
├── CouplyWidget/
│   ├── CouplyWidget.swift
│   ├── WidgetViews.swift
│   └── Info.plist
└── CouplyTests/
```

---

## MVP Scope (First Release)

Focus on these for v1.0:
1. Phone auth & partner pairing
2. Quick photo capture & send (2 taps)
3. Photo feed with viewing
4. Push notifications for new photos
5. Basic widget (latest photo)

---

## Verification Plan

### Testing Approach
1. **Unit Tests**: Services (Auth, Photo upload, Pairing)
2. **UI Tests**: Camera flow, feed navigation
3. **Manual Testing**: Use iOS Simulator skill scripts
4. **Real Device**: Test camera, notifications, widgets

### Test Scenarios
- [ ] New user signup and pairing flow
- [ ] Capture and send photo (verify 2-tap flow)
- [ ] Partner receives push notification
- [ ] Photo appears in feed and widget
- [ ] Streak counter updates correctly

---

## Implementation Roadmap

### MVP (Version 1.0) - Core Experience
**Goal: Basic photo sharing that works flawlessly**

| Feature | Priority | Description |
|---------|----------|-------------|
| Phone Auth | P0 | Sign up/login with phone number |
| Partner Pairing | P0 | Invite code system to connect couples |
| Camera View | P0 | Full-screen camera, capture, preview |
| 2-Tap Send | P0 | Capture → Send (the core promise) |
| Photo Feed | P0 | View received photos |
| Push Notifications | P0 | "New photo from [Partner]" |
| Basic Widget | P1 | Small widget with latest photo |
| Streak Counter | P1 | Track daily exchanges |

### Version 1.1 - Engagement
**Goal: Make it sticky and fun**

| Feature | Priority | Description |
|---------|----------|-------------|
| Mood Ring | P0 | Quick mood status |
| Quick Reactions | P0 | Double-tap hearts, emoji reactions |
| Digital Touch - Poke | P1 | Quick haptic tap to partner |
| Doodle Notes | P1 | Draw on canvas or photos |
| Streak Milestones | P1 | Celebrate 7, 30, 100 days |
| Medium Widget | P1 | Mood + streak + photo |

### Version 1.2 - The Wow Features
**Goal: Features they'll tell friends about**

| Feature | Priority | Description |
|---------|----------|-------------|
| Sync Moment | P0 | Both capture at same random time |
| Ugly Selfie Wars | P0 | Fun challenge mode |
| Digital Touch - Heartbeat | P1 | Feel partner's heartbeat |
| Countdowns | P1 | Shared event timers |
| Voice Notes | P1 | Quick audio messages |
| On This Day | P1 | Memory flashbacks |

### Version 2.0 - Premium & Polish
**Goal: Monetization + advanced features**

| Feature | Priority | Description |
|---------|----------|-------------|
| Live Glimpse | P0 | Peek at partner's camera |
| Secret Photo Drops | P0 | Scheduled/location-triggered photos |
| Photo Capsule | P1 | Time capsule for future |
| Music Integration | P1 | Spotify/Apple Music "Our Song" |
| Themes & Customization | P1 | Unlock via XP or purchase |
| Auto-Generated Memories | P2 | Weekly recaps, anniversary slideshows |
| Achievement System | P2 | Badges and XP |

---

## Sprint-by-Sprint Breakdown (MVP)

### Sprint 1: Foundation (Week 1)
- [ ] Create Xcode project with folder structure
- [ ] Set up Firebase project and integrate SDK
- [ ] Build data models (User, Couple, Photo)
- [ ] Create AuthService with phone authentication
- [ ] Build onboarding UI (welcome, phone auth screens)

### Sprint 2: Pairing (Week 2)
- [ ] Create PairingService with invite code generation
- [ ] Build pairing UI (send invite / enter code)
- [ ] Deep link support for invite links
- [ ] Store couple relationship in Firestore
- [ ] Profile setup screen

### Sprint 3: Camera & Send (Week 3)
- [ ] Build CameraView with AVFoundation
- [ ] Front/back camera toggle
- [ ] Capture and preview flow
- [ ] PhotoService for Firebase Storage upload
- [ ] Implement 2-tap send (capture → send)

### Sprint 4: Feed & Notifications (Week 4)
- [ ] Create FeedView to display photos
- [ ] PhotoDetailView for full-screen viewing
- [ ] Real-time Firestore listeners
- [ ] Set up APNs + Firebase Cloud Messaging
- [ ] Cloud Function to trigger notifications on new photo

### Sprint 5: Widget & Polish (Week 5)
- [ ] Create WidgetKit extension
- [ ] Small widget with latest photo
- [ ] App Groups for data sharing
- [ ] Streak counter logic and UI
- [ ] Polish: animations, haptics, error handling

### Sprint 6: Testing & Launch (Week 6)
- [ ] TestFlight beta testing
- [ ] Bug fixes from beta feedback
- [ ] App Store screenshots and description
- [ ] Submit for review
- [ ] Launch!

---

## Files to Create (In Order)

```
1.  Couply/App/CouplyApp.swift
2.  Couply/App/AppDelegate.swift
3.  Couply/Core/Models/User.swift
4.  Couply/Core/Models/Couple.swift
5.  Couply/Core/Models/Photo.swift
6.  Couply/Core/Services/AuthService.swift
7.  Couply/Core/Services/FirebaseService.swift
8.  Couply/Features/Onboarding/OnboardingView.swift
9.  Couply/Features/Onboarding/PhoneAuthView.swift
10. Couply/Features/Onboarding/PairingView.swift
11. Couply/Features/Camera/CameraView.swift
12. Couply/Features/Camera/CameraViewModel.swift
13. Couply/Features/Camera/PhotoPreviewView.swift
14. Couply/Core/Services/PhotoService.swift
15. Couply/Features/Feed/FeedView.swift
16. Couply/Features/Feed/PhotoDetailView.swift
17. Couply/Features/MainTabView.swift
18. Couply/Core/Services/NotificationService.swift
19. Couply/Features/Settings/SettingsView.swift
20. CouplyWidget/CouplyWidget.swift
```


# 🌿 Momentum — A Calming Productivity & Journaling App

> *Plan. Focus. Reflect — beautifully.*

Momentum is a minimalist productivity and journaling Flutter application designed to help you organize your tasks, focus deeply, and capture your thoughts in a calming, clutter-free environment.  
It blends soft aesthetics with practical tools to make planning feel peaceful and personal.

---

## ✨ Features

- 🧾 **Task Manager** — Add, prioritize, reorder, and mark tasks as complete  
- ⏳ **Focus Timer (Pomodoro)** — Stay productive with adjustable focus sessions  
- 🗓️ **Planner** — Switch between daily, weekly, or monthly views  
- 📒 **Notes & Journal** — Write freely, attach images, and reflect mindfully  
- 🎨 **Warm, Safe Aesthetic** — Gentle beige-green tones that feel welcoming  
- 💾 **Offline Assets** — Uses local images for a smooth, offline-friendly experience  
- ⚡ **Responsive Design** — Optimized for web, mobile, and desktop


---

## 🖼️ App Pages

| Page | Description |
|------|--------------|
| 🏠 **Home Dashboard** | Displays overall productivity and quick shortcuts |
| 🗓 **My Tasks** | Add, delete and prioritize your tasks |
| ⏱ **Focus Timer** | Pomodoro-style timer to help you focus mindfully |
| 🗓 **Planner** | Organized view for planning day, week, or month |
| 📝 **Notes & Journal** | A peaceful space to jot thoughts and upload images |

---

## 🧩 Project Structure

```

momentum_app/
├─ lib/
│  ├─ main.dart
│  └─ widgets/
│     └─ hero_header.dart
├─ assets/
│  └─ images/
│     ├─ home.jpg
│     ├─ focus.jpg
│     ├─ planner.jpg
│     └─ notes.jpg
├─ pubspec.yaml
└─ README.md

````

---

## 🚀 Getting Started

### 1️⃣ Clone this repository
```bash
git clone https://github.com/<your-username>/Momentum-Flutter.git
cd Momentum-Flutter
````

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Run the app

```bash
flutter run
```

### 4️⃣ For web preview

```bash
flutter run -d chrome
```

---

## 🪴 Assets Setup

Store all your images here:

```
assets/images/
```

Make sure this section exists in your `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Then reference images in your Dart code like:

```dart
Image.asset('assets/images/notes.jpg', fit: BoxFit.cover);
```

---

## 🧠 Future Enhancements

* 🔔 Smart task reminders & notifications
* 📈 Productivity stats and streak tracker
* ☁️ Cloud sync for backup and multi-device use
* 💬 Daily journaling prompts for reflection
* 🌙 Dark mode for night journaling

---

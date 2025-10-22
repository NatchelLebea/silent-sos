
---

#  SilentSOS – Your Voice When You Can’t Speak

SilentSOS is a Flutter-based safety and emotional support application created in response to the alarming rise of gender-based violence in South Africa, where help often arrives *too late*.
The app empowers users to trigger SOS alerts, share live location, and access emotional guidance through an integrated AI support chatbot powered by Rasa.

---

# Motivation

Every day, countless women and vulnerable people in South Africa experience gender-based violence (GBV) — and far too often, help arrives too late.
SilentSOS was built to change that by detecting distress, alerting loved ones instantly, and offering emotional support in moments of fear or trauma.

> “I built SilentSOS because I was tired of hearing stories that end with ‘if only someone had known.’”
> — Natchel Lebea

---

# Features

# Safety Features

Voice Trigger SOS – Detects your trigger word and activates emergency mode.
Live Location Alerts – Sends GPS coordinates to trusted contacts via SMS.
Firebase Integration – Securely stores emergency contacts and user data.
Continuous Listening – Always ready to detect your SOS word in the background.
Dialog Confirmation – Displays a visual alert when SOS is triggered.

# Emotional Support Features

Rasa Chatbot Integration – A compassionate AI companion trained to:

* Offer calm, supportive guidance during or after a stressful event.
* Help users regulate anxiety or fear with grounding techniques.
* Provide mental health resources and encouraging affirmations.

---

# Tech Stack

| Component          | Technology                     |
| -------------------| ------------------------------ |
| Frontend           | Flutter (Dart)                 |
| Backend            | Django + Firebase Firestore    |
| AI Chatbot         | Rasa (Python NLP Framework)    |
| Speech Recognition | speech_to_text                 |
| Location & SMS     | geolocator, telephony          |
| State Management   | Provider                       |
| Storage            | Shared Preferences + Firestore |

---

# Installation

# Flutter Setup

```bash
git clone https://github.com/YOUR_USERNAME/SilentSOS.git
cd SilentSOS
flutter pub get
flutter run
```

# Django Backend

```bash
cd backend
python -m venv env
env\Scripts\activate
pip install -r requirements.txt
python manage.py runserver 0.0.0.0:8000
```

# Rasa Chatbot

```bash
cd rasa_bot
pip install -r requirements.txt
rasa train
rasa run --enable-api
```

Then connect it to Flutter via a REST API endpoint, e.g.:

```
http://<your-ip>:5005/webhooks/rest/webhook
```

---

# Permissions

In `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

---

#Future Improvements

Offline Mode – Work without internet for faster emergency response.
Gesture & Button Triggers– SOS via handshakes or volume buttons.
AI Scream Detection – Use ML to detect screams or panic and trigger SOS.
Emotional Recovery Mode – Rasa bot offers post-event guidance and resources.
Live Tracking – Allow responders to track your movement in real-time.
Push Notifications – Send instant updates to contacts via Firebase Cloud Messaging.

---

## Author

 Natchel Lebea
📍 South Africa 🇿🇦
📧 [lebean0101@gmail.com]

> “SilentSOS is for everyone who never got the chance to ask for help —
> and for everyone who needs a voice when they can’t speak.”

---

##  Acknowledgements

To all victims and survivors of GBV — your strength inspired this.
To developers using tech to protect and heal — keep building.

---


  That’ll make your GitHub page look **professional and portfolio-ready**.


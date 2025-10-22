
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
# Screenshots Of the App

# Login and Register
![1000000130](https://github.com/user-attachments/assets/fe2daad2-6cd6-460a-b1ab-afdcfa7bd785)
![1000000131](https://github.com/user-attachments/assets/74eb3f6d-4d9d-4fa2-a101-ad84c1a00bb2)

# Contacts
![1000000134](https://github.com/user-attachments/assets/7cc5d3c7-ed1e-4802-9694-0db3861f79cc)
![1000000133](https://github.com/user-attachments/assets/62058ca3-7cb2-4699-99dc-72b8c346951a)
![1000000135](https://github.com/user-attachments/assets/8570d29c-bcf6-42e8-9f45-19ede0cc4079)
![1000000137](https://github.com/user-attachments/assets/bf3f4baf-3625-4407-8bbd-9b64c8f91e9a)
![1000000![1000000143](https://github.com/user-attachments/assets/8b576c1c-7381-45aa-96e9-5d7cbe9e3194)
144](https://github.com/user-attachments/assets/6389d8c3-fc05-4b90-b9e9-30b259ff3940)

# Trigger Settings Page

![1000000141](https://github.com/user-attachments/assets/5adb0afc-2acd-480a-8c25-ca2e0004cf96)

![1000000142](https://github.com/user-attachments/assets/f9b7b2b0-4ca1-49b7-9d8f-e8dfe23a254d)

# Safety Page
![1000000140 (2)](https://github.com/user-attachments/assets/af1810d1-1983-472a-8061-c1dec7f6200c)

# Support Chatbot Page

![1000000145](https://github.com/user-attachments/assets/96b3d810-1a6a-4395-9486-625e6e439d93)
![1000000146](https://github.com/user-attachments/assets/f5e6aa43-3209-48e0-98a4-4e038a2694d2)

# Installation

# Flutter Setup

```bash
git clone https://github.com/YOUR_USERNAME/SilentSOS.git
cd SilentSOS
flutter pub get
flutter run
```

# Django Backend

https://github.com/NatchelLebea/silent_sos_backend

```bash
cd backend
python -m venv env
env\Scripts\activate
pip install -r requirements.txt
python manage.py runserver 0.0.0.0:8000
```

# Rasa Chatbot

https://github.com/NatchelLebea/silent_sos_rasabot

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



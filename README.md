# TPG316C — Student Assistant Application System

> Flutter · MVVM · Provider · Supabase

---

## Group Members

|   | Full Name | Student Number |
|---|-----------|----------------|
| 1 | Tshepiso Mofokeng | 224079447 |
| 2 | Ntlahla Dlali | 220039413 |
| 3 | Tshitso Selepe | 224004059 |
| 4 | Odwa Cengimbo| 222068206 |


---

## Quick Start

### Step 1 — Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a free project.
2. Open **SQL Editor → New Query**, paste the contents of `supabase_setup.sql`, and click **Run**.
3. Copy your **Project URL** and **anon public key** from **Settings → API**.

### Step 2 — Configure the App

Edit the `.env` file in the project root:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 3 — Install Dependencies

```bash
flutter pub get
```

### Step 4 — Run the App

```bash
flutter run
```

---

## Setting Up Admin Users

1. In **Supabase Dashboard → Authentication → Users**, find or create the admin user.
2. Click the user → **Edit** → scroll to **Raw user meta data**.
3. Set it to:
   ```json
   { "role": "admin" }
   ```
4. Save. That user will now be routed to the Admin Dashboard on login.

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — Supabase init, Provider setup
├── app.dart                         # MaterialApp + named routes
├── core/
│   ├── constants/
│   │   └── supabase_constants.dart  # Table names, statuses, module data
│   ├── services/
│   │   ├── auth_service.dart        # Supabase auth wrapper
│   │   └── storage_service.dart     # File upload/delete
│   └── theme/
│       └── app_theme.dart           # Colours, typography, component themes
└── features/
    ├── auth/
    │   ├── views/login_screen.dart
    │   └── viewmodels/auth_viewmodel.dart
    ├── student_portal/
    │   ├── models/student_application.dart
    │   ├── views/
    │   │   ├── home_screen.dart
    │   │   ├── application_form_screen.dart
    │   │   ├── application_detail_screen.dart
    │   │   └── widgets/application_status_chip.dart
    │   └── viewmodels/application_viewmodel.dart
    └── admin_portal/
        ├── views/admin_dashboard_screen.dart
        └── viewmodels/admin_viewmodel.dart
```

---

## Architecture: MVVM + Provider

| Layer | Responsibility |
|-------|---------------|
| **Model** | Plain Dart class (`StudentApplication`) — maps to Supabase rows |
| **ViewModel** | Extends `ChangeNotifier` — calls Supabase, holds state, calls `notifyListeners()` |
| **View** | Flutter widgets — calls `context.watch<VM>()` to rebuild, `context.read<VM>()` to call methods |

---

## Features

- ✅ Role-based login (Student → Home, Admin → Dashboard)
- ✅ Student: submit, view, edit, delete own applications
- ✅ Maximum 2 modules enforced on the form
- ✅ Supporting document upload to Supabase Storage
- ✅ Admin: approve / reject / delete any application
- ✅ Admin: filter by status (All / Pending / Approved / Rejected)
- ✅ Pull-to-refresh on all lists
- ✅ Row Level Security — students can only access their own data

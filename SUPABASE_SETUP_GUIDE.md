# 🚀 Panduan Setup Supabase untuk User Registration

## 📋 Daftar Isi
1. [Setup Supabase Project](#setup-supabase-project)
2. [Konfigurasi Authentication](#konfigurasi-authentication)
3. [Setup Database Schema](#setup-database-schema)
4. [Testing Registration](#testing-registration)
5. [Troubleshooting](#troubleshooting)

---

## 1. Setup Supabase Project

### A. Buat Project Baru
1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Klik **"New Project"**
3. Isi detail project:
   - **Name**: `streamline-warehouse` (atau nama lain)
   - **Database Password**: Buat password yang kuat (simpan dengan aman!)
   - **Region**: Pilih yang terdekat dengan lokasi Anda
4. Tunggu ~2 menit sampai project selesai dibuat

### B. Dapatkan API Keys
1. Setelah project dibuat, buka **Settings** ⚙️
2. Pilih **API** di sidebar
3. Copy credentials berikut:
   - **Project URL**: `https://xxxxxxxx.supabase.co`
   - **anon/public key**: Key yang panjang (ini aman untuk public)
   
4. Update file `.env` di root project:
```env
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxxxxxx
GOOGLE_CLIENT_ID=your-google-client-id
```

---

## 2. Konfigurasi Authentication

### A. Enable Email Authentication
1. Di Supabase Dashboard, buka **Authentication** → **Providers**
2. Pastikan **Email** sudah enabled (default: ON)
3. Konfigurasi Email Settings:

#### Option 1: Confirm Email OFF (Untuk Development) ✅ RECOMMENDED
**Gunakan ini untuk testing cepat tanpa verifikasi email**

1. Buka **Authentication** → **Providers** → **Email**
2. **Scroll ke bawah** ke bagian "Email Settings"
3. **MATIKAN** toggle **"Confirm email"**
4. Klik **Save**

**Keuntungan:**
- ✅ User langsung bisa login setelah register
- ✅ Tidak perlu verifikasi email
- ✅ Cocok untuk development/testing

**Catatan:** Untuk production, sebaiknya aktifkan email confirmation!

#### Option 2: Confirm Email ON (Untuk Production)
**Gunakan ini untuk production environment**

1. **Confirm email** tetap ON
2. Setup Email Template di **Authentication** → **Email Templates**
3. Konfigurasi SMTP (pilih salah satu):

**A. Menggunakan Built-in Supabase Email (Limited)**
- Gratis untuk limited emails
- Cocok untuk testing
- Terbatas 4 emails/hour di free tier

**B. Menggunakan Custom SMTP Provider (Recommended)**

Contoh menggunakan Gmail:
```
SMTP Host: smtp.gmail.com
SMTP Port: 587
Username: your-email@gmail.com
Password: app-specific-password (bukan password gmail biasa)
```

Cara buat App Password Gmail:
1. Buka Google Account → Security
2. Enable 2-Step Verification
3. Search "App passwords"
4. Generate password untuk "Mail"
5. Copy password tersebut ke Supabase SMTP settings

**C. Provider SMTP Lain (Alternatif)**
- **SendGrid**: 100 emails/day gratis
- **Mailgun**: 5000 emails/month gratis
- **AWS SES**: Pay per use, murah

### B. Configure Auth Settings
1. Buka **Authentication** → **URL Configuration**
2. Tambahkan URL redirect:
   ```
   Site URL: http://localhost:3000
   Redirect URLs: 
   - com.example.streamline://login-callback
   - http://localhost:3000/**
   ```

3. **Rate Limits** (Optional):
   - Buka **Authentication** → **Rate Limits**
   - Sesuaikan jika perlu (default sudah cukup)

---

## 3. Setup Database Schema

### A. Jalankan SQL Schema
1. Buka **SQL Editor** di Supabase Dashboard
2. Klik **"New query"**
3. Copy-paste isi file `supabase/auth_accounts_schema.sql` dari project Anda
4. Klik **"Run"** atau tekan `Ctrl + Enter`

File ini akan membuat:
- ✅ Table `accounts` untuk profile user
- ✅ Table `activity_logs` untuk audit trail
- ✅ RLS (Row Level Security) policies
- ✅ Triggers untuk auto-create account saat user register
- ✅ Functions untuk log aktivitas

### B. Verify Schema
Setelah run SQL, cek:
1. **Database** → **Tables** → Lihat table `accounts` dan `activity_logs`
2. **Authentication** → Masih kosong (normal, belum ada user)

### C. Optional: Test dengan Sample User
```sql
-- Di SQL Editor, jalankan ini untuk test:
SELECT * FROM auth.users;
SELECT * FROM public.accounts;
```

---

## 4. Testing Registration

### A. Test via Aplikasi Flutter
1. **Build dan Run aplikasi**:
```bash
flutter clean
flutter pub get
flutter run
```

2. **Test Registration Flow**:
   - Buka app → Tap **"Don't have an account? Register"**
   - Isi form:
     - Email: `test@example.com`
     - Password: `password123` (min 6 karakter)
     - Confirm Password: `password123`
   - Tap **"Register"**

3. **Expected Behavior**:

**Jika Confirm Email OFF:**
- ✅ Langsung redirect ke Home Screen
- ✅ Snackbar: "Account created successfully!"
- ✅ User bisa langsung menggunakan app

**Jika Confirm Email ON:**
- ⏳ Muncul snackbar: "Please check your email to verify your account"
- ⏳ User belum bisa login sampai klik link di email
- ⏳ Cek inbox email untuk confirmation link

### B. Verify di Supabase Dashboard
1. Buka **Authentication** → **Users**
2. Lihat user baru dengan email `test@example.com`
3. Check status:
   - **Confirm Email OFF**: Status = `confirmed` ✅
   - **Confirm Email ON**: Status = `unconfirmed` ⏳ (sampai klik email)

4. Buka **Database** → **Table Editor** → `accounts`
5. Lihat profile user baru dengan role `viewer` (default)

### C. Test Login
1. Logout dari app
2. Login dengan credentials yang sama
3. Harus berhasil masuk ke Home Screen

---

## 5. Troubleshooting

### ❌ Error: "Failed to sign up"

**Penyebab 1: Email sudah terdaftar**
```
Solution: Gunakan email berbeda atau hapus user lama di Dashboard
```

**Penyebab 2: Password terlalu lemah**
```
Solution: Gunakan password minimal 6 karakter
```

**Penyebab 3: Network error**
```
Solution: 
- Cek koneksi internet
- Cek SUPABASE_URL di .env sudah benar
- Test: curl https://your-project.supabase.co/rest/v1/
```

### ❌ Error: "Invalid API key"
```
Solution:
1. Cek SUPABASE_ANON_KEY di .env
2. Pastikan tidak ada spasi atau karakter tersembunyi
3. Copy ulang dari Supabase Dashboard → Settings → API
4. Restart app setelah update .env
```

### ❌ Email confirmation tidak terkirim
```
Solution:
1. Cek Email Templates di Authentication → Email Templates
2. Pastikan SMTP configured (jika menggunakan custom SMTP)
3. Cek spam folder
4. Untuk testing, matikan "Confirm email" sementara
```

### ❌ User sudah register tapi tidak bisa login
```
Solution:
1. Cek status user di Dashboard → Authentication → Users
2. Jika status "unconfirmed", ada 2 cara:
   a. Klik link confirmation di email
   b. Manual confirm via Dashboard:
      - Click user → Pilih "Confirm email"
```

### ❌ Error: "Row Level Security policy violation"
```
Solution:
Pastikan SQL schema sudah dijalankan lengkap.
Cek RLS policies di Database → Tables → accounts → Policies
```

### ❌ Profile tidak dibuat otomatis di table accounts
```
Solution:
Cek trigger sudah ada:
1. Database → Functions
2. Lihat function: handle_new_user()
3. Jika tidak ada, jalankan ulang auth_accounts_schema.sql
```

---

## 6. Advanced Configuration (Optional)

### A. Customize User Roles
Edit function di SQL:
```sql
-- Set default role menjadi 'staff' instead of 'viewer'
CREATE OR REPLACE FUNCTION public.handle_new_user()
...
  insert into public.accounts (id, email, role)
  values (new.id, new.email, 'staff'); -- Ganti 'viewer' jadi 'staff'
...
```

### B. Email Templates Customization
1. **Authentication** → **Email Templates** → **Confirm signup**
2. Edit template:
```html
<h2>Welcome to Streamline Warehouse!</h2>
<p>Please confirm your email by clicking the link below:</p>
<a href="{{ .ConfirmationURL }}">Confirm Email</a>
```

### C. Add Additional User Metadata
Saat register, bisa tambahkan metadata:
```dart
// Di auth_service.dart, modifikasi signUpWithEmail:
final response = await _client.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': 'John Doe',
    'phone': '+62812345678',
  },
);
```

---

## 🎉 Selesai!

Konfigurasi Supabase untuk user registration sudah selesai!

### Quick Checklist:
- ✅ Project Supabase dibuat
- ✅ API Keys dikonfigurasi di `.env`
- ✅ Email Authentication enabled
- ✅ Confirm Email setting dikonfigurasi (ON/OFF)
- ✅ Database schema dijalankan
- ✅ Test registration berhasil
- ✅ User bisa login

### Next Steps:
1. Test dengan multiple users
2. Test forgot password flow
3. Implement profile editing
4. Setup Google Sign-In (sudah ada di app)
5. Configure production SMTP untuk email verification

---

## 📚 Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Client](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

**Dibuat:** 24 Desember 2025  
**Status:** ✅ Ready for Development

# Audit Menyeluruh Project Manpro

Tanggal audit: 6 November 2026  
Project mobile: `manpro-mobile`  
Project backend: `manpro-backend`  
Jenis audit: analisis struktur, keamanan, autentikasi, kualitas kode, data integrity, performa, testing, dan maintainability.

## 1. Kesimpulan umum

Project sudah memiliki fondasi fungsional yang cukup lengkap untuk aplikasi produksi: Flutter mobile, Django REST API, JWT authentication, database relasional, beberapa transaksi database, dan pemisahan menu berdasarkan tipe pengguna.

Namun, project belum cukup hardened untuk operasi produksi jangka panjang. Risiko terbesar bukan hanya masa berlaku token, tetapi:

1. Otorisasi backend masih bersifat umum `IsAuthenticated`; belum terlihat pembatasan role/permission yang kuat untuk endpoint admin, master data, upload, dan operasi destructive.
2. Sebagian halaman Flutter masih menggunakan request HTTP langsung sehingga melewati interceptor JWT, auto-refresh token, timeout, dan pola error handling terpusat.
3. Konfigurasi keamanan deployment belum lengkap dan Android masih mengizinkan cleartext traffic.
4. Validasi dan constraint database belum cukup melindungi dari duplikasi atau konflik ketika beberapa operator bekerja bersamaan.
5. Test otomatis sangat minim dan test Flutter yang ada masih berupa test bawaan counter.
6. Banyak file sangat besar dan mencampur UI, network, parsing, validasi, state, serta navigasi dalam satu file sehingga biaya maintenance dan risiko regresi tinggi.

Perubahan login jangka panjang yang telah dikerjakan sebelumnya sudah memperbaiki alur refresh token pada Flutter, tetapi temuan lain dalam laporan ini tetap perlu ditangani secara bertahap.

## 2. Cakupan dan bukti pemeriksaan

Pemeriksaan dilakukan pada:

- Flutter mobile di `/home/androidlinux/PROJECT SPIN/manpro-mobile`.
- Django backend di `/home/androidlinux/PROJECT SPIN/manpro-backend`.
- Konfigurasi dependency, environment, authentication, routing, model, serializer, view, service, page, test, dan konfigurasi Android.
- Static inspection menggunakan pencarian source, review file utama, `flutter analyze`, serta `python manage.py check --deploy`.

Status validasi:

- `flutter analyze`: **lulus**, tidak ada issue analyzer.
- `flutter test`: **gagal**, karena test masih menggunakan test bawaan counter dan `dotenv` belum diinisialisasi; ini bukan kegagalan langsung pada kode refresh token.
- `python manage.py check --deploy`: mengeluarkan 5 warning keamanan deployment, dijelaskan pada bagian konfigurasi keamanan.

Catatan: audit ini bersifat read-only. Tidak ada perubahan source yang dibuat untuk audit ini. Working tree sudah memiliki perubahan dari pekerjaan sebelumnya dan perubahan user.

## 3. Gambaran struktur project

Project terdiri dari dua repository yang sejajar:

```text
/home/androidlinux/PROJECT SPIN/
├── manpro-mobile/                 # Aplikasi Flutter untuk operator, leader, dan admin
└── manpro-backend/                # Backend Django REST API dan database service
```

### 3.1 Struktur utama `manpro-mobile`

```text
manpro-mobile/
├── android/                       # Konfigurasi Android, Gradle, manifest, signing
│   └── app/
├── ios/                           # Konfigurasi iOS dan Runner
├── linux/                         # Runner Flutter Linux
├── macos/                         # Runner Flutter macOS
├── web/                           # Target Flutter Web
├── windows/                       # Runner Flutter Windows
├── assets/                        # Icon, animasi, gambar, dan asset aplikasi
│   ├── icon/
│   └── lottie/
├── lib/                           # Source code utama Flutter
│   ├── config/                    # Konfigurasi aplikasi dan environment
│   ├── model/                     # Model data/domain
│   │   └── master/                # Model master data
│   ├── navigation/                # Routing dan navigasi berbasis session/role
│   ├── page/                      # Halaman dan feature UI
│   │   ├── 001-molding/           # Feature utama proses molding
│   │   │   ├── record_process/    # Pencatatan proses produksi
│   │   │   ├── record_testing/    # Pencatatan testing
│   │   │   ├── report/            # Report dan monitoring
│   │   │   ├── reason_dialog/     # Dialog alasan NG/stop/change
│   │   │   ├── running_grid_view/ # Tampilan proses berjalan berbentuk grid
│   │   │   ├── running_list_view/ # Tampilan proses berjalan berbentuk list
│   │   │   ├── stop_grid_view/    # Tampilan proses stop berbentuk grid
│   │   │   ├── stop_list_view/    # Tampilan proses stop berbentuk list
│   │   │   └── continue_pending_*/# Alur melanjutkan proses pending
│   │   └── operator/              # Form dan alur kerja operator
│   ├── provider/                  # State management dan business orchestration
│   ├── service/                   # API client, auth, storage, dan service layer
│   │   ├── dio_client.dart        # HTTP client terpusat
│   │   ├── auth_service.dart      # Login, refresh, logout
│   │   ├── auth_interceptor.dart  # Intercept 401 dan retry request
│   │   ├── auth_session.dart      # Pemulihan session lokal
│   │   └── token_storage.dart     # Secure storage token
│   ├── utils/                     # Helper dan utility
│   ├── widget/                    # Widget reusable lintas feature
│   ├── main.dart                  # Entry point aplikasi
│   └── page/auth_gate.dart        # Pemeriksaan session saat startup
├── test/                          # Unit/widget/integration test Flutter
├── pubspec.yaml                   # Dependency, asset, dan metadata Flutter
├── analysis_options.yaml          # Aturan analyzer Dart
├── .env.dev/.env.test/.env.prod   # Konfigurasi environment non-secret
└── AUDIT_PROJECT_MANPRO_*.md      # Dokumentasi audit dan roadmap perbaikan
```

### 3.2 Struktur utama `manpro-backend`

```text
manpro-backend/
├── webapp/
│   ├── manage.py                   # Command utama Django
│   ├── .env                        # Environment backend; jangan di-commit
│   ├── api/                        # Django app untuk REST API
│   │   ├── models.py               # Model database dan aturan data
│   │   ├── serializers.py          # Transformasi model <-> JSON
│   │   ├── views.py                # Endpoint dan orchestration request
│   │   ├── urls.py                 # Routing endpoint API
│   │   ├── signals.py              # Event/signal model
│   │   ├── admin.py                # Konfigurasi Django Admin
│   │   ├── tests.py                # Test API
│   │   ├── migrations/             # Riwayat perubahan schema database
│   │   ├── management/             # Custom management command
│   │   └── utils/                  # Helper backend
│   ├── webapp/                     # Konfigurasi project Django
│   │   ├── settings.py             # Database, JWT, DRF, CORS, security
│   │   ├── urls.py                 # Root URL dan Swagger
│   │   ├── asgi.py                 # Entry point ASGI
│   │   ├── wsgi.py                 # Entry point WSGI
│   │   └── templates/              # Template server-side
│   ├── media/                      # File upload; perlu storage dan backup terkontrol
│   │   ├── img/
│   │   └── users/
│   ├── db.sqlite3                  # Database lokal/dev; bukan target production
│   └── TODO.md                     # Catatan pekerjaan backend
├── lib/page/                       # Asset atau page pendukung backend/dev tool
├── requirements.txt                # Dependency Python
└── myvenv/                         # Virtual environment lokal; jangan di-commit
```

### 3.3 Alur komunikasi antar komponen

```text
User/operator
    │
    ▼
Flutter Page / Widget
    │  menggunakan Provider atau Service
    ▼
Repository/Service HTTP
    │  idealnya melalui DioClient + AuthInterceptor
    ▼
Django URL Router
    ▼
DRF View
    ├── Authentication: JWTAuthentication
    ├── Authorization: role/permission  [perlu diperkuat]
    ├── Serializer: validasi dan transformasi data
    └── Model/ORM
         ▼
       Database MySQL/SQLite lokal
```

### 3.4 Area tanggung jawab saat melakukan perbaikan

| Area | Lokasi utama | Fokus perbaikan |
|---|---|---|
| Session/login | `mobile/lib/service`, `mobile/lib/navigation`, `mobile/lib/page/auth_gate.dart` | Refresh token, retry, logout, session restoration |
| API client | `mobile/lib/service` | Semua request memakai client terpusat |
| UI proses molding | `mobile/lib/page/001-molding` | Pecah file besar dan kurangi network logic di widget |
| State management | `mobile/lib/provider` | Loading/error/state transition yang konsisten |
| Data contract | `mobile/lib/model`, `backend/webapp/api/serializers.py` | Validasi request/response dan backward compatibility |
| API/business logic | `backend/webapp/api/views.py` | Pisahkan view, service, permission, dan domain |
| Database | `backend/webapp/api/models.py`, `migrations/` | Constraint, index, status transition, audit trail |
| Security/deployment | `backend/webapp/webapp/settings.py`, `mobile/android` | HTTPS, DEBUG, CORS, signing key, cleartext traffic |
| Testing | `mobile/test`, `backend/webapp/api/tests.py` | Auth, permission, concurrency, business flow |

## 3. Hal yang sudah baik

### Mobile

- Sudah ada `DioClient` terpusat dan interceptor authentication.
- Token disimpan menggunakan secure storage, bukan penyimpanan biasa.
- Alur refresh token, retry request, dan pemulihan session saat startup sudah ditambahkan pada:
  - [auth_interceptor.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/service/auth_interceptor.dart>)
  - [auth_service.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/service/auth_service.dart>)
  - [auth_session.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/service/auth_session.dart>)
  - [auth_gate.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/page/auth_gate.dart>)
- Struktur provider/service sudah menunjukkan usaha memisahkan data access dari UI.

### Backend

- Default DRF authentication menggunakan JWT dan default permission menggunakan `IsAuthenticated` di [settings.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/webapp/settings.py>).
- Access token dikonfigurasi 4 jam dan refresh token 25 hari dengan rotation serta blacklist setelah rotation.
- `SECRET_KEY` diwajibkan melalui environment.
- Banyak operasi database sudah menggunakan transaction.
- Backend menggunakan ORM Django; tidak ditemukan penggunaan raw SQL aktif yang menonjol dalam pemeriksaan ini.
- Sebagian model master sudah memiliki pola soft delete.

## 4. Temuan prioritas P0 — harus ditangani terlebih dahulu

P0 berarti risiko keamanan, kehilangan data, atau kegagalan operasional yang harus diselesaikan sebelum memperluas fitur baru.

### P0.1 — Backend belum memiliki authorization berbasis role yang memadai

Default `IsAuthenticated` hanya memastikan user sudah login. Belum ditemukan custom permission seperti `IsAdminUser`, `BasePermission`, pengecekan group/role, atau object-level permission yang konsisten.

Padahal terdapat endpoint untuk:

- user management;
- change password;
- create/update/delete/restore master data;
- upload SAP;
- mark SAP exported;
- delete record produksi;
- operasi administrasi lainnya.

Contoh routing dapat dilihat pada [api/urls.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/urls.py>). Frontend memang membatasi menu berdasarkan group, tetapi pembatasan frontend bukan security boundary karena endpoint tetap dapat dipanggil langsung.

Risiko:

- User authenticated biasa berpotensi memanggil endpoint admin secara langsung.
- Operator dapat mengakses atau mengubah data di luar kewenangannya.
- Operasi destructive tidak memiliki guard role yang jelas.

Perbaikan:

1. Definisikan role resmi: misalnya `ADMIN`, `LEADER`, `OPERATOR`, dan role lain yang memang diperlukan.
2. Buat custom permission DRF per capability, bukan hanya per halaman.
3. Terapkan permission pada setiap endpoint sensitive.
4. Tambahkan object-level check untuk record berdasarkan area, mesin, line, atau scope user jika diperlukan.
5. Tambahkan integration test untuk kombinasi role x endpoint.

### P0.2 — Request HTTP langsung melewati mekanisme authentication terpusat

Sebagian halaman Flutter menggunakan `http.get` dan `http.post` secara langsung, sehingga tidak melewati interceptor Dio. Dampaknya: request tersebut tidak otomatis memakai refresh token, retry, timeout, dan error handling terpusat.

Contoh yang terhubung dari menu admin:

- [recordrunningmanage.dart:46](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/page/001-molding/recordrunningmanage.dart:46>) melakukan GET tanpa header Authorization.
- [recordrunningmanage.dart:91](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/page/001-molding/recordrunningmanage.dart:91>) mengambil reason list menggunakan HTTP langsung.
- [recordrunningmanage.dart:128](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/page/001-molding/recordrunningmanage.dart:128>) melakukan POST tanpa Bearer token.
- [recordrunningmanage.dart:1205](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/page/001-molding/recordrunningmanage.dart:1205>) melakukan DELETE tanpa mekanisme auth terpusat.
- Pola serupa ditemukan di `recordstopmanage.dart`, `recordrunning.dart`, `record_on_progress.dart`, beberapa halaman report, dan beberapa halaman operator.

Risiko:

- Request gagal ketika backend menegakkan authentication.
- Request tidak mendapatkan access token baru setelah expired.
- Perilaku antar halaman tidak konsisten.
- Error network dan timeout lebih sulit ditangani.

Perbaikan:

1. Migrasikan seluruh request aktif ke `DioClient.instance` atau repository/service terpusat.
2. Hapus atau tandai jelas implementasi HTTP lama yang hanya berada dalam komentar.
3. Tambahkan rule/code review agar request ke API tidak dibuat langsung dari widget.
4. Setelah migrasi, test request 401, refresh, retry, logout, dan network timeout.

### P0.3 — Security hardening deployment belum lengkap

`python manage.py check --deploy` menghasilkan warning:

- `security.W004`: HSTS belum diaktifkan.
- `security.W008`: `SECURE_SSL_REDIRECT` belum aktif.
- `security.W012`: `SESSION_COOKIE_SECURE` belum aktif.
- `security.W016`: `CSRF_COOKIE_SECURE` belum aktif.
- `security.W018`: `DEBUG=True` terdeteksi pada environment yang diperiksa.

Konfigurasi berada di [settings.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/webapp/settings.py>). Jika environment tersebut memang development, warning masih dapat dimengerti, tetapi pipeline production wajib memverifikasi nilai production secara eksplisit.

Di Android juga ditemukan `android:usesCleartextTraffic="true"` pada [AndroidManifest.xml](</home/androidlinux/PROJECT SPIN/manpro-mobile/android/app/src/main/AndroidManifest.xml>).

Perbaikan:

1. Pisahkan konfigurasi development, staging, dan production.
2. Pastikan production memakai HTTPS dan `DEBUG=False`.
3. Aktifkan HSTS setelah HTTPS benar-benar siap.
4. Aktifkan secure cookie untuk deployment yang menggunakan cookie.
5. Ubah `usesCleartextTraffic` menjadi `false`, kecuali ada kebutuhan internal yang terdokumentasi dan dibatasi melalui network security config.
6. Tambahkan deployment smoke check yang gagal jika production masih DEBUG atau memakai HTTP.

### P0.4 — Informasi internal dan data request masih dapat bocor ke log/response

Pada mobile, [dio_client.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/lib/service/dio_client.dart>) memasang `LogInterceptor` dengan request body dan response body secara unconditional. Ini berisiko mencatat data bisnis pada release build.

Pada backend ditemukan beberapa pola berisiko:

- `print()` dalam jumlah besar.
- [views.py:3163](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/views.py:3163>) mencetak raw request data untuk operasi PATCH.
- [views.py:7443](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/views.py:7443>) mengembalikan traceback ke client.
- Banyak endpoint mengembalikan `str(e)` langsung sebagai response.

Risiko:

- Token, data operator, data produksi, atau payload bisnis masuk log.
- Path filesystem, struktur kode, dan detail database dapat terbuka kepada client.
- Log production sulit dikontrol dan sulit diaudit.

Perbaikan:

1. Aktifkan HTTP logging hanya pada debug atau environment lokal.
2. Redact `Authorization`, token, password, dan data sensitif.
3. Ganti `print()` dengan structured logger.
4. Kembalikan pesan error generik ke client dan simpan detail hanya di server.
5. Buat correlation/request ID untuk pelacakan tanpa membuka data sensitif.

### P0.5 — Test authentication dan authorization belum memadai

Mobile hanya memiliki satu [widget_test.dart](</home/androidlinux/PROJECT SPIN/manpro-mobile/test/widget_test.dart>) yang masih menguji counter bawaan. Test tersebut gagal karena aplikasi membutuhkan initialization dotenv dan tidak lagi memiliki widget counter.

Backend hanya memiliki test yang sangat sedikit di [api/tests.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/tests.py>). Test menggunakan `APITestCase`, tetapi belum terlihat setup authentication dan coverage role/permission yang memadai, padahal default permission backend adalah `IsAuthenticated`.

Perbaikan minimum:

- test login berhasil dan gagal;
- test access token expired lalu refresh;
- test refresh token invalid/blacklisted;
- test retry request setelah refresh;
- test session restoration saat aplikasi dibuka ulang;
- test akses operator ke endpoint admin harus 403;
- test akses admin ke endpoint admin;
- test upload, delete, restore, dan change password;
- test concurrency/duplikasi record produksi;
- test error response tidak mengandung traceback.

## 5. Temuan prioritas P1 — penting setelah P0

### P1.1 — Risiko race condition pada ID dan duplikasi job

`RecordProses.generate_id()` di [models.py:585](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/models.py:585>) menggunakan jumlah record hari itu lalu menambahkan angka 1. Dua request bersamaan dapat memperoleh kandidat ID yang sama sebelum salah satunya commit.

Selain itu, `RecordProsesDetail.jobnumber` belum terlihat memiliki unique constraint database. Pemeriksaan existing record di view saja tidak cukup untuk mencegah duplikasi dalam kondisi concurrent.

Perbaikan:

- Gunakan UUID atau database sequence untuk primary key internal.
- Jika ID bisnis harus berformat tertentu, gunakan sequence/counter atomik dan unique constraint.
- Tambahkan constraint unik sesuai aturan bisnis untuk `jobnumber` dan kombinasi field terkait.
- Tangani `IntegrityError` dengan response yang aman dan dapat dipahami user.
- Tambahkan test concurrent create.

### P1.2 — Validasi status dan kuantitas belum cukup kuat di level database

Beberapa status disimpan sebagai `CharField` biasa tanpa choices/check constraint yang kuat. `RecordNg.qty` juga belum terlihat memiliki validasi positif yang memadai di database.

Risiko:

- Nilai status typo atau status tidak dikenal masuk ke database.
- Kuantitas negatif atau tidak valid merusak laporan.
- State transition dapat dilompati oleh request langsung.

Perbaikan:

- Definisikan enum/choices untuk status.
- Tambahkan database check constraint.
- Validasi transition, misalnya `RUNNING -> STOPPED -> FINISHED`, di service layer.
- Validasi qty sebagai bilangan non-negatif dan tetapkan aturan maksimal jika ada.
- Tambahkan audit trail untuk perubahan status penting.

### P1.3 — Penghapusan record produksi masih hard delete

Endpoint [views.py:7535](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/views.py:7535>) memanggil `record.delete()`. Untuk data produksi, hard delete berisiko menghilangkan jejak operasional dan menyulitkan audit.

Perbaikan:

- Gunakan soft delete untuk record operasional jika sesuai aturan bisnis.
- Simpan siapa, kapan, dan alasan penghapusan.
- Batasi hard delete hanya untuk prosedur maintenance dengan role khusus.
- Pastikan laporan default tidak menampilkan record yang di-soft-delete.

### P1.4 — Backend terlalu besar dan memiliki definisi duplikat/legacy code

Ukuran file utama:

- [views.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/views.py>): sekitar 10.511 baris.
- [serializers.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/serializers.py>): sekitar 3.562 baris.
- [models.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/api/models.py>): sekitar 1.230 baris.

Ditemukan definisi berulang, antara lain:

- `get_active_testing_records` muncul lebih dari sekali di `views.py`.
- `StandardResultsSetPagination` muncul lebih dari sekali.
- `RecordProcessDetailSerializer` muncul lebih dari sekali di `serializers.py`.
- Banyak blok kode lama dikomentari.

Risiko:

- Definisi terakhir dapat diam-diam menimpa definisi sebelumnya.
- Perbaikan pada satu blok belum tentu memengaruhi kode aktif.
- Review dan onboarding developer menjadi sulit.

Perbaikan bertahap:

1. Pisahkan views berdasarkan domain: auth, master, record process, testing, report, SAP.
2. Pisahkan serializer dan service berdasarkan domain.
3. Pindahkan business logic dari view ke service/use-case.
4. Hapus dead code setelah diverifikasi melalui test dan git history.
5. Terapkan linting, formatting, import sorting, dan aturan duplicate detection.

### P1.5 — Pagination dan query perlu diuji pada volume produksi

Beberapa endpoint melakukan serialisasi seluruh hasil lalu melakukan pagination terhadap list di memory. Pola ini terlihat di beberapa bagian `views.py`, termasuk area report.

Risiko:

- Memory backend meningkat seiring data produksi bertambah.
- Response report melambat.
- Beban database dan CPU meningkat.

Perbaikan:

- Paginate `QuerySet` sebelum serialisasi.
- Gunakan `select_related` dan `prefetch_related` berdasarkan profiling.
- Tambahkan index untuk field filter dan sort yang sering dipakai: status, job number, ID proses, waktu, dan soft-delete flag.
- Whitelist parameter `order_by`; jangan menerima field sort arbitrary tanpa validasi.
- Uji endpoint dengan dataset yang mendekati produksi.

### P1.6 — Rate limiting dan abuse protection untuk auth/upload

Belum terlihat rate limiting yang memadai untuk login, refresh, change password, dan upload file.

Perbaikan:

- Terapkan throttle login berdasarkan IP dan identifier user.
- Tambahkan lockout/backoff setelah kegagalan berulang.
- Batasi ukuran dan frekuensi upload.
- Validasi MIME, extension, ukuran, dan isi file.
- Tambahkan audit log untuk login gagal, logout, password change, upload, dan delete.

### P1.7 — Zona waktu perlu diseragamkan

Backend menggunakan `TIME_ZONE = "Asia/Tokyo"` di [settings.py](</home/androidlinux/PROJECT SPIN/manpro-backend/webapp/webapp/settings.py>), sedangkan konteks operasional project berada di Indonesia dan logger mobile menyebut JST pada beberapa bagian.

Risiko:

- Pergantian hari produksi salah.
- Filter laporan harian tidak sesuai tanggal operator.
- ID harian dan timestamp audit dapat bergeser.

Perbaikan:

- Tetapkan timezone bisnis secara eksplisit, misalnya `Asia/Jakarta` jika itu aturan operasional.
- Simpan timestamp dalam UTC bila memungkinkan.
- Konversi ke timezone pabrik hanya pada tampilan dan aturan bisnis yang memang membutuhkan local time.
- Tambahkan test sekitar pergantian hari.

## 6. Temuan prioritas P2 — kualitas dan maintainability

### P2.1 — File Flutter terlalu besar dan tanggung jawab bercampur

Beberapa file sangat besar, misalnya:

- `recordrunning.dart` sekitar 4.108 baris.
- `detailrecordfinish.dart` sekitar 3.864 baris.
- `record_completed.dart` sekitar 3.688 baris.
- `operator/measurementform.dart` sekitar 2.926 baris.
- `operator/onejoborder.dart` sekitar 3.149 baris.
- `operator/inspectionform.dart` sekitar 2.453 baris.

UI, request API, parsing, state, validasi, dan navigasi masih bercampur dalam beberapa halaman.

Perbaikan:

- Pecah halaman berdasarkan feature/domain.
- Gunakan repository untuk komunikasi API.
- Gunakan controller/notifier/view model untuk state dan orchestration.
- Jadikan widget presentational sebisa mungkin.
- Buat model request/response khusus, jangan parsing map bebas di widget.

### P2.2 — Potensi `setState` setelah asynchronous operation

Ditemukan banyak pola `await` lalu `setState` pada halaman dan dialog. Tidak semuanya pasti bug karena beberapa mungkin sudah memiliki guard, tetapi pola ini perlu direview sistematis dengan `mounted`/`context.mounted`.

Area yang perlu diprioritaskan antara lain:

- `record_on_progress.dart`.
- `recordrunning.dart`.
- `operator/inspectionform.dart`.
- `operator/measurementform.dart`.
- `operator/onejoborder.dart`.
- halaman report dan dialog yang memuat data asynchronous.

Risiko:

- Exception ketika user meninggalkan halaman saat request berjalan.
- Dialog atau snackbar dipanggil menggunakan context yang sudah tidak valid.
- State lama menimpa state halaman baru.

### P2.3 — Logging mobile perlu dibatasi berdasarkan build mode

`AppLogger` sudah membatasi sebagian logging pada debug, tetapi `LogInterceptor` Dio masih aktif unconditional. Pastikan release build tidak mencatat body request/response dan tidak menampilkan token.

Tambahkan juga aturan bahwa password, access token, refresh token, dan data produksi tidak boleh masuk log.

### P2.4 — Environment dan signing key perlu dijaga ketat

File environment dimasukkan sebagai asset di [pubspec.yaml](</home/androidlinux/PROJECT SPIN/manpro-mobile/pubspec.yaml>). Saat ini key yang terlihat hanya konfigurasi URL/environment, tetapi prinsipnya tetap: jangan memasukkan secret ke asset mobile karena isi APK dapat diekstrak.

Workspace juga memiliki file signing seperti `android/app/manpro-release.jks`, `android/manpro-release.jks`, dan `android/key.properties`. Hasil pemeriksaan git tidak menunjukkan kandidat tersebut sedang tracked, tetapi cakupan `.gitignore` harus dipastikan melindungi seluruh lokasi key.

Perbaikan:

- Simpan signing key di secret manager/CI, bukan repository.
- Pastikan semua `.jks`, `key.properties`, dan environment secret di-ignore.
- Audit git history bila pernah ada key yang ter-commit.
- Bedakan base URL dev, staging, dan production pada pipeline build.

### P2.5 — Dokumentasi dan pipeline quality gate belum cukup

README mobile masih bersifat template/general. Backend belum terlihat memiliki dokumentasi deployment yang lengkap, dan belum terlihat konfigurasi lint/test gate seperti `pyproject.toml`, `pytest`, `tox`, `pre-commit`, atau Makefile.

Perbaikan:

- Dokumentasikan arsitektur, role matrix, API convention, state transition, dan cara release.
- Tambahkan CI untuk `flutter analyze`, `flutter test`, backend test, migration check, lint, dan security check.
- Gunakan staging environment sebelum production.
- Tambahkan checklist release dan rollback.

## 7. Roadmap perbaikan yang disarankan

### Sprint 1 — keamanan dan stabilitas dasar

1. Terapkan role/permission backend untuk seluruh endpoint sensitive.
2. Migrasikan request HTTP langsung pada halaman aktif ke Dio/repository.
3. Matikan body logging pada release build.
4. Hilangkan traceback, raw exception, dan raw request logging dari response/log production.
5. Pastikan production `DEBUG=False`, HTTPS, HSTS, dan Android cleartext disabled.
6. Perbaiki test harness mobile dan backend.

### Sprint 2 — integritas data produksi

1. Tambahkan unique constraint dan strategi ID atomik.
2. Validasi status transition dan kuantitas.
3. Ubah delete record produksi menjadi soft delete/audited delete.
4. Tambahkan audit log untuk aksi sensitif.
5. Tambahkan test concurrency dan role matrix.

### Sprint 3 — performa dan operasional

1. Perbaiki pagination agar terjadi di database sebelum serialisasi.
2. Profiling query report dan tambahkan index berdasarkan data nyata.
3. Tambahkan throttle login/upload.
4. Seragamkan timezone.
5. Tambahkan monitoring error, request ID, health check yang aman, dan alert.

### Sprint 4 — refactoring maintainability

1. Pecah `views.py`, `serializers.py`, dan halaman Flutter besar berdasarkan domain.
2. Hapus duplicate definition dan commented legacy code setelah coverage tersedia.
3. Pisahkan UI, state, repository, dan model.
4. Tambahkan CI quality gate dan dokumentasi release.

## 8. Matriks prioritas ringkas

| Prioritas | Temuan | Dampak | Target |
|---|---|---|---|
| P0 | Authorization role backend | Akses data/aksi tidak sah | Segera |
| P0 | HTTP langsung melewati auth interceptor | Token expired, request gagal, perilaku tidak konsisten | Segera |
| P0 | Production security config | Risiko transport dan konfigurasi terbuka | Sebelum production |
| P0 | Traceback/raw payload/log sensitif | Kebocoran informasi | Segera |
| P0 | Test auth/permission minim | Regresi sulit terdeteksi | Segera |
| P1 | Race condition ID/duplikasi | Data produksi bentrok | Setelah P0 |
| P1 | Hard delete dan state bebas | Kehilangan/audit data lemah | Setelah P0 |
| P1 | Query dan pagination skala besar | Performa menurun saat data tumbuh | Setelah P0 |
| P1 | Throttle dan upload protection | Abuse/brute force/resource exhaustion | Setelah P0 |
| P1 | Timezone tidak seragam | Laporan dan ID harian bergeser | Setelah P0 |
| P2 | File besar/duplicate code | Maintenance mahal | Bertahap |
| P2 | Async lifecycle | Crash/intermittent UI error | Bertahap |
| P2 | Dokumentasi/CI | Release tidak konsisten | Bertahap |

## 9. Rekomendasi titik mulai

Urutan paling aman untuk mulai perbaikan:

1. Buat permission matrix endpoint backend.
2. Implementasikan permission backend dan test 401/403.
3. Inventarisasi seluruh request langsung dari widget dan migrasikan ke repository/Dio.
4. Tambahkan test login-refresh-retry-logout.
5. Hardening configuration production.
6. Tambahkan constraint data dan audit trail.

Jangan memulai refactor besar sebelum test permission dan alur record utama tersedia. Dengan begitu, pemecahan file besar dapat dilakukan bertahap tanpa kehilangan perilaku bisnis yang sudah berjalan.


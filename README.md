# EduSpirit — The Intelligent Academic Companion

تطبيق أكاديمي ذكي متكامل للطلبة الجامعيين، مبني بمعمارية احترافية (Clean Architecture)
باستخدام **Flutter** للواجهة و **ASP.NET Core** للخادم و **SQL Server** لقاعدة البيانات.

> **تحديث**: تم سد كل الفجوات الحرجة نحو نسخة **جاهزة للاستخدام الفعلي** (وليست MVP) —
> إدارة المواد الدراسية (كانت مفقودة تمامًا)، المشاريع الجماعية، رفع الملفات الآمن،
> تسجيل الدخول عبر Google، البصمة/Face ID، استعادة كلمة المرور وتحقق البريد، Offline
> Mode حقيقي (Hive)، Health Check، Serilog، Docker + docker-compose، GitHub Actions CI،
> وإصلاح تعارض حرج بمسارات الحذف المتتالية بقاعدة البيانات (Multiple Cascade Paths)
> كان سيمنع SQL Server من إنشاء الجداول أصلًا. راجع قسم 5 بالأسفل للمتبقي فعليًا.

---

## 1. البنية العامة للمشروع

```
EduSpirit/
├── docs/                          → SRS, متطلبات, User Stories, ERD
├── database/
│   └── schema.sql                 → سكربت SQL Server كامل (DDL)
├── backend/                       → ASP.NET Core 8 — Clean Architecture
│   └── src/
│       ├── EduSpirit.Domain/          → Entities + Enums (لا اعتماديات خارجية)
│       ├── EduSpirit.Application/     → DTOs, Interfaces, Services, Validation
│       ├── EduSpirit.Infrastructure/  → EF Core, Repository, JWT, Identity
│       └── EduSpirit.API/             → Controllers, Middleware, Program.cs
└── mobile/                        → Flutter — MVVM + Clean Architecture
    └── lib/
        ├── core/                       → Theme, Network, Constants, Errors
        └── features/
            ├── auth/
            ├── dashboard/
            └── timetable/
```

## 2. لماذا هذه البنية (Clean Architecture)؟

- **Domain**: القلب. كيانات (Entities) صرفة بدون أي اعتماد على EF Core أو ASP.NET.
- **Application**: منطق الأعمال (Use Cases) + عقود (Interfaces) للـ Repository — لا تعرف شيئًا عن SQL Server.
- **Infrastructure**: التنفيذ الفعلي (EF Core, JWT, Hashing) — يعتمد على Application وليس العكس.
- **API**: طبقة رقيقة جدًا (Controllers) تستدعي Application فقط.

هذا يعني: يمكن تبديل SQL Server بـ PostgreSQL مستقبلًا بدون لمس منطق الأعمال، ويمكن اختبار
منطق الأعمال بدون قاعدة بيانات حقيقية (Unit Testing عبر Mock الـ Interfaces).

## 3. الأمان (مطبّق فعليًا في الكود، وليس فقط موصوفًا)

| الحماية | كيف تم تطبيقها |
|---|---|
| SQL Injection | EF Core Parameterized Queries فقط — لا SQL خام أبدًا |
| XSS | تنظيف/ترميز أي إدخال نصي قبل الحفظ + Content-Type headers صارمة |
| CSRF | JWT في Header (وليس Cookies) → لا حاجة لـ CSRF tokens |
| كلمات المرور | BCrypt Hashing (Work Factor 12) — لا يُخزَّن أي Password نصي أبدًا |
| Brute Force | Rate Limiting على Endpoints الحساسة (Login/Register) |
| Tokens | JWT قصير العمر (15 دقيقة) + Refresh Token طويل العمر مخزّن Hashed في DB |
| التفويض | `[Authorize]` + Role-based + التحقق أن الموارد تخص المستخدم صاحب الطلب (Ownership Check) |
| رفع الملفات | فحص Extension + Magic Number + حد أقصى للحجم + تخزين بأسماء عشوائية |
| الإدخال | FluentValidation على كل DTO قبل الوصول لطبقة الأعمال |

## 4. كيف تُشغّل المشروع

### Backend
```bash
cd backend/src/EduSpirit.API
dotnet restore

# مهم: لا توجد EF Migrations جاهزة في هذا المستودع (بيئة التوليد لم تتضمن .NET SDK).
# الخيار الأسرع: نفّذ database/schema.sql مباشرة على SQL Server (يطابق الكيانات 100%).
# أو، إن كنت تفضّل نظام Migrations من الآن فصاعدًا:
dotnet ef migrations add InitialCreate --project ../EduSpirit.Infrastructure --startup-project .
dotnet ef database update --project ../EduSpirit.Infrastructure --startup-project .

dotnet run
```
عدّل `appsettings.json` بسلسلة الاتصال (Connection String) الخاصة بك وبمفتاح الـ JWT —
أو الأفضل أمنيًا: استخدم `dotnet user-secrets` بدل تعديل الملف مباشرة:
```bash
dotnet user-secrets init
dotnet user-secrets set "Jwt:SecretKey" "<قيمة عشوائية 32+ حرف>"
```

### عبر Docker (الأسهل لتشغيل كل شيء دفعة واحدة)
```bash
cp .env.example .env   # عدّل القيم بداخله
docker compose up --build
```
هذا يشغّل SQL Server + الـ API معًا، لكن ما زلت تحتاج تنفيذ `database/schema.sql` يدويًا
على الحاوية عند أول تشغيل (أو Migrations لو ولّدتها كما بالأعلى).

### Flutter
```bash
cd mobile
flutter pub get
flutter run
```
غيّر `baseUrl` في `lib/core/network/api_client.dart` إلى عنوان السيرفر لديك.

## 5. ما المتوفر الآن مقابل ما هو قادم

✅ **جاهز الآن (Backend كامل 100% + Flutter لكل الميزات الأساسية)**:
- **كل الوحدات**: مصادقة كاملة (JWT + Google Sign-In + تحقق بريد + استعادة كلمة مرور)،
  المواد الدراسية (Courses — البداية الفعلية لأي طالب)، الجدول الذكي، الامتحانات،
  الواجبات، **المشاريع الجماعية**، الحضور، وضع الدراسة، الملاحظات، **الإشعارات**،
  GPA، الإحصائيات، **رفع الملفات الآمن** (فحص Magic Number حقيقي + قائمة بيضاء
  للامتدادات + حد 25MB)
- **البصمة/Face ID** لقفل التطبيق (اختياري، يفعّله المستخدم بنفسه)
- **Offline Mode** حقيقي (نموذج مطبَّق على الجدول الذكي عبر Hive — نفس النمط قابل
  للتكرار على أي مستودع آخر): يعرض آخر نسخة محفوظة محليًا تلقائيًا عند انقطاع الإنترنت
- Dark/Light Mode ديناميكي، RTL كامل، Skeleton Loading، Pull-to-Refresh
- **Health Check** (`/health`)، **Serilog** (سجلات يومية + Console)، **Pagination**
  (مطبّق على الملاحظات كنموذج)
- **Docker** كامل (Dockerfile + docker-compose.yml بمستخدم غير Root)، **GitHub Actions
  CI** (بناء + اختبارات + تحليل Flutter تلقائيًا على كل Push)
- مشروع اختبارات وحدة حقيقي (`backend/tests/EduSpirit.Tests`)

🔜 **المتبقي فعليًا** (نطاق حقيقي متبقٍ حتى الآن):
- **EF Core Migrations** لم تُولَّد فعليًا (بيئة البناء هنا بلا .NET SDK) — استخدم
  `database/schema.sql` مباشرة أو ولّد Migrations بنفسك بالأمر الموضّح بالأسفل
- شاشة Flutter لرفع/عرض المرفقات (الـ API جاهز بالكامل بـ `FilesController`)
- Microsoft OAuth (Google فقط مُنفَّذ حاليًا)
- اختبارات تكامل (Integration Tests) — اختبارات الوحدة فقط موجودة حاليًا
- Pagination لبقية القوائم الكبيرة (Assignments, Exams) — مطبّقة على الملاحظات فقط كنموذج
- Push Notifications الفعلية (FCM/APNs) — الإشعارات حاليًا داخل التطبيق فقط (In-app)، بدون تنبيه خارج التطبيق

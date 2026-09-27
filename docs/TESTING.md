# EduSpirit — استراتيجية الاختبار (Testing Strategy)

## 1. هرم الاختبار المعتمد

```
        ▲  E2E (قليلة)          — تدفقات كاملة على جهاز حقيقي/محاكي
       ╱ ╲ Integration (متوسطة) — API + قاعدة بيانات حقيقية (Testcontainers)
      ╱   ╲ Unit (كثيرة جدًا)   — منطق الأعمال بمعزل عن أي بنية تحتية
     ╱─────╲
```

القاعدة: كل منطق أعمال حساس (حساب GPA، كشف تعارض الجدول، حساب نسبة الحضور، تدفق
المصادقة) **يجب** أن يُغطّى باختبار وحدة قبل أن يُعتبر "منتهيًا" — وهذا مطبّق فعليًا
في `backend/tests/EduSpirit.Tests` (وليس فقط موصوفًا هنا).

## 2. اختبارات الوحدة (Unit Tests) — Backend

**المكان**: `backend/tests/EduSpirit.Tests` (xUnit + Moq + FluentAssertions)

كل خدمة في `EduSpirit.Application.Services` تُختبر بمعزل تام عن EF Core/SQL Server
عبر Mock لـ `IUnitOfWork`/`IGenericRepository<T>` — بحيث تُشغَّل الاختبارات في أقل
من ثانية واحدة بدون أي قاعدة بيانات حقيقية.

**أمثلة مطبّقة فعليًا** (راجع الملفات):
- `AuthServiceTests`: يرفض التسجيل ببريد مكرر (409)، يرفض تسجيل الدخول بكلمة مرور
  خاطئة برسالة عامة لا تكشف وجود الحساب من عدمه، يعيد Tokens صحيحة عند نجاح الدخول.
- `TimetableServiceTests`: يكشف تعارض المواعيد، يرفض وقت نهاية قبل وقت البداية.
- `GpaServiceTests`: يتحقق من صحة معادلة GPA المرجّح بالساعات المعتمدة رياضيًا.

**تشغيلها**:
```bash
cd backend/tests/EduSpirit.Tests
dotnet test
```

**الأولوية القادمة لتوسيع التغطية**: AssignmentService (تحديث التقدّم)،
AttendanceService (حساب النسبة مع حالة "متأخر" = نصف حضور)، NoteService (البحث).

## 3. اختبارات التكامل (Integration Tests) — Backend

تُبنى لاحقًا في `backend/tests/EduSpirit.IntegrationTests` باستخدام:
- `WebApplicationFactory<Program>` لتشغيل الـ API كاملًا في الذاكرة.
- **Testcontainers for .NET** لتشغيل SQL Server حقيقي في Docker أثناء الاختبار
  فقط (وليس قاعدة In-Memory وهمية — لأن سلوك SQL Server الحقيقي في الـ
  Constraints/Indexes يختلف أحيانًا عن الـ Providers الوهمية).

**سيناريوهات أساسية مخطط لها**:
- تسجيل → تسجيل دخول → طلب محمي بالتوكن → تحديث Access Token عبر Refresh.
- إنشاء محاضرتين متعارضتين عبر HTTP فعليًا → التأكد من استجابة 409.
- محاولة حذف/تعديل مورد يخص مستخدمًا آخر → التأكد من استجابة 403 (Ownership Check).

## 4. اختبارات الواجهة (Flutter)

- **Widget Tests**: لكل شاشة رئيسية (Login, Dashboard, Assignments) — التحقق من
  ظهور الحالات الثلاث: تحميل (Skeleton)، نجاح (بيانات)، خطأ (رسالة + إعادة محاولة).
- **Golden Tests**: للتأكد أن الثيم الفاتح/الداكن يُطبَّق بصريًا كما هو متوقع دون
  رجعة بصرية (Visual Regression) عند أي تعديل مستقبلي على `AppTheme`.
- **Mock للـ ApiClient**: عبر حقن `Dio` بـ `MockAdapter` (حزمة `http_mock_adapter`)
  بدل الاتصال الحقيقي، بنفس فلسفة الـ Mock في اختبارات الـ Backend.

## 5. اختبارات الأمان (Security Testing)

يُشغَّل قبل كل إصدار (Release):
- **Dependency Scanning**: `dotnet list package --vulnerable` + `flutter pub outdated`.
- **Static Analysis**: تفعيل `<AnalysisLevel>latest</AnalysisLevel>` في csproj +
  `flutter analyze` بصرامة (fail on warning في CI).
- **فحص يدوي دوري** لقائمة OWASP API Top 10 (خاصة BOLA/Broken Object Level
  Authorization — وهو بالضبط ما تختبره Ownership Checks في الخدمات أعلاه).

## 6. معايير القبول (Definition of Done) لأي ميزة جديدة

ميزة جديدة لا تُعتبر منتهية إلا إذا:
1. لها اختبار وحدة واحد على الأقل لكل قاعدة عمل (Business Rule) فيها.
2. Endpoint الخاص بها محمي بـ `[Authorize]` ما لم يكن عامًا صراحة.
3. أي عملية تعديل/حذف تتحقق من ملكية المورد (Ownership Check) قبل التنفيذ.
4. رسائل الخطأ عربية واضحة ولا تكشف تفاصيل تقنية داخلية (Stack Trace, أسماء جداول).

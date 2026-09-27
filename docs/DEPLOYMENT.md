# EduSpirit — خطة النشر (Deployment Plan)

## 1. البيئات (Environments)

| البيئة | الغرض | قاعدة البيانات |
|---|---|---|
| Development | تطوير محلي | SQL Server محلي أو Docker |
| Staging | اختبار قبل الإصدار، يستخدمه فريق QA | نسخة منفصلة على Azure/AWS |
| Production | المستخدمون الفعليون | نسخة مُدارة (Azure SQL / AWS RDS) بنسخ احتياطي تلقائي يومي |

كل بيئة لها `appsettings.{Environment}.json` منفصل + JWT Secret مختلف تمامًا —
**لا يُشارَك أبدًا** نفس مفتاح الأمان بين Staging و Production.

## 2. Backend — الاستضافة

**الخيار الموصى به**: حاوية Docker واحدة للـ API خلف Reverse Proxy (Nginx/YARP) +
قاعدة بيانات مُدارة منفصلة (وليس على نفس السيرفر) لسهولة القياس أفقيًا لاحقًا.

```dockerfile
# backend/src/EduSpirit.API/Dockerfile (مثال)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish EduSpirit.API/EduSpirit.API.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENTRYPOINT ["dotnet", "EduSpirit.API.dll"]
```

**الأسرار (Secrets)**: عبر متغيرات بيئة (`Jwt__SecretKey`, `ConnectionStrings__DefaultConnection`)
أو خدمة أسرار مُدارة (Azure Key Vault / AWS Secrets Manager) — **ليس** داخل
`appsettings.json` المرفوع لـ Git أبدًا. أضف `appsettings.Production.json` إلى
`.gitignore` إن احتوى قيمًا حقيقية.

## 3. قاعدة البيانات — الترحيل (Migrations)

```bash
# توليد Migration جديد بعد أي تعديل على الكيانات
dotnet ef migrations add <MigrationName> --project EduSpirit.Infrastructure --startup-project EduSpirit.API

# تطبيقه على قاعدة الإنتاج (يُشغَّل كخطوة منفصلة قبل نشر نسخة API الجديدة)
dotnet ef database update --project EduSpirit.Infrastructure --startup-project EduSpirit.API
```

قاعدة صارمة: **لا يُشغَّل** `dotnet ef database update` تلقائيًا من داخل `Program.cs`
في الإنتاج — يُنفَّذ كخطوة CI/CD منفصلة ومُراجَعة، لتفادي فقدان بيانات عن طريق الخطأ.

## 4. Flutter — التوزيع

| المنصة | الأداة | ملاحظات |
|---|---|---|
| Android | `flutter build appbundle --release` | التوقيع عبر Keystore محفوظ في CI Secrets |
| iOS | `flutter build ipa --release` | يتطلب حساب Apple Developer + Certificates عبر Fastlane |

**إدارة الإصدارات**: `pubspec.yaml` → `version: 1.0.0+1` (رقم أمام + يزيد لكل رفعة
لنفس المتجر). التوزيع التجريبي قبل النشر العام عبر Firebase App Distribution
(Android) و TestFlight (iOS).

## 5. خط CI/CD المقترح (GitHub Actions)

```
Push/PR → 
  1) Backend: dotnet restore → dotnet build → dotnet test (يفشل الـ Pipeline لو رسب أي اختبار)
  2) Flutter: flutter pub get → flutter analyze → flutter test
  3) (فرع main فقط) بناء صورة Docker للـ API → رفعها لـ Container Registry
  4) (فرع main فقط) نشر تلقائي لبيئة Staging → موافقة يدوية → نشر Production
```

هذا يضمن أن أي كود يصل لـ `main` قد اجتاز الاختبارات فعليًا (راجع `docs/TESTING.md`)
وليس فقط "يُفترض أنه يعمل".

## 6. المراقبة بعد الإطلاق (Observability)

- **Logging**: Serilog (مُهيَّأ بالفعل في `EduSpirit.API.csproj`) → يُوجَّه لاحقًا
  لخدمة تجميع سجلات (Seq / Application Insights / CloudWatch).
- **Health Check**: إضافة `/health` endpoint (ASP.NET Core Health Checks) يراقبه
  الـ Load Balancer لإعادة تشغيل الحاوية تلقائيًا عند تعطّل الاتصال بقاعدة البيانات.
- **تنبيهات**: على معدل أخطاء 5xx غير طبيعي، وعلى فشل الـ Health Check لأكثر من دقيقتين.

## 7. خطة التراجع (Rollback)

لأن الصور (Images) مُصدّرة برقم إصدار ثابت (Tag)، التراجع هو ببساطة إعادة نشر
الصورة السابقة. **قاعدة البيانات**: لا نكتب Migrations تحذف أعمدة/جداول مباشرة —
بل نُبقي العمود القديم لإصدار واحد على الأقل (Expand-Contract Pattern) حتى نتأكد
أن لا حاجة للتراجع قبل حذفه فعليًا في Migration لاحق منفصل.

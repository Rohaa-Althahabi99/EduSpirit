# EduSpirit API — Phase 1 Endpoints

Base URL: `https://<your-server>/api/v1`

جميع الطلبات (عدا `/auth/*`) تتطلب Header:
```
Authorization: Bearer <accessToken>
```

## Auth

| Method | Endpoint | Body | ملاحظات |
|---|---|---|---|
| POST | `/auth/register` | `{ fullName, email, password }` | Rate-limited: 10/دقيقة |
| POST | `/auth/login` | `{ email, password }` | نفس رسالة الخطأ لبريد غير موجود/كلمة مرور خاطئة |
| POST | `/auth/refresh` | `{ refreshToken }` | يُبطل التوكن القديم فورًا (Rotation) |
| POST | `/auth/logout` | `{ refreshToken }` | يتطلب تسجيل دخول |

**استجابة تسجيل الدخول/التسجيل:**
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "accessTokenExpiresAt": "2026-07-19T12:15:00Z",
  "user": { "id": "...", "fullName": "...", "email": "...", "university": null, "major": null, "avatarUrl": null, "themePreference": "system" }
}
```

## Timetable

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/timetable/today` | حصص اليوم الحالي مرتبة بالوقت |
| GET | `/timetable/weekly` | كل الحصص المتكررة مرتبة باليوم ثم الوقت |
| POST | `/timetable` | ينشئ حصة جديدة — يرفض التعارض الزمني تلقائيًا (409) |
| DELETE | `/timetable/{id}` | حذف ناعم (Soft Delete) — يتحقق من الملكية |

## Dashboard

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/dashboard` | جدول اليوم + الامتحان القادم (قادم) + نسبة الحضور (قادمة) |

## Exams

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/exams/upcoming` | مرتبة بالأقرب أولًا مع عدد الأيام المتبقية |
| POST | `/exams` | إنشاء امتحان مرتبط بمادة يملكها المستخدم |
| POST | `/exams/{examId}/checklist` | إضافة عنصر لقائمة تحضير الامتحان |
| PATCH | `/exams/checklist/{itemId}?isDone=true` | تبديل حالة عنصر التحضير |

## Assignments

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/assignments` | كل الواجبات مرتبة بالموعد النهائي |
| POST | `/assignments` | إنشاء واجب جديد |
| PATCH | `/assignments/{id}/progress` | تحديث نسبة الإنجاز والحالة |
| DELETE | `/assignments/{id}` | حذف ناعم (يتحقق من الملكية) |

## Attendance

| Method | Endpoint | ملاحظات |
|---|---|---|
| POST | `/attendance` | تسجيل/تحديث حضور يوم معيّن لمادة معيّنة (Upsert) |
| GET | `/attendance/stats` | نسبة الحضور لكل مادة (المتأخر = نصف حضور) |

## Study Mode

| Method | Endpoint | ملاحظات |
|---|---|---|
| POST | `/study/start` | بدء جلسة دراسة، يعيد `sessionId` |
| POST | `/study/end` | إنهاء الجلسة، يحدّث سلسلة الإنجاز تلقائيًا |
| GET | `/study/streak` | السلسلة الحالية والأطول |

## Notes

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/notes?q=...` | بحث في العنوان والوسوم |
| POST | `/notes` | إنشاء ملاحظة |
| DELETE | `/notes/{id}` | حذف ناعم |

## GPA & Statistics

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/gpa` | المعدل الفصلي والتراكمي مرجّح بالساعات المعتمدة |
| POST | `/gpa/grades` | إضافة درجة مادة لفصل معيّن |
| GET | `/statistics` | ساعات الدراسة الأسبوعية + إحصاءات الواجبات والحضور |

## Notifications

| Method | Endpoint | ملاحظات |
|---|---|---|
| GET | `/notifications` | كل الإشعارات، الأحدث أولًا |
| GET | `/notifications/unread-count` | عدد غير المقروءة (لشارة الجرس) |
| PATCH | `/notifications/{id}/read` | تعليم كمقروء |

## رموز الأخطاء الموحّدة

كل خطأ يُعاد بنفس الشكل:
```json
{ "success": false, "message": "رسالة عربية واضحة" }
```

| Status | المعنى |
|---|---|
| 400 | خطأ في البيانات المُرسلة |
| 401 | غير مسجّل الدخول / التوكن منتهي |
| 403 | لا تملك صلاحية الوصول لهذا المورد |
| 404 | المورد غير موجود |
| 409 | تعارض (مثال: تعارض مواعيد، بريد مسجّل مسبقًا) |
| 429 | تجاوزت الحد المسموح من المحاولات |
| 500 | خطأ داخلي غير متوقع بالخادم |

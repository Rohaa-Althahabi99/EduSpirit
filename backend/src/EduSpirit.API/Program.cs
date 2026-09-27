using System.Text;
using System.Threading.RateLimiting;
using EduSpirit.API.Middleware;
using Microsoft.AspNetCore.RateLimiting;
using EduSpirit.Application.Interfaces;
using EduSpirit.Application.Services;
using EduSpirit.Infrastructure.Identity;
using EduSpirit.Infrastructure.Persistence;
using EduSpirit.Infrastructure.Repositories;
using EduSpirit.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// ------------------------- Logging (Serilog) -------------------------
// يكتب للـ Console دائمًا + لملف يومي محليًا. لاحقًا في الإنتاج يُوجَّه لخدمة
// تجميع سجلات مركزية (Seq / Application Insights) بإضافة Sink إضافي فقط هنا.
builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/eduspirit-.log", rollingInterval: RollingInterval.Day, retainedFileCountLimit: 14));

// ------------------------- Database -------------------------
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ------------------------- Dependency Injection -------------------------
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IEmailService, SmtpEmailService>();
builder.Services.AddScoped<IGoogleTokenValidator, GoogleTokenValidator>();

builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<CourseService>();
builder.Services.AddScoped<TimetableService>();
builder.Services.AddScoped<ExamService>();
builder.Services.AddScoped<AssignmentService>();
builder.Services.AddScoped<ProjectService>();
builder.Services.AddScoped<AttendanceService>();
builder.Services.AddScoped<StudyService>();
builder.Services.AddScoped<NoteService>();
builder.Services.AddScoped<GpaService>();
builder.Services.AddScoped<StatisticsService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddScoped<FileService>();
builder.Services.AddScoped<IFileStorageService, LocalFileStorageService>();
builder.Services.AddScoped<DashboardService>();

// ------------------------- Authentication (JWT) -------------------------
var jwtSection = builder.Configuration.GetSection("Jwt");
var secretKey = jwtSection["SecretKey"]!;

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = true; // في الإنتاج: HTTPS إلزامي دائمًا
    options.SaveToken = false;
    options.MapInboundClaims = false;// لا نخزّن التوكن في AuthenticationProperties
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = jwtSection["Issuer"],
        ValidateAudience = true,
        ValidAudience = jwtSection["Audience"],
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ValidateLifetime = true,
        ClockSkew = TimeSpan.FromSeconds(30),
    };
});

builder.Services.AddAuthorization();

// ------------------------- Rate Limiting (ضد Brute Force) -------------------------
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("AuthPolicy", opt =>
    {
        opt.PermitLimit = 10;                 // 10 محاولات كحد أقصى
        opt.Window = TimeSpan.FromMinutes(1);  // خلال دقيقة واحدة
        opt.QueueLimit = 0;
    });
    options.RejectionStatusCode = 429;
});

// ------------------------- CORS -------------------------
builder.Services.AddCors(options =>
{
    options.AddPolicy("MobileApp", policy =>
    {
        // في الإنتاج: استبدل هذا بأصل التطبيق الفعلي بدل السماح للجميع.
        policy.WithOrigins(builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? Array.Empty<string>())
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// ------------------------- Validation -------------------------
// [ApiController] يفعّل تلقائيًا التحقق من DataAnnotations الموجودة على DTOs
// (Required, EmailAddress, MinLength...) ويرجع 400 مع تفاصيل الأخطاء تلقائيًا.

// ------------------------- Health Checks -------------------------
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database");

// ------------------------- Controllers + Swagger -------------------------
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
        {
            {
                new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                {
                    Reference = new Microsoft.OpenApi.Models.OpenApiReference
                    {
                        Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        });

    });

var app = builder.Build();

app.UseSerilogRequestLogging(); // يسجّل كل طلب HTTP تلقائيًا (المسار، الحالة، الزمن)

// ------------------------- Middleware Pipeline -------------------------
app.UseMiddleware<ExceptionHandlingMiddleware>(); // أول شيء دائمًا، ليلتقط كل شيء بعده

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
// يخدم الملفات المرفوعة (الصور، PDF...) من wwwroot/uploads عبر مسار /uploads
app.UseStaticFiles();

// رؤوس أمان إضافية على كل استجابة (تحمي من Clickjacking, MIME sniffing...)
app.Use(async (context, next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["Referrer-Policy"] = "no-referrer";
    await next();
});

app.UseCors("MobileApp");
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health"); // يراقبه الـ Load Balancer / Docker Health Check

app.Run();

# ---------- مرحلة البناء ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# ننسخ ملفات csproj أولًا فقط لنستفيد من Docker Layer Caching عند تكرار البناء
COPY src/EduSpirit.Domain/*.csproj EduSpirit.Domain/
COPY src/EduSpirit.Application/*.csproj EduSpirit.Application/
COPY src/EduSpirit.Infrastructure/*.csproj EduSpirit.Infrastructure/
COPY src/EduSpirit.API/*.csproj EduSpirit.API/
RUN dotnet restore EduSpirit.API/EduSpirit.API.csproj

COPY src/. .
RUN dotnet publish EduSpirit.API/EduSpirit.API.csproj -c Release -o /app --no-restore

# ---------- مرحلة التشغيل ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# نحتاج curl فقط من أجل HEALTHCHECK بالأسفل
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# مستخدم غير Root لتشغيل التطبيق — تقليل أثر أي ثغرة اختراق داخل الحاوية نفسها.
RUN useradd -m eduspirit

COPY --from=build --chown=eduspirit:eduspirit /app .
USER eduspirit

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "EduSpirit.API.dll"]

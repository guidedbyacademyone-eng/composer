# Multi-stage Dockerfile for ComposerWeb (Stage-1)
# Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy csproj and restore first (caches better)
COPY ["ComposerWeb/ComposerWeb.csproj", "ComposerWeb/"]
COPY ["ComposerStaff/Composer.Staff.csproj", "ComposerStaff/"]
COPY ["ComposerCore/Composer.Core.csproj", "ComposerCore/"]
RUN dotnet restore "ComposerWeb/ComposerWeb.csproj"

# copy everything and publish
COPY . .
WORKDIR /src/ComposerWeb
RUN dotnet publish "ComposerWeb.csproj" -c Release -o /app/publish /p:TrimUnusedDependencies=true

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

# Cloud Run uses the PORT env; default to 8080 for local runs
ENV ASPNETCORE_URLS="http://*:${PORT:-8080}"
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV COMPOSER_INVITES_MODE=google

# Non-root (optional): runtime images already configure a non-root user in many base images
# Expose port for local dev convenience
EXPOSE 8080

# Start the app
ENTRYPOINT ["dotnet", "ComposerWeb.dll"]

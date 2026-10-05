FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY global.json ./
COPY Servio.Model/Servio.Model.csproj Servio.Model/
COPY Servio.Services/Servio.Services.csproj Servio.Services/
COPY Servio.API/Servio.API.csproj Servio.API/
RUN dotnet restore Servio.API/Servio.API.csproj

COPY Servio.Model/ Servio.Model/
COPY Servio.Services/ Servio.Services/
COPY Servio.API/ Servio.API/
RUN dotnet publish Servio.API/Servio.API.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "Servio.API.dll"]

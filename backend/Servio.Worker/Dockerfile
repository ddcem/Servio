FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY global.json ./
COPY Servio.Model/Servio.Model.csproj Servio.Model/
COPY Servio.Worker/Servio.Worker.csproj Servio.Worker/
RUN dotnet restore Servio.Worker/Servio.Worker.csproj

COPY Servio.Model/ Servio.Model/
COPY Servio.Worker/ Servio.Worker/
RUN dotnet publish Servio.Worker/Servio.Worker.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "Servio.Worker.dll"]

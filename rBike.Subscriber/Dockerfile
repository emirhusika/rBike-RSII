FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY rBike.Subscriber/rBike.Subscriber.csproj rBike.Subscriber/
RUN dotnet restore rBike.Subscriber/rBike.Subscriber.csproj
COPY . .

RUN dotnet publish rBike.Subscriber/rBike.Subscriber.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "rBike.Subscriber.dll"]
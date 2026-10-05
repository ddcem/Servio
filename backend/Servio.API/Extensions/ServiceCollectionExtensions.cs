using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using Servio.API.Hubs;
using Servio.API.Realtime;
using Servio.Model.Configuration;
using Servio.Model.Responses;
using Servio.Services.Auth;
using Servio.Services.Common;
using Servio.Services.Configuration;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Database.Seed;
using Servio.Services.Menu;
using Servio.Services.Messaging;
using Servio.Services.Notifications;
using Servio.Services.Orders;
using Servio.Services.Payments;
using Servio.Services.Payments.PayPal;
using Servio.Services.Recommendations;
using Servio.Services.Reports;
using Servio.Services.ReferenceData;
using Servio.Services.Reservations;
using Servio.Services.Settings;
using Servio.Services.Tables;
using Servio.Services.Users;

namespace Servio.API.Extensions;

public static class ServiceCollectionExtensions
{
    public const string CorsPolicyName = "ServioClients";

    /// <summary>
    /// The single place where values from .env are read and turned into typed options.
    /// </summary>
    public static IServiceCollection AddServioOptions(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<JwtOptions>(o =>
        {
            o.Key = configuration.GetRequired(EnvKeys.JwtKey);
            o.Issuer = configuration.GetRequired(EnvKeys.JwtIssuer);
            o.Audience = configuration.GetRequired(EnvKeys.JwtAudience);
            o.ExpiresMinutes = configuration.GetRequiredInt(EnvKeys.JwtExpiresMinutes);
        });

        services.Configure<RabbitMqOptions>(o =>
        {
            o.Host = configuration.GetRequired(EnvKeys.RabbitMqHost);
            o.Port = configuration.GetRequiredInt(EnvKeys.RabbitMqPort);
            o.Username = configuration.GetRequired(EnvKeys.RabbitMqUser);
            o.Password = configuration.GetRequired(EnvKeys.RabbitMqPassword);
            o.EmailQueue = configuration.GetRequired(EnvKeys.RabbitMqEmailQueue);
        });

        services.Configure<PayPalOptions>(o =>
        {
            o.BaseUrl = configuration.GetRequired(EnvKeys.PayPalBaseUrl);
            o.ClientId = configuration.GetRequired(EnvKeys.PayPalClientId);
            o.ClientSecret = configuration.GetRequired(EnvKeys.PayPalClientSecret);
            o.ReturnUrl = configuration.GetRequired(EnvKeys.PayPalReturnUrl);
            o.CancelUrl = configuration.GetRequired(EnvKeys.PayPalCancelUrl);
        });

        services.Configure<RestaurantOptions>(o =>
        {
            o.TimeZoneId = configuration.GetRequired(EnvKeys.RestaurantTimeZone);
        });

        return services;
    }

    public static IServiceCollection AddServioDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ServioDbContext>(o => o.UseNpgsql(configuration.GetConnectionString()));
        services.AddScoped<DataSeeder>();
        return services;
    }

    public static IServiceCollection AddServioServices(this IServiceCollection services)
    {
        services.AddMemoryCache();
        services.AddHttpContextAccessor();

        services.AddSingleton<IPasswordHasher<User>, PasswordHasher<User>>();
        services.AddSingleton<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<IMessagePublisher, RabbitMqPublisher>();
        services.AddSingleton<IRestaurantClock, RestaurantClock>();
        services.AddSingleton<IRealtimeNotifier, SignalRNotifier>();

        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<ISessionValidator, SessionValidator>();
        services.AddScoped<INotificationDispatcher, NotificationDispatcher>();
        services.AddScoped<IAuthService, AuthService>();

        services.AddScoped<LookupService<Role>>();
        services.AddScoped<LookupService<PreparationStation>>();
        services.AddScoped<LookupService<PaymentMethod>>();
        services.AddScoped<ITableAreaService, TableAreaService>();
        services.AddScoped<IItemTagService, ItemTagService>();
        services.AddScoped<IMenuCategoryService, MenuCategoryService>();
        services.AddScoped<ICurrencyService, CurrencyService>();

        services.AddScoped<ISettingsService, SettingsService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IProfileService, ProfileService>();
        services.AddScoped<IMenuItemService, MenuItemService>();
        services.AddScoped<IRestaurantTableService, RestaurantTableService>();
        services.AddScoped<IReservationService, ReservationService>();
        services.AddScoped<IOrderService, OrderService>();
        services.AddScoped<IOrderTicketService, OrderTicketService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IPaymentService, PaymentService>();
        services.AddScoped<IRecommendationService, RecommendationService>();
        services.AddScoped<IReportService, ReportService>();

        services.AddHttpClient<IPayPalClient, PayPalClient>((provider, client) =>
        {
            var baseUrl = provider.GetRequiredService<IOptions<PayPalOptions>>().Value.BaseUrl.TrimEnd('/');
            client.BaseAddress = new Uri(baseUrl + "/");
            client.Timeout = TimeSpan.FromSeconds(30);
        });

        return services;
    }

    public static IServiceCollection AddServioAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(o =>
            {
                o.MapInboundClaims = false;
                o.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = configuration.GetRequired(EnvKeys.JwtIssuer),
                    ValidateAudience = true,
                    ValidAudience = configuration.GetRequired(EnvKeys.JwtAudience),
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(configuration.GetRequired(EnvKeys.JwtKey))),
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromMinutes(1),
                    NameClaimType = System.Security.Claims.ClaimTypes.Name,
                    RoleClaimType = System.Security.Claims.ClaimTypes.Role
                };
                o.Events = new JwtBearerEvents
                {
                    // 401 and 403 carry the same JSON error shape as every other error, so the apps can show it.
                    OnChallenge = async context =>
                    {
                        context.HandleResponse();
                        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                        await context.Response.WriteAsJsonAsync(
                            new ErrorResponse("Your session has expired or you are not logged in. Please log in again."));
                    },
                    OnForbidden = async context =>
                    {
                        context.Response.StatusCode = StatusCodes.Status403Forbidden;
                        await context.Response.WriteAsJsonAsync(
                            new ErrorResponse("Your role does not have permission for this action."));
                    },
                    // WebSocket clients cannot send headers, so the hub accepts the token from the query string.
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];
                        if (!string.IsNullOrEmpty(accessToken) && context.HttpContext.Request.Path.StartsWithSegments(NotificationHub.Path))
                        {
                            context.Token = accessToken;
                        }

                        return Task.CompletedTask;
                    },
                    // Tokens of logged-out sessions are rejected even before they expire.
                    OnTokenValidated = async context =>
                    {
                        var jti = context.Principal?.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Jti)?.Value;
                        var validator = context.HttpContext.RequestServices.GetRequiredService<ISessionValidator>();

                        if (jti is null || !await validator.IsActiveAsync(jti, context.HttpContext.RequestAborted))
                        {
                            context.Fail("Session is no longer active.");
                        }
                    }
                };
            });

        services.AddAuthorization();
        return services;
    }

    public static IServiceCollection AddServioCors(this IServiceCollection services, IConfiguration configuration)
    {
        var origins = configuration.GetRequired(EnvKeys.CorsAllowedOrigins)
            .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        services.AddCors(o => o.AddPolicy(CorsPolicyName, p => p
            .WithOrigins(origins)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials()));

        return services;
    }

    public static IServiceCollection AddServioControllers(this IServiceCollection services)
    {
        services.AddControllers()
            .AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()))
            .ConfigureApiBehaviorOptions(o =>
            {
                // Validation errors are returned in the same shape as all other errors.
                o.InvalidModelStateResponseFactory = context =>
                {
                    var errors = context.ModelState
                        .Where(x => x.Value?.Errors.Count > 0)
                        .ToDictionary(
                            x => x.Key,
                            x => x.Value!.Errors.Select(e => e.ErrorMessage).ToArray());

                    return new BadRequestObjectResult(
                        new ErrorResponse("Some fields are not valid. Please correct them and try again.", errors));
                };
            });

        return services;
    }

    public static IServiceCollection AddServioSignalR(this IServiceCollection services)
    {
        services.AddSignalR()
            .AddJsonProtocol(o => o.PayloadSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
        return services;
    }

    public static IServiceCollection AddServioSwagger(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(o =>
        {
            o.SwaggerDoc("v1", new OpenApiInfo { Title = "Servio API", Version = "v1" });
            o.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                Description = "Paste the token returned by POST /api/auth/login"
            });
            o.AddSecurityRequirement(document => new OpenApiSecurityRequirement
            {
                [new OpenApiSecuritySchemeReference("Bearer", document)] = []
            });
        });

        return services;
    }
}

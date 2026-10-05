using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using Servio.Model.Configuration;
using Servio.Model.Responses;
using Servio.Services.Auth;
using Servio.Services.Configuration;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Database.Seed;
using Servio.Services.Messaging;

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

        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<ISessionValidator, SessionValidator>();
        services.AddScoped<IAuthService, AuthService>();

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

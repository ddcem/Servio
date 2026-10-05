using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Servio.API.Extensions;
using Servio.API.Middleware;
using Servio.Services.Database;
using Servio.Services.Database.Seed;

// Loads the .env file from the repository root when running outside Docker.
// Variables that are already set (Docker env_file, launch profile) are not overwritten.
Env.NoClobber().TraversePath().Load();

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddEnvironmentVariables();

builder.Services
    .AddServioOptions(builder.Configuration)
    .AddServioDatabase(builder.Configuration)
    .AddServioServices()
    .AddServioAuthentication(builder.Configuration)
    .AddServioCors(builder.Configuration)
    .AddServioControllers()
    .AddServioSwagger();

var app = builder.Build();

await using (var scope = app.Services.CreateAsyncScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ServioDbContext>();
    await context.Database.MigrateAsync();
    await scope.ServiceProvider.GetRequiredService<DataSeeder>().SeedAsync();
}

app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(ServiceCollectionExtensions.CorsPolicyName);
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

await app.RunAsync();

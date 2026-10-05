using DotNetEnv;
using Servio.Worker.Configuration;
using Servio.Worker.Consumers;
using Servio.Worker.Email;

// Loads the .env file from the repository root when running outside Docker.
Env.NoClobber().TraversePath().Load();

var builder = Host.CreateApplicationBuilder(args);
builder.Configuration.AddEnvironmentVariables();

builder.Services.AddWorkerOptions(builder.Configuration);
builder.Services.AddSingleton<IEmailSender, SmtpEmailSender>();
builder.Services.AddHostedService<EmailQueueConsumer>();

var host = builder.Build();
await host.RunAsync();

using System;
using CommandLine;
using DotnetListener.Model;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace DotnetListener
{
    public class Program
    {
        private static CommandLineArgs _appConfig;
        private static bool _isDevelopment = false;

        public static void Main(string[] args)
        {
            GetEnvironmentType();
            ParseArgsAndSetAppConfig(args);
            CreateHostBuilder(args).Build().Run();
        }

        private static void GetEnvironmentType()
        {
            var envType = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
            _isDevelopment = String.Equals(envType, "Development", StringComparison.OrdinalIgnoreCase);
        }

        private static void ParseArgsAndSetAppConfig(string[] args) =>
            new Parser(settings => settings.IgnoreUnknownArguments = true)
                .ParseArguments<CommandLineArgs>(args)
                .WithParsed(cmdArgs => _appConfig = cmdArgs);

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseSetting("AppMode", _appConfig.AppMode.ToString());
                    if (_appConfig.AppMode == AppMode.AzureRelay)
                    {
                        var connectionString = GetAzureRelayConnectionString();
                        webBuilder.UseAzureRelay(options => options.UrlPrefixes.Add(connectionString)).UseUrls();
                    }
                    webBuilder.UseStartup<Startup>();
                });

        private static string GetAzureRelayConnectionString()
        {
            if (!_isDevelopment)
            {
                throw new NotImplementedException("Getting Azure Relay connection string is not supported outside the development environment.");
            }
            var configuration = new ConfigurationBuilder().AddUserSecrets<Program>().Build();
            var connectionString = configuration.GetValue<string>("AzureRelay:ConnectionString");

            if (String.IsNullOrEmpty(connectionString))
            {
                throw new ArgumentException("Azure Relay connection string is empty or missing.");
            }
            return connectionString;
        }
    }
}

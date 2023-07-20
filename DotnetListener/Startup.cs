using System;
using DotnetListener.Model;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace DotnetListener
{
    public class Startup
    {
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _environment;
        private readonly AppMode _appMode;

        public Startup(IConfiguration configuration, IWebHostEnvironment environment)
        {
            _configuration = configuration;
            _environment = environment;
            _appMode = (AppMode)Enum.Parse(typeof(AppMode), _configuration.GetValue<String>("AppMode"));
        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            if (_environment.IsDevelopment() && _appMode == AppMode.Api)
            {
                services.AddSwaggerGen();
            }
        }

        public void Configure(IApplicationBuilder app)
        {
            if (_environment.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                if (_appMode == AppMode.Api)
                {
                    app.UseSwagger();
                    app.UseSwaggerUI();
                }
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}

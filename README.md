
# Business Central and Azure Relay Integration

This is example project for articles:

- Integrate Business Central and corporate services with Azure Relay - part 1

- Integrate Business Central and corporate services with Azure Relay - part 2 (coming soon)

  

I recommend reading these articles before proceeding with this readme.

  

## Prerequisites

Both projects are included in VS Code workspace file.

### BCSender

- Requires Business Central V22 development environment.

- VS Code with [AL extensions](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)

  

### DotnetListener

- Requires [.NET 6 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)

- VS Code with [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit) (optional)

  

If you are not accustomed to using VS Code for C# development, you have option to open *DotnetListener* project in Visual Studio via .sln file (project's root).

  

## Setup :wrench:

1. Clone the repository

2. Create Azure Relay Hybrid Connection as per instructions in the first article (chapter *Setting up Azure Relay namespace and Hybrid Connection*). Use [Azure Relay configuration file](./azure-relay-config.txt) to populate configuration data from configured Azure Relay Hybrid Connection.

3. Configure *BCSender* [launch configuration](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-json-launch-file) according to your Business Central development environment setup and publish BC sender application.

4. Configure listener by running following commands from the root of the *DotnetListener* project:

    dotnet user-secrets init

    dotnet user-secrets set 'AzureRelay:ConnectionString' '<hybrid_connection_string>'


5. Select the *Launch as Azure Relay listener (DotnetListener)* launch configuration from the *Run and Debug* view (CTRL + SHIFT + D) and run the application. Alternatively,you can run application from the terminal:

    dotnet run --AppMode AzureRelay


6. Open *BCSender* application and navigate to *Azure Service Bus Relay Setup* page. Populate fields using respective values from [Azure Relay configuration file](./azure-relay-config.txt) and tick *IsEnabled* option (in the same row). You will be also asked to setup encryption key, for this example you can skip it.

7. Run 'Test Connection' action and if you configured everything correctly, you should expect message 'Hello from Azure Relay listener API!'.


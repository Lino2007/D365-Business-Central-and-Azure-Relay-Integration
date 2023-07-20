using CommandLine;

namespace DotnetListener.Model
{
    public class CommandLineArgs
    {
        [Option("AppMode", Default = AppMode.Api, HelpText = "Specifies whether application will run as Azure Relay listener or as classic Web Api. Options: Api, AzureRelay")]
        public AppMode AppMode { get; set; }
    }
}
// Learn more about F# at http://fsharp.org

open System
open System.IO
open Microsoft.Extensions.Configuration
open ShopCrawler.Ebay
open ShopCrawler.Ebay.Types

[<CLIMutable>]
type Configuration = {
    Ebay: EbayConfig
}



[<EntryPoint>]
let main argv =
    let builder = ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appSettings.json", true, true)
                    .AddJsonFile("appSettings.Development.json", true, true)
                    .AddEnvironmentVariables() 
    let configurationRoot = builder.Build()
    let configuration = configurationRoot.Get<Configuration>()
    let authRes = Auth.auth configuration.Ebay
    
    match authRes with
    | Ok r -> Console.WriteLine r
    | Error e -> Console.WriteLine e
    
    0 // return an integer exit code

// Learn more about F# at http://fsharp.org

open System
open System.IO
open Microsoft.Extensions.Configuration
open ShopCrawler.Ebay
open ShopCrawler.Ebay.Apis
open ShopCrawler.Ebay.Types
open ShopCrawler.Ebay.SaveToDB

[<CLIMutable>]
type Configuration = {
    Ebay: EbayConfig
}

let run (client: Client): Result<string,'a> =
//    let items = Finding.findByKeywords client ["blackberry"; "keyone"]
    let items = Finding.findItemsAdvanced client ["iphone"; "xs"] "9355"
    match items with
    | Ok _items ->
        saveItems _items
        printf "%A" _items
    | Error e -> Console.WriteLine ("Error: {0}", e)
    Ok "Done"

[<EntryPoint>]
let main argv =
    let builder = ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appSettings.json", true, true)
                    .AddJsonFile("appSettings.Development.json", true, true)
                    .AddEnvironmentVariables() 
    let configurationRoot = builder.Build()
    let configuration = configurationRoot.Get<Configuration>()
    
    let result =
        Auth.auth configuration.Ebay
        |> Result.bind (Client.build configuration.Ebay >> Ok)
        |> Result.bind run
    
    match result with
    | Ok _ -> ()
    | Error e -> sprintf "Error building client: %s" e |> failwith
    
    0 // return an integer exit code

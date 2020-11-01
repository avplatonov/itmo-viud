namespace ShopCrawler.Service

open Microsoft.Extensions.Options
open ShopCrawler.Ebay
open ShopCrawler.Ebay.Apis
open ShopCrawler.Ebay.Types

type FinderService (ebayConfig: IOptions<EbayConfig>) =
    let client =
        Auth.auth ebayConfig.Value
        |> Result.bind (Client.build ebayConfig.Value >> Ok)
        |> function
          | Ok c -> c
          | Error e -> failwith e
        
    member x.Find =
        Finding.findItemsAdvanced client
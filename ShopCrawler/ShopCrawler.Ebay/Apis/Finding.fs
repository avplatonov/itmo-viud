module ShopCrawler.Ebay.Apis.Finding

open ShopCrawler.Ebay
open ShopCrawler.Ebay.Parsers
open ShopCrawler.Common.Utils

open FSharp.Data.JsonExtensions
open FSharp.Data

let findByKeywords client keywords =
    Client.request client "services/search/FindingService/v1" [
        "OPERATION-NAME", "findItemsByKeywords"
        "SERVICE-VERSION", "1.0.0"
        "REST-PAYLOAD", ""
        "itemFilter.name", "ListingType"
        "itemFilter.value", "Auction"
        "keywords", keywords |> String.concat " "
        "paginationInput.entriesPerPage", "100"
        "sortOrder", "BidCountFewest"
    ]
    |> Result.bind ^ fun r ->
        let items = (r?findItemsByKeywordsResponse.AsSingleItem?searchResult.AsSingleItem?item.AsArray())
        items
        |> Array.map parseItem
        |> Ok


let findItemsAdvanced client keywords category =
    Client.request client "services/search/FindingService/v1" [
        "OPERATION-NAME", "findItemsAdvanced"
        "SERVICE-VERSION", "1.0.0"
        "REST-PAYLOAD", ""
        "keywords", keywords |> String.concat " "
        "categoryId", category
        "descriptionSearch", "false"
        "paginationInput.entriesPerPage", "10"
    ]
    |> Result.bind ^ fun r ->
        let items = (r?findItemsAdvancedResponse.AsSingleItem?searchResult.AsSingleItem?item.AsArray())
        
        items
        |> Array.map parseItem
        |> Ok 

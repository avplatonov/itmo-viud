

namespace ShopCrawler.Logic

open FSharp.Data

module Say =
    let hello name =
        printfn "Hello %s" name

module API =
    let getRequestByKeywords appid keywords = 
        let getDataFromApi: HttpResponse =
            let baseUrl = "https://svcs.ebay.com/services/search/FindingService/v1"
            Http.Request
                ( baseUrl,
                  query=
                      [
                        "OPERATION-NAME", "findItemsByKeywords";
                        "SERVICE-VERSION", "1.0.0";
                        "SECURITY-APPNAME", appid;
                        "RESPONSE-DATA-FORMAT", "JSON";
                        "REST-PAYLOAD", ""
                        "itemFilter.name", "ListingType";
                        "itemFilter.value", "Auction";
                        "keywords", keywords;
                        "paginationInput.entriesPerPage", "5";
                        "sortOrder", "BidCountFewest"
                      ],
                  httpMethod="GET"
                )
                
        JsonValue.Parse(getDataFromApi.Body.ToString().Split("\n").[1].[3..] |> (fun s -> s.[..(s.Length - 2)]))
        

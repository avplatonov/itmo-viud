module ShopCrawler.Ebay.Client

open FSharp.Data
open FSharp.Data.HttpRequestHeaders

open Types

let build config token =
    { ApiToken = token
      AppName = config.ClientId
      BaseUrl = config.ApiBaseUrl }
    
let buildAuth client =
    let value = sprintf "Bearer %s" client.ApiToken.Token
    Authorization value
    
let request client method query =
    let url =
        sprintf "%s/%s" client.BaseUrl method
    let headers = [
        buildAuth client
    ]
    let query = query @ [
        "SECURITY-APPNAME", client.AppName
        "RESPONSE-DATA-FORMAT", "JSON"
    ]
    
    let result = Http.Request(url, headers = headers, query = query, silentHttpErrors = true)
    
    match result.StatusCode, result.Body with
    | 200, Text body -> JsonValue.Parse body |> Ok
    | code, Text b -> sprintf "Unexpected error. Status code: %d. %s" code b |> Error
    | code, _ -> sprintf "Unknown error. Status code: %d" code |> Error